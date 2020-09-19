extends StaticBody

var unique_id = -1

var bornDate = 0 # Unix time date of birth

func makeUnique():
	unique_id += randi()%100000

func _ready():
	bornDate = OS.get_unix_time()

func save(save_game: Resource):
	if unique_id != -1:
		save_game.data["StaticFarmingArea_"+str(unique_id)+"_date"] = bornDate
		print("Farming Area ", unique_id, " saving ", bornDate)

func load(save_game: Resource):
	if unique_id != -1 and "StaticFarmingArea_"+str(unique_id)+"_date" in save_game.data:
		bornDate = save_game.data["StaticFarmingArea_"+str(unique_id)+"_date"]
		print("Farming Area ", unique_id, " loaded ", bornDate)


func _on_Area_body_entered(body):
	var current_time = OS.get_unix_time()
	print("Player is harvesting ", current_time - bornDate, "s old plant")
	bornDate = current_time
	print("Reset plant")
