extends Spatial

enum State {
	ENTER,
	WANDER,
	SCARED,
	CHASING,
	CAUGHT
}

var mState = State.ENTER

export(int) var spawnDepth = -2
export(int) var mDepth = 0

export(int) var default_speed = 2
export(int) var speed = 2

# -23 < x < 18
# -24 < z < -19
export(Rect2) var spawner_zone = Rect2(-23,-24,5,23+18)

var mAnimationPlayer = null
onready var mTimer = $Timer

var destination = Vector2.ZERO
var current_orientation : float = 0

func random_vec_in_zone():
	return Vector2(spawner_zone.position.x+spawner_zone.size.x*randf(), spawner_zone.position.y+spawner_zone.size.y*randf())

const Item = preload("res://Item.gd")
var mItem = null
func _ready():
	self.rotation.y = randf()
	mItem = Item.new()
	if randi()%100 > 90:
		mItem.id = Item._id.ID_TURTLE
	else:
		mItem.id = Item._id.ID_FISH
	mItem.name = Item._name[mItem.id]
	mItem.data["size"] = randi()%5+6
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
	else:
		print("Error can't load Fish's mesh")
	
	start_enter()

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

func _unhandled_key_input(event):
	match mState:
		State.WANDER:
			event_wander(event)

func calc_angle(a:Vector3, b:Vector3) -> float:
	return atan2(b.z - a.z, b.x - a.x)

func _on_FishView_body_entered(body):
	
	if mState == State.WANDER or mState == State.CHASING: # TODO: also on CHASING
		# TODO: Fix this angle
		# TODO: smooth angle
		self.rotation.y = calc_angle(body.translation, self.translation)
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
			#food.tasting() # TODO: add randomness
			#food.beating() # TODO: measure reaction time and escape...
			food.catchAFish(self)
		else:
			# move to bait
			self.look_at(baitLoc, Vector3(0, 1, 0))
			translate(Vector3(0, 0, -delta*speed))
	else:
		start_wander()

func _show_yourself():
	mState = State.CAUGHT
	rotation = Vector3(0, 3.14/2, 0)

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

func end_wanter():
	pass

func event_wander(event):
	pass
