extends Spatial

enum State {
	WANDER
}

var mState = State.WANDER

export(int) var mDepth = 0

export(int) var default_speed = 50
export(int) var speed = 1

# 16 < x < 20
# -12 < z < 5
export(Rect2) var spawner_zone = Rect2(16,-12,4,5+12)

onready var mAnimationPlayer = $Fish/AnimationPlayer
onready var mTimer = $Timer

var destination = Vector2.ZERO
var current_orientation : float = 0

func random_vec_in_zone():
	return Vector2(spawner_zone.position.x+spawner_zone.size.x*randf(), spawner_zone.position.y+spawner_zone.size.y*randf())

func _ready():
	self.rotation.y = randf()*2*3.14
	start_wander()

func _process(delta):
	if delta > 1:
		return # Abord if lagging
	match mState:
		State.WANDER:
			state_wander(delta)

func _unhandled_key_input(event):
	match mState:
		State.WANDER:
			event_wander(event)

func _on_FishView_body_entered(body):
	print("Body entered fishview")


func _on_PredatorView_body_entered(body):
	print("Body entered predatorView")
	
#######################   WANDERING   ###############################

func start_wander():
	mAnimationPlayer.get_animation("Static").loop = true
	mAnimationPlayer.play("Static")
	destination = random_vec_in_zone()
	self.look_at(Vector3(destination.x, mDepth, destination.y), Vector3(0, 1, 0))
	mState = State.WANDER

func state_wander(delta):
	if translation.distance_to(Vector3(destination.x, mDepth, destination.y)) <= 0.1:
		destination = random_vec_in_zone()
		#self.look_at(Vector3(destination.x, mDepth, destination.y), Vector3(0, 1, 0))
	else:
		# TODO: Smooth rotation
		self.look_at(Vector3(destination.x, mDepth, destination.y), Vector3(0, 1, 0))
		translate(Vector3(0, 0, -delta*speed))

func end_wanter():
	pass

func event_wander(event):
	pass
