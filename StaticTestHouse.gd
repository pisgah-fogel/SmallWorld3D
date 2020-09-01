extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	print("Teleport to inside the house")
	var root = get_tree().get_root()
	
	# Remove the current level
	var level = root.get_node("TestScene/TestIsland")
	level.queue_free()
	
	# Add the next level
	var next_level_resource = load("res://TestHouse.tscn")
	var next_level = next_level_resource.instance()
	root.add_child(next_level)

	var character = root.get_node("TestScene/Character")
	character.translation = Vector3(0, 0, 0)
	
	# TODO: check if it mess up with resources saving
	# TODO: use a splash screen to hide the teleportation
