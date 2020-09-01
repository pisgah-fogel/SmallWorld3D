extends StaticBody

signal fishCatched(fish)
signal baitEaten(fish)

onready var mParticles = $Particles

func baitEatenByFish(fish):
	print("Bait eaten by fish")
	emit_signal("baitEaten", fish)

func catchAFish(fish):
	print("catchAFish")
	emit_signal("fishCatched", fish)

func tasting():
	# TODO: play "taste" animation or VFX
	mParticles.emitting = true
	mParticles.one_shot = true
	mParticles.amount = 1
	print("Tasting bait")

func beating():
	# TODO: play "beaten" animation or VFX
	mParticles.emitting = true
	mParticles.one_shot = false
	mParticles.amount = 3
	print("beating bait")
