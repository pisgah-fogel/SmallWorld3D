extends Spatial

enum State {
	ENTER,
	WANDER,
	SCARED,
	CHASING,
	CAUGHT,
	BEATING,
	GOBACK
}

var mState = State.ENTER

export(int) var spawnDepth = -2
export(int) var mDepth = 0

export(int) var default_speed = 2
export(int) var speed = 2
export(int) var tasting_propability = 60

export(float) var timer_objectif = 1
export(int) var bad_luck = 5

export(Rect2) var spawner_zone = Rect2(-23,-24,5,23+18) setget set_spawner

var mAnimationPlayer = null
onready var mTimer = $Timer

var destination = Vector2.ZERO
var current_orientation : float = 0

func set_spawner(spawner):
	spawner_zone = spawner
	var a = random_vec_in_zone()
	self.global_transform.origin = Vector3(a.x, spawnDepth, a.y)

func random_vec_in_zone():
	return Vector2(spawner_zone.position.x+spawner_zone.size.x*randf(), spawner_zone.position.y+spawner_zone.size.y*randf())

var mItem = null
func _ready():
	self.rotation.y = randf()
	print("Fish spawned")

func setFishType(item):
	print("Fish set FishType")
	mItem = item
	var mMesh = null
	match mItem.id:
		Item._id.ID_FISH:
			var Fish = load("res://gfx/Fish.glb")
			mMesh = Fish.instance()
		Item._id.ID_TURTLE:
			var Turtle = load("res://gfx/SwimmingTurtle.glb")
			mMesh = Turtle.instance()
	if mMesh:
		add_child(mMesh)
		mAnimationPlayer = mMesh.get_node("AnimationPlayer")
		mMesh.rotation = Vector3(0, 3.14/2, 0)
		start_enter()
	else:
		print("Error can't load Fish's mesh")

func _unhandled_key_input(event):
	match mState:
		State.BEATING:
			if event.is_action_pressed("ui_action"):
				if randi()%100 > bad_luck:
					food.catchAFish(self)
				else:
					food.baitEatenByFish(self)
					start_wander() # Or start_scared() ?
		State.CHASING:
			if event.is_action_pressed("ui_action"):
				start_scared()

func _process(delta):
	if delta > 1:
		return # Abord if lagging
	match mState:
		State.WANDER:
			state_wander(delta)
		State.ENTER:
			state_enter(delta)
		State.SCARED:
			state_scared(delta)
		State.CHASING:
			state_chasing(delta)
		State.GOBACK:
			state_goback(delta)

func _on_FishView_body_entered(body):
	if mState == State.WANDER or mState == State.CHASING:
		# TODO: smooth angle
		var a = self.get_global_transform().looking_at(body.get_global_transform().origin, Vector3(0, 1, 0))
		a = a.rotated(Vector3(0, 1, 0), 3.14)
		self.global_transform.basis = a.basis
		start_scared()

var food = null
func _on_PredatorView_body_entered(body):
	if mState == State.WANDER:
		start_chasing()
		food = body

######################## CHASING ########################

func start_chasing():
	mState = State.CHASING
	speed = default_speed

func state_chasing(delta):
	if food != null:
		var baitLoc = food.to_global(Vector3(0, 0, 0))
		if Vector2(translation.x, translation.z).distance_to(Vector2(baitLoc.x, baitLoc.z)) < 0.05:
			food.beating()
			if randi()%100>tasting_propability:
				print("Beating")
				mState = State.BEATING
				mTimer.start(timer_objectif)
			else:
				print("Tasting")
				food.tasting()
				start_goback()
		else:
			# move to bait
			self.look_at(baitLoc, Vector3(0, 1, 0))
			translate(Vector3(0, 0, -delta*speed))
	else:
		start_wander()

func _show_yourself():
	mState = State.CAUGHT
	mTimer.start(10)
	rotation = Vector3(0, 3.14/2, 0)

func _on_Timer_timeout():
	if mState == State.BEATING:
		if food:
			food.baitEatenByFish(self)
		start_wander()
	if mState == State.CAUGHT:
		start_wander() # Just in case...
		# TODO: Correct bug when 2 fishes get caught at the same time
		
#######################  GOBACK  ##########################
var goback_duration = 2.2
func start_goback():
	mState = State.GOBACK
	goback_duration = randf()*2+1
	speed = default_speed/2

func state_goback(delta):
	goback_duration -= delta
	if goback_duration <= 0:
		start_chasing()
	if food != null:
		var baitLoc = food.to_global(Vector3(0, 0, 0))
		self.look_at(baitLoc, Vector3(0, 1, 0))
		translate(Vector3(0, 0, delta*speed))
	else:
		start_wander()

#######################  ENTER   ##########################

func start_enter():
	speed = default_speed/2
	mState = State.ENTER
	mAnimationPlayer.get_animation("Static").loop = true
	mAnimationPlayer.play("Static")
	translation.y = spawnDepth

func state_enter(delta):
	if translation.y < mDepth:
		translation.y += delta*speed
	else:
		start_wander()

#######################  SCARED  ###########################
func start_scared():
	speed = default_speed
	mState = State.SCARED
	mAnimationPlayer.get_animation("Static").loop = true
	mAnimationPlayer.play("Static")

func state_scared(delta):
	if translation.y > spawnDepth:
		translate(delta*speed*Vector3(0, -1, -1))
	else:
		queue_free()
		print("Fish vanished into deep waters")

#######################   WANDERING   ###############################

func start_wander():
	speed = default_speed/2
	mAnimationPlayer.get_animation("Static").loop = true
	mAnimationPlayer.play("Static")
	destination = random_vec_in_zone()
	self.look_at(Vector3(destination.x, mDepth, destination.y), Vector3(0, 1, 0))
	mState = State.WANDER

func state_wander(delta):
	if translation.distance_to(Vector3(destination.x, mDepth, destination.y)) <= 0.1:
		destination = random_vec_in_zone()
	else:
		# TODO: Smooth rotation
		self.look_at(Vector3(destination.x, mDepth, destination.y), Vector3(0, 1, 0))
		translate(Vector3(0, 0, -delta*speed))
