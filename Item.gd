extends Resource

class_name Item

const _id = {
    ID_VOID = 0,
    ID_GRASS = 1,
    ID_GRASS2 = 2,
	ID_GRASS3 = 3,
	ID_GRASS4 = 4,
	ID_TURTLE = 5,
	ID_FISH = 6
}

const _name = [
    "Nothing",
    "Small plant",
    "Green plant",
	"Yellow plant",
	"Red plant",
	"Turtle",
	"Blue Fish"
]

export var id: int = 0
export var name: String = ''
export var data: Dictionary = {}
