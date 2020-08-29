extends KinematicBody

export var speed = 200
export var gravity = 600
var velocity = Vector3(0, 0, 0)

onready var mMesh = $Trex
onready var mAnimationPlayer = $Trex/AnimationPlayer

enum State {MOVE, ACTION}
var mState = State.MOVE

func _ready():
	mAnimationPlayer.connect("animation_finished", self, "_end_animation")
	mAnimationPlayer.playback_speed = 2 

func _physics_process(delta):
	match mState:
		State.MOVE:
			state_move(delta)
		State.ACTION:
			pass # Wait for animation to finish

func _end_animation(anim_name):
	match mState:
		State.MOVE:
			pass
		State.ACTION:
			mState = State.MOVE

################## MOVE STATE ####################

func state_move(delta):
	var moving = false
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = lerp(velocity.x, speed, 0.1)
		moving = true
	elif Input.is_action_pressed("ui_left"):
		velocity.x = lerp(velocity.x, -speed, 0.1)
		moving = true
	else:
		velocity.x = lerp(velocity.x, 0, 0.1)
		
	if Input.is_action_pressed("ui_up"):
		moving = true
		velocity.z = lerp(velocity.z, -speed, 0.1)
	elif Input.is_action_pressed("ui_down"):
		moving = true
		velocity.z = lerp(velocity.z, speed, 0.1)
	else:
		velocity.z = lerp(velocity.z, 0, 0.1)
	
	var vel = Vector2(velocity.x, velocity.z)
	if not moving:
		if Input.is_action_pressed("ui_action"):
			mAnimationPlayer.play("DownTrack")
			mState = State.ACTION
			velocity = Vector3(0, 0, 0)
			return
		else:
			mAnimationPlayer.play("IdleTrack")
	else:
		var target_angle = atan2(velocity.x, velocity.z)
		var buff = mMesh.get_rotation()
		buff.y = lerp_angle(buff.y, target_angle, 0.1)
		mMesh.set_rotation(buff)
		mAnimationPlayer.play("WalkTrack")
	
	velocity.y = -gravity # TODO: integrate
	self.move_and_slide(velocity*delta)

# Utils

func lerp_angle(from, to, weight):
    return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference
