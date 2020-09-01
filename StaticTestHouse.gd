extends StaticBody

func _on_Area_body_entered(body):
	print("Teleport to inside the house")
	var root = get_tree().get_root()
	
	# Remove the current level
	var level = root.get_node("TestScene/TestIsland")
	if not level:
		level = get_parent()
	
	if not level:
		print("Error: cannot free actual scene: staying in this one")
		return
	level.queue_free()
	
	# Add the next level
	var next_level_resource = load("res://TestHouse.tscn")
	var next_level = next_level_resource.instance()
	root.add_child(next_level)

	# TODO: use a splash screen to hide the teleportation
