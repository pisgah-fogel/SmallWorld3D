extends KinematicBody

export var speed = 200
export var gravity = 600
var velocity = Vector3(0, 0, 0)

onready var mMesh = $Trex
onready var mAnimationPlayer = $Trex/AnimationPlayer
onready var mCollisionShape = $Trex/KinematicBody/CollisionShape
onready var mTimer = $Timer

enum State {MOVE, ACTION}
var mState = State.MOVE

var objectList = []
class Wallet:
	var money:int = 0
var mWallet = Wallet.new()

func _ready():
	mAnimationPlayer.connect("animation_finished", self, "_end_animation")
	mAnimationPlayer.playback_speed = 2 

func _physics_process(delta):
	match mState:
		State.MOVE:
			state_move(delta)
		State.ACTION:
			pass # Wait for animation to finish

func _process(delta):
	match mState:
		State.MOVE:
			pass
		State.ACTION:
			pass

func _end_animation(anim_name):
	match mState:
		State.MOVE:
			pass
		State.ACTION:
			end_action()

func _on_Timer_timeout():
	match mState:
		State.MOVE:
			pass
		State.ACTION:
			pass

################## ACTION STATE ####################

func start_action():
	mAnimationPlayer.play("DownTrack")
	mState = State.ACTION
	velocity = Vector3(0, 0, 0)
	mCollisionShape.disabled =false
	self.move_and_slide(Vector3.ZERO) # Update physic collisions

func end_action():
	mState = State.MOVE
	mCollisionShape.disabled = true

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
			start_action()
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

##################### SAVING RESOURCES ########################

func save(save_game: Resource):
	save_game.data["character_transform"] = self.global_transform
	save_game.data["character_objects"] = objectList
	save_game.data["character_money"] = mWallet.money

func load(save_game: Resource):
	self.global_transform = save_game.data["character_transform"]
	objectList = save_game.data["character_objects"]
	mWallet.money = save_game.data["character_money"]

#####################  Utils ############################

func lerp_angle(from, to, weight):
    return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference
