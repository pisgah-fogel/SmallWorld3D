extends KinematicBody

onready var mAnimationPlayer = $Trex/AnimationPlayer
onready var mTimer = $Timer

enum State { IDLE, WANDER }
var mState = State.IDLE

func _ready():
	mAnimationPlayer.get_animation("IdleTrack").loop = true
	mAnimationPlayer.play("IdleTrack")
	mTimer.start(randi()%5+1)

var count_coll = 0
func _on_Timer_timeout():
	count_coll = 0
	match mState:
		State.IDLE:
			pickUpNewRandTarget()
			mState = State.WANDER
			mTimer.start(randi()%10+7)
			mAnimationPlayer.get_animation("WalkTrack").loop = true
			mAnimationPlayer.play("WalkTrack")
		State.WANDER:
			mState = State.IDLE
			mTimer.start(randi()%15+3)
			mAnimationPlayer.get_animation("IdleTrack").loop = true
			mAnimationPlayer.play("IdleTrack")

export(float) var gravity = -5
var target = Vector3.ZERO
export(float) var speed = 1.0
func _physics_process(delta):
	if mState == State.WANDER:
		var v = (target - self.global_transform.origin).normalized()
		v.y = gravity
		smoothLookAtTarget()
		var slide_vec = move_and_slide(v*speed, Vector3(0.0, 1.0, 0.0), false, 4) # TODO: change by move_and_slide and handle the output
		if is_on_wall():
			count_coll += 1
			# Turn to avoid colliding again
			pickUpNormalTarget()
			if count_coll > 20:
				mState = State.IDLE
				mAnimationPlayer.get_animation("IdleTrack").loop = true
				mAnimationPlayer.play("IdleTrack")
				mTimer.start(5)

func pickUpNormalTarget():
	for i in range(get_slide_count()):
		var col = get_slide_collision(i)
		#print("col.remainder ", col.remainder) # TODO: play animation if this is too big
		if count_coll > 7:
			target = self.global_transform.origin + col.normal*speed*20
		else: # if we are stuck let's try this
			target = self.global_transform.origin + (self.global_transform.origin-col.position).normalized()*speed*20
			
		target.y = self.global_transform.origin.y

func smoothLookAtTarget():
	var targetTransform = global_transform.looking_at(target, Vector3(0.0, 1.0, 0.0))
	self.global_transform = self.global_transform.interpolate_with(targetTransform, 0.1)

func pickUpNewRandTarget():
	target = Vector3(randi()%40-10, 0.0, randi()%40-10)
	target += self.global_transform.origin

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
		pickUpNewRandTarget()
