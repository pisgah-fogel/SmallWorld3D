extends StaticBody

var active = false
export(String, FILE, "*.shader") var shaderPath = "res://GrayScale.shader"

func _on_Area_body_entered(body):
	if get_tree().get_root().get_node("TestScene").getActiveShaderFilename() != shaderPath:
		get_tree().get_root().get_node("TestScene").enableScreenShader(shaderPath)
		active = true
		print("Set shader active")
	else:
		get_tree().get_root().get_node("TestScene").enableScreenShader(null)
		active = false
		print("Set shader inactive")
		