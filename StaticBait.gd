extends StaticBody

signal fishCatched(fish)
signal baitEaten(fish)

onready var mParticles = $Particles

var isEaten = false

# User was unlucky or too late, fish have eaten the bait
func baitEatenByFish(fish):
	if not isEaten:
		isEaten = true
		print("Bait eaten by fish")
		emit_signal("baitEaten", fish)

# User catched a fish
func catchAFish(fish):
	if not isEaten:
		isEaten = true
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
