extends KinematicBody

class_name Character

export var speed = 200
export var gravity = 600
export var max_inventory = 5*2
export var fishing_distance = 5
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


func getTool():
	"""
	Return the item the player is holding (ID_VOID if nothing)
	"""
	if objectList.size():
		if objectList[0]:
			return objectList[0]
	var tmp = Item.new()
	tmp.id = Item._id.ID_VOID
	return tmp

func removeTool():
	"""
	Remove the item the player is currently holding
	"""
	if objectList.size():
		objectList[0] = null
		# TODO play sound

func _ready():
	var mActionCollision = ActionCollision.instance()
	mCollisionShape = mActionCollision.get_node("CollisionShape")
	mMesh.add_child(mActionCollision)
	mAnimationPlayer.connect("animation_finished", self, "_end_animation")
	mAnimationPlayer.playback_speed = 2
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func changeState(newstate):
	match mState:
		State.MOVE:
			exitMoveState()
		State.ACTION:
			exitActionState()
		State.INVENTORY:
			exitInventoryState()
		State.FISHING:
			exitFishingState()
		State.GOTFISH:
			exitGotFishState()
	mState = newstate
	match mState:
		State.MOVE:
			enterMoveState()
		State.ACTION:
			enterActionState()
		State.INVENTORY:
			enterInventoryState()
		State.FISHING:
			enterFishingState()
		State.GOTFISH:
			entergotfishState()

func _physics_process(delta):
	match mState:
		State.MOVE:
			state_move(delta)
		State.FISHING:
			state_fishing(delta)
		State.ACTION:
			pass # Wait for animation to finish

func _end_animation(_anim_name):
	match mState:
		State.MOVE:
			pass
		State.ACTION:
			changeState(State.MOVE)

func _on_Timer_timeout():
	match mState:
		State.MOVE:
			pass
		State.ACTION:
			pass

func _unhandled_key_input(event):
	match mState:
		State.MOVE:
			if event.is_action_pressed("ui_action"): # Fish, frop something or object specific action
				if is_dropping:
					dropSomethingIfPossible()
				elif canUseFishingRot():
					changeState(State.FISHING)
				elif canEnterDroppingWithoutCheating():
					startDoppingPresent()
				else:
					changeState(State.ACTION)
			elif event.is_action_pressed("ui_inventory"):
				changeState(State.INVENTORY)
			elif event.is_action_pressed("ui_cheat"):
				if not is_dropping:
					startDoppingPresent()
				mWallet.money += 500
			else:
				event_move(event)
		State.ACTION:
			pass
		State.INVENTORY:
			if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_inventory"):
				changeState(State.MOVE)
		State.FISHING:
			event_fishing(event)

################################# DROP something ###############################
# This can happen while we are in State.MOVE

var is_dropping: bool = false
const DropPlacement = preload("res://DropPlacement.tscn")
var mDropPlacement = null # Ghosty version of the item we what to drop so we can check for the placement
var dropping_col_count = 0
var toBeDropped = null
const BlueGhost = preload("res://BlueGhost.tres")
const RedGhost = preload("res://RedGhost.tres")
# This is a state inside MOVING state
func startDoppingPresent(cheating: bool = false):
	if not cheating:
		instanciateToBeDropped()
	else:
		toBeDropped = Drop.instance()
		var item = Item.new()
		item.randomItem()
		toBeDropped.setItem(item)
	
	is_dropping = true
	dropping_col_count = 0
	# TODO: enable dropping more things
	assert (toBeDropped != null)
	
	if not mDropPlacement:
		mDropPlacement = DropPlacement.instance()
		
		# TODO: add position offset according to objets' size
		#mDropPlacement.transform.origin = mMesh.transform.origin + Vector3(0, 0, 4)
		
		# TODO: Add rotation objects
		# TODO: Snap to ????
		
		# Make the drop placement shape matches the shape of the item we are trying to drop
		var dropPlacementShape = toBeDropped.get_node("CollisionShape")
		if not dropPlacementShape:
			dropPlacementShape = toBeDropped.get_node("Area/CollisionShape")
		if dropPlacementShape:
			mDropPlacement.get_node("CollisionShape").shape = dropPlacementShape.shape
			var ptr = mDropPlacement.get_node("MeshInstance")
			var buff = toBeDropped.get_node("present/Cube")
			if not buff:
				buff = toBeDropped.get_node("farmingArea/FarminArea")
			ptr.mesh = buff.mesh
			ptr.set_surface_material(0, BlueGhost)
		else:
			print("Error: cannot find the collision shape of the object to be dropped")

		mDropPlacement.connect("body_entered", self, "dropping_body_entered")
		mDropPlacement.connect("body_exited", self, "dropping_body_exited")
		mMesh.add_child(mDropPlacement)

func canDropObject():
	"""
	Returns true if we can drop the object (if we are in dropping state and there is no collision)
	"""
	return is_dropping and mDropPlacement and toBeDropped and dropping_col_count == 0

func dropping_body_entered(_body):
	"""
	New collision detected, do not allow drop
	"""
	mDropPlacement.get_node("MeshInstance").set_surface_material(0, RedGhost) # Set color to red
	dropping_col_count += 1

func dropping_body_exited(_body):
	"""
	Decrement the collision counter, if there is no more collision allow drop
	"""
	dropping_col_count -= 1
	if dropping_col_count < 0:
		dropping_col_count = 0 # Make sure the "dropping_body" does not spawn in a collision...
	if dropping_col_count == 0:
		mDropPlacement.get_node("MeshInstance").set_surface_material(0, BlueGhost) # Set color to Blue

func stopDropping(giveObjectBack: bool = false):
	"""
	Clears the dropping state
	"""
	if giveObjectBack:
		pass # TODO: Give the object back
	is_dropping = false
	dropping_col_count = 0
	if mDropPlacement:
		mDropPlacement.queue_free()
		mDropPlacement = null
	toBeDropped = null

const Drop = preload("res://Drop.tscn")
const StaticFarmingArea = preload("res://StaticFarmingArea.tscn")

func dropSomethingIfPossible():
	if canDropObject():
		# Place toBeDropped on map
		var buff = get_parent().mScene.get_node("CharDrops")
		if buff:
			buff.add_child(toBeDropped)
			toBeDropped.global_transform.origin = mDropPlacement.get_node("MeshInstance").global_transform.origin
			if toBeDropped.has_method("makeUnique"):
				toBeDropped.makeUnique()
			stopDropping()
		else:
			get_tree().get_root().get_node("TestScene").notify("You can't place stuff here")
			stopDropping(true)
		# TODO: add rotation or snap ???

func canEnterDroppingWithoutCheating() -> bool:
	"""
	Returns true if the character has something in his hand and this object cann be dropped
	"""
	return objectList.size() > 0 and objectList[0] != null and Item.canDrop(objectList[0])

func instanciateToBeDropped():
	"""
	Instanciate the object the player is holding so it can be dropped
	"""
	if toBeDropped == null:
		toBeDropped = StaticFarmingArea.instance()
		# TODO: instanciate objects to be dropped according to object type
		objectList[0] = null # TODO: Find a safer way to do it

######################### End of DROP

##################### FISHING  ########################
func canUseFishingRot():
	return objectList.size() > 0 and objectList[0] != null and Item.canGoFishingWith(objectList[0])

func equipeFishingRot():
	if mFishingRot == null:
		mFishingRot = FishingRot.instance()
		mMesh.add_child(mFishingRot)

var mBait = null
var mFishingRot = null
func enterFishingState():
	equipeFishingRot() # Just to be sure
	if mBait == null:
		mBait = Bait.instance()
		
		# Local movement (relative to the player)
		mBait.translation = Vector3(fishing_distance*sin(mMesh.rotation.y), -1, fishing_distance*cos(mMesh.rotation.y))
		
		mBait.connect("fishCatched", self, "_on_fishCatched")
		mBait.connect("baitEaten", self, "_on_baitEaten")
		add_child(mBait)
	mFishingRot.get_node("AnimationPlayer").play("SwingTrack")
	
func state_fishing(delta):
	if bait_pulling_strength != 0:
		if mBait:
			# Move bait to the player (using global coordinate, in case of bait rotation...)
			var dir = (get_global_transform().origin - mBait.get_global_transform().origin).normalized()
			mBait.global_translate(dir*bait_pulling_strength*delta)
			if mBait.get_global_transform().origin.distance_to(get_global_transform().origin) < 1.5:
				changeState(State.MOVE)
		else:
			changeState(State.MOVE)

var bait_pulling_strength = 0
func event_fishing(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_inventory") or event.is_action_pressed("ui_right")\
		or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		changeState(State.MOVE)
		
	bait_pulling_strength = event.get_action_strength("ui_action")

func exitFishingState():
	if mBait:
		mBait.queue_free()
		mBait = null
	if mFishingRot:
		mFishingRot.queue_free()
		mFishingRot = null

func _on_fishCatched(fish : Fish):
	if mBait != null:
		mBait.queue_free()
		mBait = null
	# TODO: rotate to be pretty for the player
	var _e = self.connect("translateFishToPlayer", fish, "_on_translateFishToPlayer")
	_e = fish.connect("translationDone", self, "_on_fish_translation_done")
	changeState(State.GOTFISH)

func _on_baitEaten(_fish : Fish):
	# TODO pause or ignore next fishing input
	print("Player's bait eaten, start move state again")
	changeState(State.MOVE)

###################### GOTFISH ########################
signal translateFishToPlayer(player_position)

func entergotfishState():
	print("Player: send signal to fish to show up")
	emit_signal("translateFishToPlayer", mMesh.global_transform.origin)

func _on_fish_translation_done(fish: Fish):
	print("Player: fish translation done")
	print("Player catched ", fish.mItem.name)
	if haveSpareSpace():
		addObjectToInventory(fish.mItem)
	else:
		print("Inventory is full")
		# TODO handle full inventory
		fish.queue_free()
	changeState(State.MOVE)

func exitGotFishState():
	pass

################## INVENTORY STATE ####################
const Inventory = preload("res://Inventory.tscn")
var inventoryInstance = null
func enterInventoryState():
	# TODO: play inventory animation
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

func exitInventoryState():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if inventoryInstance != null and is_instance_valid(inventoryInstance):
		if inventoryInstance.mChest != null:
			inventoryInstance.mChest.closeChest()
		inventoryInstance.queue_free()
	equipeItem()

func _on_chestOpenned(chest):
	changeState(State.INVENTORY)
	openInventory(chest)

func clear_null_inventory():
	while objectList.size() > 0 and objectList[objectList.size()-1] == null:
		objectList.pop_back()

func receiveObject(object, giver):
	if haveSpareSpace():
		if giver.has_method("canRemoveObject"):
			giver.canRemoveObject(object)
		addObjectToInventory(object)
		get_tree().get_root().get_node("TestScene").notify(object.name+" received")
	else:
		# TODO handle inventory full
		if giver.has_method("canRemoveObject"):
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

func enterActionState():
	mAnimationPlayer.play("DownTrack")
	mCollisionShape.disabled =false
	var _linear_velocity = self.move_and_slide(Vector3.ZERO) # Update physic collisions

func exitActionState():
	mCollisionShape.disabled = true

################## MOVE STATE ####################
func enterMoveState():
	pass

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
	var _linear_velocity = self.move_and_slide(Vector3(velocity.x, -gravity, velocity.y))
	teleport_if_falls()
	
	if velocity.length() < 1:
		mAnimationPlayer.play("IdleTrack")
	else:
		var target_angle = atan2(velocity.x, velocity.y)
		var buff = mMesh.get_rotation()
		buff.y = lerp_angle(buff.y, target_angle, 0.1)
		mMesh.set_rotation(buff)
		mAnimationPlayer.play("WalkTrack")

func exitMoveState():
	if is_dropping:
		stopDropping(true)
	reset_movements_and_picking()

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
