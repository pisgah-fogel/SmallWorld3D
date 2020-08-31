extends StaticBody

signal fishCatched(fish)
signal baitEaten(fish)

func baitEatenByFish(fish):
	print("Bait eaten by fish")
	emit_signal("baitEaten", fish)

func catchAFish(fish):
	print("catchAFish")
	emit_signal("fishCatched", fish)

func tasting():
	# TODO: play "taste" animation or VFX
	print("Tasting bait")

func beating():
	# TODO: play "beaten" animation or VFX
	print("beating bait")
