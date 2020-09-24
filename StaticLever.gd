extends StaticBody

onready var mAnimationPlayer = $Lever/AnimationPlayer

var active = false
export(String, FILE, "*.shader") var shaderPath = "res://GrayScale.shader"

func desactivate():
	if active:
		active = false
		mAnimationPlayer.play("Off")

func _ready():
	mAnimationPlayer.play("Off")

func _on_Area_body_entered(body):
	if get_tree().get_root().get_node("TestScene").getActiveShaderFilename() != shaderPath:
		for lever in get_parent().get_children():
			if lever != self and lever.has_method("desactivate"):
				lever.desactivate()
		get_tree().get_root().get_node("TestScene").enableScreenShader(shaderPath)
		active = true
		mAnimationPlayer.play("On")
	else:
		get_tree().get_root().get_node("TestScene").enableScreenShader(null)
		desactivate()
		
