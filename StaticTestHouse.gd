extends StaticBody

func _on_Area_body_entered(body):
	print("Teleport to inside the house")
	
	var level = get_tree().get_root().get_node("TestScene")
	level.loadScene("res://TestHouse.tscn")
	# TODO: use a splash screen to hide the teleportation
