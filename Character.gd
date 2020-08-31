extends KinematicBody

export var speed = 200
export var gravity = 600
export var max_inventory = 5*2
export var fishing_distance = 5
export (float) var high_caught_fish = 3
var velocity = Vector2(0, 0)

onready var mMesh = $Robot
onready var mAnimationPlayer = $Robot/AnimationPlayer
var mCollisionShape = null
onready var mTimer = $Timer

enum State {MOVE, ACTION, INVENTORY, FISHING, GOTFISH}
var mState = State.MOVE
var Item = preload("res://Item.gd")

var objectList = []
class Wallet:
	var money:int = 0
var mWallet = Wallet.new()

func _ready():
	var ActionCollision = load("res://ActionCollision.tscn")
	var mActionCollision = ActionCollision.instance()
	mCollisionShape = mActionCollision.get_node("CollisionShape")
	mMesh.add_child(mActionCollision)
	mAnimationPlayer.connect("animation_finished", self, "_end_animation")
	mAnimationPlayer.playback_speed = 2
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

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
		State.FISHING:
			state_fishing(delta)
		State.GOTFISH:
			state_gotFish(delta)

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
				if objectList.size() > 0 and objectList[0] != null and objectList[0].id == Item._id.ID_FISHINGROT:
					start_fishing()
				else:
					start_action()
			elif event.is_action_pressed("ui_inventory"):
				start_inventory()
			elif event.is_action_pressed("ui_cheat"):
				mWallet.money += 10
				if haveSpareSpace():
					var object = Item.new()
					#object.id = Item._id.ID_FISHINGROT
					object.id = randi()%20
					object.name = Item._name[object.id]
					object.data["quality"] = randi()%3;
					addObjectToInventory(object)
					print("User cheated")
			else:
				event_move(event)
		State.ACTION:
			pass
		State.INVENTORY:
			if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_inventory"):
				end_inventory()
		State.FISHING:
			event_fishing(event)

##################### FISHING  ########################
var mBait = null
var mFishingRot = null
func start_fishing():
	mState = State.FISHING
	reset_movements_and_picking()
	if mFishingRot == null:
		var FishingRot = load("res://gfx/FishingRot.glb")
		mFishingRot = FishingRot.instance()
		mMesh.add_child(mFishingRot)
	if mBait == null:
		var Bait = load("res://StaticBait.tscn")
		mBait = Bait.instance()
		mBait.translation = Vector3(fishing_distance*sin(mMesh.rotation.y), 0, fishing_distance*cos(mMesh.rotation.y))
		mBait.connect("fishCatched", self, "_fishCatched")
		mBait.connect("baitEaten", self, "_baitEaten")
		add_child(mBait)
	
func state_fishing(delta):
	pass

func event_fishing(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_inventory"):
		stop_fishing()
	# TODO: pull bait back if ui_action and frighten or catch...

func stop_fishing():
	if mBait:
		mBait.queue_free()
		mBait = null
	if mFishingRot:
		mFishingRot.queue_free()
		mFishingRot = null
	mState = State.MOVE

var newFish = null
func _fishCatched(fish):
	newFish = fish
	if mBait != null:
		mBait.queue_free()
		mBait = null
	newFish._show_yourself()
	# TODO: rotate to be pretty for the player
	start_gotFish()

func _baitEaten(fish):
	print("Player's bait eaten, start move state again")
	stop_fishing()

###################### GOTFISH ########################

func start_gotFish():
	mState = State.GOTFISH

func state_gotFish(delta):
	# TODO move the fish to the character
	if newFish != null:
		var fishGlobal = newFish.to_global(Vector3.ZERO)
		var trans = Vector3.ZERO
		if fishGlobal.y < translation.y + high_caught_fish:
			trans.y = 0.1
		else:
			trans = (translation - fishGlobal).normalized()
			trans.y = 0
		newFish.global_translate(trans*delta*10.0)
		if Vector2(fishGlobal.x, fishGlobal.z).distance_to(Vector2(translation.x, translation.z)) < 1:
			stop_gotFish()
			print("Fish ", fishGlobal.x, " ", fishGlobal.z)
			print("Me ", translation.x, " ", translation.y)
	else:
		stop_gotFish()

func stop_gotFish():
	if newFish != null:
		print("Player catched ", newFish.mItem.name)
		if haveSpareSpace():
			addObjectToInventory(newFish.mItem)
		else:
			print("Inventory is full")
			# TODO handle full inventory
		newFish.queue_free()
		newFish = null
	stop_fishing() #Free bait & start_move()

################## INVENTORY STATE ####################
const Inventory = preload("res://Inventory.tscn")
var inventoryInstance = null
func start_inventory():
	# TODO: play inventory animation
	mState = State.INVENTORY
	reset_movements_and_picking()
	openInventory(null)

func openInventory(chest):
	# Open inventory
	# TODO: play IDLE animation and loop
	clear_null_inventory()
	inventoryInstance = Inventory.instance()
	if inventoryInstance.has_method("setUserWallet"):
		inventoryInstance.setUserWallet(mWallet)
	if chest and chest.has_method("setUserWallet"):
		chest.setUserWallet(mWallet)
	inventoryInstance.setInventoryList(objectList)
	inventoryInstance.setChest(chest)
	add_child(inventoryInstance)

func end_inventory():
	mState = State.MOVE
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if inventoryInstance != null:
		if inventoryInstance.mChest != null:
			inventoryInstance.mChest.closeChest()
		inventoryInstance.queue_free()

func _on_chestOpenned(chest):
	mState = State.INVENTORY
	reset_movements_and_picking()
	openInventory(chest)

func clear_null_inventory():
	while objectList.size() > 0 and objectList[objectList.size()-1] == null:
		objectList.pop_back()

func receiveObject(object, giver):
	print("Player received ", object.name)
	if haveSpareSpace():
		giver.canRemoveObject(object)
		addObjectToInventory(object)
	else:
		# TODO handle inventory full
		giver.canRemoveObject(object)
		print("Inventory is full")

func haveSpareSpace():
	var count = 0
	for item in objectList:
		if item == null:
			count += 1
	return objectList.size()-count < max_inventory

func addObjectToInventory(object):
	for i in range(objectList.size()):
		if objectList[i] == null:
			objectList[i] = object
			return
	objectList.append(object)

################## ACTION STATE ####################

func start_action():
	mAnimationPlayer.play("DownTrack")
	mState = State.ACTION
	reset_movements_and_picking()
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

func reset_movements_and_picking():
	velocity = Vector2(0, 0)
	right_strength = 0.0
	left_strength = 0.0
	up_strength = 0.0
	down_strength = 0.0
	userControl = Vector2.ZERO
	mCollisionShape.disabled = true

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
