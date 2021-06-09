extends Spatial

class_name Fish

signal translationDone(fish)

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

export(int) var default_speed = 2 # TODO: 1.5 does not work; fishes never finish enterring
export(int) var speed = 2
export(int) var tasting_propability = 70
export(float) var distance_eating = 0.7

export(float) var timer_objectif = 0.7
export(int) var bad_luck = 20

export (float) var high_caught_fish = 1

export(Rect2) var spawner_zone = Rect2(-23,-24,5,23+18) setget set_spawner

var mAnimationPlayer = null
onready var mTimer = $Timer

var destination = Vector2.ZERO
var current_orientation : float = 0

func set_spawner(spawner):
	spawner_zone = spawner
	var a = random_vec_in_zone()
	#self.global_transform.origin = Vector3(a.x, spawnDepth, a.y) # Condition "!is_inside_tree()" is true. Returned: Transform()
	self.transform.origin = Vector3(a.x, spawnDepth, a.y)

func random_vec_in_zone():
	return Vector2(spawner_zone.position.x+spawner_zone.size.x*randf(), spawner_zone.position.y+spawner_zone.size.y*randf())

func changeState(newstate):
	match mState:
		State.ENTER:
			exitEnterState()
		State.WANDER:
			exitWanderState()
		State.SCARED:
			exitScaredState()
		State.CHASING:
			exitChasingState()
		State.CAUGHT:
			exitCaughtState()
		State.BEATING:
			exitBeatingState()
		State.GOBACK:
			exitGoBackState()
	mState = newstate
	match mState:
		State.ENTER:
			enterEnterState()
		State.WANDER:
			enterWanderState()
		State.SCARED:
			enterScaredState()
		State.CHASING:
			enterChasingState()
		State.CAUGHT:
			enterCaughtState()
		State.BEATING:
			enterBeatingState()
		State.GOBACK:
			enterGoBackState()
	

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
		changeState(State.ENTER)
	else:
		print("Error can't load Fish's mesh")

func _unhandled_key_input(event):
	match mState:
		State.BEATING:
			beating_input(event)
		State.CHASING:
			chasing_input(event)

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
		State.CAUGHT:
			state_caught(delta)

func _on_FishView_body_entered(body):
	if mState == State.WANDER or mState == State.CHASING:
		# TODO: smooth angle
		var a = self.get_global_transform().looking_at(body.get_global_transform().origin, Vector3(0, 1, 0))
		a = a.rotated(Vector3(0, 1, 0), 3.14)
		self.global_transform.basis = a.basis
		changeState(State.SCARED)

var bait_location : Vector3 = Vector3.ZERO
func _on_PredatorView_body_entered(body):
	if mState == State.WANDER:
		body.connect("tree_exiting", self, "_on_bait_deleted")
		self.connect("fishCaught", body, "_on_fish_caught")
		self.connect("baitEaten", body, "_on_bait_eaten")
		self.connect("beating", body, "_on_beating")
		self.connect("tasting", body, "_on_tasting")
		bait_location = body.to_global(Vector3(0, 0, 0))
		changeState(State.CHASING)

func _on_bait_deleted():
	changeState(State.WANDER)

######################## BEATING ########################
signal fishCaught(fish)
signal baitEaten(fish)
signal beating()
signal tasting()

func enterBeatingState():
	mTimer.start(timer_objectif)

func beating_input(event):
	if event.is_action_pressed("ui_action"):
		print("Beating: player pressed at the right time")
		if randi()%100 > bad_luck:
			print("Player got the fish")
			self.emit_signal("fishCaught", self)
		else:
			print("Unlucky")
			self.emit_signal("baitEaten", self)
			changeState(State.WANDER) # Or State.SCARED ?

func exitBeatingState():
	pass

######################## CHASING ########################

func enterChasingState():
	speed = default_speed

func chasing_input(event):
	if event.is_action_pressed("ui_action"):
		changeState(State.SCARED)

func state_chasing(delta):
	if bait_location != Vector3.ZERO:
		if Vector2(translation.x, translation.z).distance_to(Vector2(bait_location.x, bait_location.z)) < distance_eating:
			if randi()%100>tasting_propability:
				print("Beating")
				self.emit_signal("beating")
				changeState(State.BEATING)
			else:
				print("Tasting")
				self.emit_signal("tasting")
				changeState(State.GOBACK)
		else:
			# move to bait
			smoothLookAt(bait_location)
			translate(Vector3(0, 0, -delta*speed))
	else:
		changeState(State.WANDER)

func _on_Timer_timeout():
	if mState == State.BEATING:
		self.emit_signal("baitEaten", self)
		changeState(State.WANDER)
	if mState == State.CAUGHT:
		changeState(State.WANDER) # Just in case...
		# TODO: Correct bug when 2 fishes get caught at the same time

func exitChasingState():
	pass
		
#######################  GOBACK  ##########################
var goback_duration = 2.2

func enterGoBackState():
	goback_duration = randf()*2+1
	speed = default_speed/2

func state_goback(delta):
	goback_duration -= delta
	if goback_duration <= 0:
		changeState(State.CHASING)
	smoothLookAt(bait_location)
	translate(Vector3(0, 0, delta*speed))

func exitGoBackState():
	pass

#######################  ENTER   ##########################

func enterEnterState():
	speed = default_speed/2
	mAnimationPlayer.get_animation("Static").loop = true
	mAnimationPlayer.play("Static")
	translation.y = spawnDepth

func state_enter(delta):
	if translation.y < mDepth:
		translation.y += delta*speed
	else:
		changeState(State.WANDER)

func exitEnterState():
	pass

#######################  SCARED  ###########################

func enterScaredState():
	speed = default_speed
	mAnimationPlayer.get_animation("Static").loop = true
	mAnimationPlayer.play("Static")

func state_scared(delta):
	if translation.y > spawnDepth:
		translate(delta*speed*Vector3(0, -1, -1))
	else:
		queue_free()
		print("Fish vanished into deep waters")

func exitScaredState():
	pass

#######################   WANDERING   ###############################
func enterWanderState():
	speed = default_speed/2
	mAnimationPlayer.get_animation("Static").loop = true
	mAnimationPlayer.play("Static")
	destination = random_vec_in_zone()
	smoothLookAt(Vector3(destination.x, mDepth, destination.y))

func smoothLookAt(target):
	var targetTransform = global_transform.looking_at(target, Vector3(0.0, 1.0, 0.0))
	self.global_transform = self.global_transform.interpolate_with(targetTransform, 0.1)

func state_wander(delta):
	if translation.distance_to(Vector3(destination.x, mDepth, destination.y)) <= 0.1:
		destination = random_vec_in_zone()
	else:
		smoothLookAt(Vector3(destination.x, mDepth, destination.y))
		translate(Vector3(0, 0, -delta*speed))

func exitWanderState():
	pass
########################## CAUGHT: MOVE TO PLAYER ##############################

var caught_translation_vector : Vector3 = Vector3.ZERO
var caught_translation_target : Vector3 = Vector3.ZERO

func enterCaughtState():
	print("Fish: Entering Caught state")

func _on_translateFishToPlayer(player_position):
	var fishGlobal = self.global_transform.origin
	caught_translation_target = player_position + Vector3(0, high_caught_fish, 0)
	caught_translation_vector = (caught_translation_target - fishGlobal).normalized()
	changeState(State.CAUGHT)
	mTimer.start(10)
	rotation = Vector3(0, 3.14/2, 0)

func state_caught(delta):
	self.global_translate(caught_translation_vector*delta*5.0)
	var fishGlobal = self.global_transform.origin
	if Vector2(fishGlobal.x, fishGlobal.z).distance_to(Vector2(caught_translation_target.x, caught_translation_target.z)) < 1:
		exitCaughtState()

func exitCaughtState():
	print("Fish: Exit Caught state")
	self.emit_signal("translationDone", self) # telling player he can pick-up the fish
