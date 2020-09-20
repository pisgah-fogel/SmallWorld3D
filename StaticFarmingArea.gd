extends StaticBody

var unique_id = -1

var bornDate = 0 # Unix time date of birth

export var growing_speed = 60*3

onready var farmingArea = $farmingArea

const bigPotatoPlant = preload("res://gfx/bigPotatoPlant.glb")
const smallPotatoPlant = preload("res://gfx/smallPotatoPlant.glb")

var plant = null

enum State {EMPTY = 0, SMALL = 1, BIG = 2}

var mState = State.EMPTY setget updateState

func makeUnique():
	unique_id += randi()%100000

func updateState(newState):
	if newState == mState:
		return
	if plant:
		plant.queue_free()
		plant = null
	mState = newState
	match newState:
		State.EMPTY:
			pass
		State.SMALL:
			plant = smallPotatoPlant.instance()
			# Copy material from the farming area
			var mat = farmingArea.get_node("FarminArea").get_surface_material(0)
			var mesh = plant.get_node("SmallPotatoPlant")
			mesh.set_surface_material(0, mat)
			farmingArea.add_child(plant)
		State.BIG:
			plant = bigPotatoPlant.instance()
			# Copy material from the farming area
			var mat = farmingArea.get_node("FarminArea").get_surface_material(0)
			var mesh = plant.get_node("BigPotatoPlant")
			mesh.set_surface_material(0, mat)
			farmingArea.add_child(plant)

func _ready():
	bornDate = OS.get_unix_time()
	

func save(save_game: Resource):
	if unique_id != -1:
		save_game.data["StaticFarmingArea_"+str(unique_id)+"_date"] = bornDate
		save_game.data["StaticFarmingArea_"+str(unique_id)+"_state"] = mState

func load(save_game: Resource):
	assert (unique_id != -1)
	if unique_id != -1:
		if "StaticFarmingArea_"+str(unique_id)+"_date" in save_game.data:
			bornDate = save_game.data["StaticFarmingArea_"+str(unique_id)+"_date"]
		if "StaticFarmingArea_"+str(unique_id)+"_state" in save_game.data:
			var tmp = save_game.data["StaticFarmingArea_"+str(unique_id)+"_state"]
			updateState(tmp)

func _on_Area_body_entered(body):
	if mState == State.EMPTY:
		var tmp = body.get_parent().get_parent()
		var item = tmp.getTool()
		print("Player tried to plant ", item.id," ", item.name)
		if Item.isSeed(item): # TODO: implement different kind of plants
			updateState(State.SMALL)
			bornDate = OS.get_unix_time()
			tmp.removeTool()
		
	if mState == State.BIG:
		var current_time = OS.get_unix_time()
		print("Player is harvesting ", current_time - bornDate, "s old plant")
		bornDate = current_time
		updateState(State.EMPTY)
		var item = Item.new()
		item.id = Item._id.ID_GREENMELON
		item.name = Item._name[item.id]
		item.data["quality"] = randi()%3
		body.get_parent().get_parent().receiveObject(item, self)

func _on_Timer_timeout():
	var current_time = OS.get_unix_time()
	if current_time - bornDate > growing_speed:
		if mState == State.SMALL:
			bornDate = current_time
			updateState(State.BIG)
