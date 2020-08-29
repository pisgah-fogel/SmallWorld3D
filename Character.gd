extends KinematicBody

export var speed = 200
export var gravity = 600
var velocity = Vector2(0, 0)

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

func _unhandled_key_input(event):
	match mState:
		State.MOVE:
			if event.is_action_pressed("ui_action"):
				start_action()
			else:
				event_move(event)
		State.ACTION:
			pass

################## ACTION STATE ####################

func start_action():
	mAnimationPlayer.play("DownTrack")
	mState = State.ACTION
	velocity = Vector2(0, 0)
	mCollisionShape.disabled =false
	self.move_and_slide(Vector3.ZERO) # Update physic collisions

func end_action():
	mState = State.MOVE
	mCollisionShape.disabled = true

################## MOVE STATE ####################
var right_strength = 0.0
var left_strength = 0.0
var up_strength = 0.0
var down_strength = 0.0
var userControl = Vector2.ZERO
func event_move(event):
	if event.is_action_pressed("ui_right"):
		right_strength = event.get_action_strength("ui_right")
	elif event.is_action_released("ui_right"):
		right_strength = 0.0
	
	if event.is_action_pressed("ui_left"):
		left_strength = event.get_action_strength("ui_left")
	elif event.is_action_released("ui_left"):
		left_strength = 0.0
	
	if event.is_action_pressed("ui_down"):
		down_strength = event.get_action_strength("ui_down")
	elif event.is_action_released("ui_down"):
		down_strength = 0.0
	
	if event.is_action_pressed("ui_up"):
		up_strength = event.get_action_strength("ui_up")
	elif event.is_action_released("ui_up"):
		up_strength = 0.0
	userControl.x = right_strength - left_strength
	userControl.y = down_strength - up_strength

func state_move(delta):
	velocity = velocity.linear_interpolate(userControl.normalized() * speed * delta, 0.2)
	self.move_and_slide(Vector3(velocity.x, -gravity, velocity.y))
	teleport_if_falls()
	
	if velocity.length() < 1:
		mAnimationPlayer.play("IdleTrack")
	else:
		var target_angle = atan2(velocity.x, velocity.y)
		var buff = mMesh.get_rotation()
		buff.y = lerp_angle(buff.y, target_angle, 0.1)
		mMesh.set_rotation(buff)
		mAnimationPlayer.play("WalkTrack")

##################### SAVING RESOURCES ########################

func save(save_game: Resource):
	save_game.data["character_transform"] = self.global_transform
	save_game.data["character_objects"] = objectList
	save_game.data["character_money"] = mWallet.money

func load(save_game: Resource):
	self.global_transform = save_game.data["character_transform"]
	objectList = save_game.data["character_objects"]
	mWallet.money = save_game.data["character_money"]
	
	teleport_if_falls()

#####################  Utils ############################

func teleport_if_falls():
	if self.translation.y < -10:
		self.translation = Vector3(0, 20, 0)

func lerp_angle(from, to, weight):
    return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference
