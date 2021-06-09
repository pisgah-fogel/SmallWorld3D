extends StaticBody

class_name Bait

signal fishCatched(fish)
signal baitEaten(fish)

onready var mParticles = $Particles

var isEaten = false

# User was unlucky or too late, fish have eaten the bait
func _on_bait_eaten(fish: Fish):
	if not isEaten:
		isEaten = true
		print("Bait eaten by fish")
		emit_signal("baitEaten", fish)

# User catched a fish
func _on_fish_caught(fish: Fish):
	if not isEaten:
		isEaten = true
		print("catchAFish")
		emit_signal("fishCatched", fish)

func _on_tasting():
	# TODO: play "taste" animation or VFX
	mParticles.emitting = true
	mParticles.one_shot = true
	mParticles.amount = 1
	print("Tasting bait")

func _on_beating():
	# TODO: play "beaten" animation or VFX
	mParticles.emitting = true
	mParticles.one_shot = false
	mParticles.amount = 3
	print("beating bait")
