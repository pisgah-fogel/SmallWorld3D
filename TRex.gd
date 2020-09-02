extends KinematicBody

onready var mAnimationPlayer = $Trex/AnimationPlayer
onready var mTimer = $Timer

enum State { IDLE, WANDER }
var mState = State.IDLE

func _ready():
	mAnimationPlayer.get_animation("IdleTrack").loop = true
	mAnimationPlayer.play("IdleTrack")
	mTimer.start(randi()%5+1)

func _on_Timer_timeout():
	match mState:
		State.IDLE:
			pickUpNewRandTarget()
			mState = State.WANDER
			mTimer.start(randi()%10+7)
		State.WANDER:
			mState = State.IDLE
			mTimer.start(randi()%6+3)

var target = Vector3.ZERO
export(float) var speed = 10
func _physics_process(delta):
	if mState == State.WANDER:
		var col = move_and_collide(target*delta*speed) # TODO: change by move_and_slide and handle the output
		if col:
			# Turn to avoid colliding again
			# TODO: smooth the angle
			self.rotate_y(3.14)

func pickUpNewRandTarget():
	target = Vector3(randi()%20, self.global_transform.origin.y, randi()%20)

func _process(delta):
	match mState:
		State.IDLE:
			process_idle(delta)
		State.WANDER:
			process_wander(delta)

func process_idle(delta):
	pass

func process_wander(delta):
	if self.global_transform.origin.distance_to(target) < 5.0:
		print("Trex reached target")
		pickUpNewRandTarget()
		# TODO: Turn smoothly to somewhere else
