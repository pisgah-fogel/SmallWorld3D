extends KinematicBody

export var speed = 200
export var gravity = 600
export var max_inventory = 5*2
export var fishing_distance = 5
export (float) var high_caught_fish = 1
var velocity = Vector2(0, 0)

onready var mMesh = $Robot
onready var mAnimationPlayer = $Robot/AnimationPlayer
var mCollisionShape = null
onready var mTimer = $Timer

enum State {MOVE, ACTION, INVENTORY, FISHING, GOTFISH}
var mState = State.MOVE
var Item = preload("res://Item.gd")
const ActionCollision = preload("res://ActionCollision.tscn")
const FishingRot = preload("res://gfx/FishingRot.glb")
const Bait = preload("res://StaticBait.tscn")

var objectList = []
class Wallet:
	var money:int = 0
var mWallet = Wallet.new()

func _ready():
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
		State.FISHING:
			state_fishing(delta)
		State.ACTION:
			pass # Wait for animation to finish

func _process(delta):
	match mState:
		State.MOVE:
			pass
		State.ACTION:
			pass
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

var is_dropping: bool = false
const DropPlacement = preload("res://DropPlacement.tscn")
const Drop = preload("res://Drop.tscn")
var mDropPlacement = null
var dropping_col_count = 0
var toBeDropped = null
const BlueGhost = preload("res://BlueGhost.tres")
const RedGhost = preload("res://RedGhost.tres")
# This is a state inside MOVING state
func startDopping():
	is_dropping = true
	dropping_col_count = 0
	
	# TODO: enable dropping more things
	toBeDropped = Drop.instance()
	var object = Item.new()
	object.id = randi()%20
	object.name = Item._name[object.id]
	object.data["quality"] = randi()%3;
	toBeDropped.setItem(object)
	
	if not mDropPlacement:
		mDropPlacement = DropPlacement.instance()
		# TODO: set size according to drop object size
		var dropShape = toBeDropped.get_node("CollisionShape")
		if not dropShape:
			dropShape = toBeDropped.get_node("Area/CollisionShape")
		if dropShape:
			mDropPlacement.get_node("CollisionShape").shape = dropShape.shape
			var ptr = mDropPlacement.get_node("MeshInstance")
			ptr.mesh = toBeDropped.get_node("present/Cube").mesh
			ptr.set_surface_material(0, BlueGhost)
		else:
			print("Error: cannot find the collision shape of the object to be dropped")

		mDropPlacement.connect("body_entered", self, "dropping_body_entered")
		mDropPlacement.connect("body_exited", self, "dropping_body_exited")
		mMesh.add_child(mDropPlacement)

func canDropObject():
	return is_dropping and mDropPlacement and dropping_col_count == 0

func dropping_body_entered(body):
	mDropPlacement.get_node("MeshInstance").set_surface_material(0, RedGhost)
	dropping_col_count += 1

func dropping_body_exited(body):
	dropping_col_count -= 1
	if dropping_col_count == 0:
		mDropPlacement.get_node("MeshInstance").set_surface_material(0, BlueGhost)

func stopDopping():
	is_dropping = false
	dropping_col_count = 0
	if mDropPlacement:
		mDropPlacement.queue_free()
		mDropPlacement = null

func _unhandled_key_input(event):
	match mState:
		State.MOVE:
			if event.is_action_pressed("ui_action"):
				if canUseFishingRot():
					start_fishing()
				else:
					start_action()
			elif event.is_action_pressed("ui_inventory"):
				start_inventory()
			elif event.is_action_pressed("ui_cheat"):
				if is_dropping:
					if canDropObject() and toBeDropped:
						get_parent().add_child(toBeDropped)
						toBeDropped.global_transform.origin = mDropPlacement.get_node("MeshInstance").global_transform.origin
					elif toBeDropped:
						toBeDropped.queue_free() # abort drop and free object
					stopDopping()
				else:
					startDopping()
				mWallet.money += 10
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
func canUseFishingRot():
	return objectList.size() > 0 and objectList[0] != null and objectList[0].id == Item._id.ID_FISHINGROT

func equipeFishingRot():
	if mFishingRot == null:
		mFishingRot = FishingRot.instance()
		mMesh.add_child(mFishingRot)

var mBait = null
var mFishingRot = null
func start_fishing():
	mState = State.FISHING
	reset_movements_and_picking()
	equipeFishingRot() # Just to be sure
	if mBait == null:
		mBait = Bait.instance()
		
		# Local movement (relative to the player)
		mBait.translation = Vector3(fishing_distance*sin(mMesh.rotation.y), -1, fishing_distance*cos(mMesh.rotation.y))
		
		mBait.connect("fishCatched", self, "_fishCatched")
		mBait.connect("baitEaten", self, "_baitEaten")
		add_child(mBait)
	mFishingRot.get_node("AnimationPlayer").play("SwingTrack")
	
func state_fishing(delta):
	if bait_pulling_strength != 0:
		if mBait:
			# Move bait to the player (using global coordinate, in case of bait rotation...)
			var dir = (get_global_transform().origin - mBait.get_global_transform().origin).normalized()
			mBait.global_translate(dir*bait_pulling_strength*delta)
			if mBait.get_global_transform().origin.distance_to(get_global_transform().origin) < 1.5:
				stop_fishing()
		else:
			mState = State.MOVE

var bait_pulling_strength = 0
func event_fishing(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_inventory") or event.is_action_pressed("ui_right")\
		or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		stop_fishing()
		
	bait_pulling_strength = event.get_action_strength("ui_action")

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
	if newFish != null:
		# ToDo: make the fish jump out of the water
		var fishGlobal = newFish.global_transform.origin
		var targetGlobal = mMesh.global_transform.origin + Vector3(0, high_caught_fish, 0)
		var trans = (targetGlobal - fishGlobal).normalized()
		newFish.global_translate(trans*delta*5.0)
		if Vector2(fishGlobal.x, fishGlobal.z).distance_to(Vector2(targetGlobal.x, targetGlobal.z)) < 1:
			stop_gotFish()
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
	equipeItem()

func _on_chestOpenned(chest):
	mState = State.INVENTORY
	reset_movements_and_picking()
	openInventory(chest)

func clear_null_inventory():
	while objectList.size() > 0 and objectList[objectList.size()-1] == null:
		objectList.pop_back()

func receiveObject(object, giver):
	if haveSpareSpace():
		giver.canRemoveObject(object)
		addObjectToInventory(object)
		get_tree().get_root().get_node("TestScene").notify(object.name+" received")
	else:
		# TODO handle inventory full
		giver.canRemoveObject(object)
		get_tree().get_root().get_node("TestScene").notify("Inventory is full")

func haveSpareSpace():
	var count = 0
	for item in objectList:
		if item == null:
			count += 1
	return objectList.size()-count < max_inventory-1

func addObjectToInventory(object):
	for i in range(1, objectList.size()):
		if objectList[i] == null:
			objectList[i] = object
			return
	if objectList.size() == 0:
		objectList.append(null)
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
	# TODO: save in witch scene the character is
	save_game.data["character_objects"] = objectList
	save_game.data["character_money"] = mWallet.money

func load(save_game: Resource):
	self.global_transform = save_game.data["character_transform"]
	objectList = save_game.data["character_objects"]
	mWallet.money = save_game.data["character_money"]
	
	teleport_if_falls()
	equipeItem()

#####################  Utils ############################

func equipeItem():
	if canUseFishingRot():
		equipeFishingRot()
	elif mFishingRot:
		mFishingRot.queue_free()
		mFishingRot = null

func teleport_if_falls():
	if self.translation.y < -10:
		self.translation = Vector3(0, 20, 0)

func lerp_angle(from, to, weight):
    return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference
