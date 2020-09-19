"""
This node saves all it's childs
If the player add something on the map, add it as a child of this node.
"""

extends Node

var child_list = []
func loopListChild(node):
    for N in node.get_children():
		# TODO save rotation when rotating drops will be implemented
        child_list.append([N.filename, N.transform.origin])
        print("Drop saved ["+N.get_name()+"]")

func save(save_game: Resource):
	child_list.clear()
	loopListChild(self)
	save_game.data["CharDrops_list_1"] = child_list

func load(save_game: Resource):
	if "CharDrops_list_1" in save_game.data:
		child_list = save_game.data["CharDrops_list_1"]
		for child in child_list:
			var tmp = load(child[0])
			if tmp:
				var buffer = tmp.instance()
				buffer.transform.origin = child[1]
				add_child(buffer)
				print("CharDrops: ", child, " Loaded")
			else:
				print("Error: CharDrops: Failed to load ", child)
