extends StaticBody

var active = false
export(String, FILE, "*.shader") var shaderPath = "res://GrayScale.shader"

func _on_Area_body_entered(body):
	if active:
		active = false
		print("Set shader inactive")
		get_tree().get_root().get_node("TestScene").enableScreenShader(null)
	else:
		active = true
		print("Set shader active")
		get_tree().get_root().get_node("TestScene").enableScreenShader(shaderPath)
