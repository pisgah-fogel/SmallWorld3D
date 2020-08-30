extends StaticBody

signal fishCatched(fish)
signal baitEaten(fish)

func baitEatenByFish(fish):
	emit_signal("baitEaten", fish)

func catchAFish(fish):
	emit_signal("fishCatched", fish)

func tasting():
	# TODO: play "taste" animation or VFX
	pass

func beating():
	# TODO: play "beaten" animation or VFX
	pass
