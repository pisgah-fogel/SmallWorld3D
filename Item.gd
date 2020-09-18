extends Resource

class_name Item

const _id = {
    ID_VOID = 0,
    ID_GRASS = 1,
    ID_GRASS2 = 2,
	ID_GRASS3 = 3,
	ID_GRASS4 = 4,
	ID_TURTLE = 5,
	ID_FISH = 6,
	ID_SEED_1 = 7,
	ID_SEED_2 = 8,
	ID_SEED_3 = 9,
	ID_SEED_4 = 10,
	ID_TURNIP = 11,
	ID_GREENMELON = 12,
	ID_YELLOWMELON = 13,
	ID_TOMATO = 14,
	ID_ORANGE = 15,
	ID_GRAPE = 16,
	ID_SUNFLOWER = 17,
	ID_STRAWBERRY = 18,
	ID_FISHINGROT = 19,
	ID_GARDEN = 20,
	ID_PRESENT = 21
}

const _name = [
    "Nothing",
    "Small plant",
    "Green plant",
	"Yellow plant",
	"Red plant",
	"Turtle",
	"Blue Fish",
	"seed",
	"seed",
	"seed",
	"seed",
	"Turnip",
	"Green Melon",
	"Yellow Melon",
	"Tomato",
	"Orange",
	"Grape",
	"Sunflower",
	"Strawberry",
	"FishingRot",
	"Garden",
	"Present"
]

export var id: int = 0
export var name: String = ''
export var data: Dictionary = {}

func randomItem():
	self.id = randi()%21
	self.name =_name[self.id]
	self.data["quality"] = randi()%3

static func canGoFishingWith(item):
	return item.id == _id.ID_FISHINGROT

static func canDrop(item):
	return item.id == _id.ID_GARDEN or item.id == _id.ID_PRESENT
