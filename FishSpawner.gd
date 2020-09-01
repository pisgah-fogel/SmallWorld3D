extends Spatial

onready var mPoint1 = $Point1
onready var mPoint2 = $Point2
onready var mTimer = $Timer

var spawner_zone = Rect2(-23,-24,5,23+18)

export (int) var number_fishes = 4
export (int) var timer = 10
export (int) var spawner_probability = 70
export (bool) var fill = true

const SpatialFish = preload("res://SpatialFish.tscn")
const Item = preload("res://Item.gd")

var count_fishes = 0
func _ready():
	spawner_zone.position.x = min(mPoint1.translation.x, mPoint2.translation.x)
	spawner_zone.position.y = min(mPoint1.translation.z, mPoint2.translation.z)
	spawner_zone.size.x = max(mPoint1.translation.x, mPoint2.translation.x) - spawner_zone.position.x
	spawner_zone.size.y = max(mPoint1.translation.z, mPoint2.translation.z) - spawner_zone.position.y
	mTimer.set_one_shot(true)
	mTimer.start(timer)

func spawn_fish():
	if count_fishes >= number_fishes:
		return
	var tmp = SpatialFish.instance()
	tmp.spawner_zone = spawner_zone
	
	var item = Item.new()
	var r = randi() % 100
	if r > 50:
		item.id = Item._id.ID_TURTLE
	else:
		item.id = Item._id.ID_FISH
	
	item.name = Item._name[item.id]
	item.data["size"] = randi()%5+6
	tmp.setFishType(item)
	add_child(tmp)
	tmp.connect("tree_exiting", self, "_fish_killed")
	count_fishes += 1
	if count_fishes < number_fishes:
		mTimer.start(timer)

func _fish_killed():
	count_fishes -= 1
	mTimer.start(timer)

func _on_Timer_timeout():
	var r = randi() % 100
	if r < spawner_probability:
		spawn_fish()
	elif fill:
		mTimer.start(timer)
