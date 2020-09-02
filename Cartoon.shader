/*
shader_type canvas_item;
//render_mode unshaded;

uniform float threshold : hint_range(0.0, 1.0) = 0.9;

vec3 applyRGB(mat3 op, samplerCube screenT, vec3 screenUV) {
	mat3 Ir;
	mat3 Ig;
	mat3 Ib;
	Ir[0][0] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y) - 1f)).r;
	Ir[0][1] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y))).r;
	Ir[0][2] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y) + 1f)).r;
	Ir[1][0] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y) - 1f)).r;
	Ir[1][1] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y))).r;
	Ir[1][2] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y) + 1f)).r;
	Ir[2][0] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y) - 1f)).r;
	Ir[2][1] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y))).r;
	Ir[2][2] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y) + 1f)).r;
	
	Ig[0][0] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y) - 1f)).g;
	Ig[0][1] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y))).g;
	Ig[0][2] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y) + 1f)).g;
	Ig[1][0] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y) - 1f)).g;
	Ig[1][1] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y))).g;
	Ig[1][2] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y) + 1f)).g;
	Ig[2][0] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y) - 1f)).g;
	Ig[2][1] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y))).g;
	Ig[2][2] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y) + 1f)).g;
	
	Ib[0][0] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y) - 1f)).b;
	Ib[0][1] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y))).b;
	Ib[0][2] = texture(screenT, vec2(float(screenUV.x) - 1f, float(screenUV.y) + 1f)).b;
	Ib[1][0] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y) - 1f)).b;
	Ib[1][1] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y))).b;
	Ib[1][2] = texture(screenT, vec2(float(screenUV.x), float(screenUV.y) + 1f)).b;
	Ib[2][0] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y) - 1f)).b;
	Ib[2][1] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y))).b;
	Ib[2][2] = texture(screenT, vec2(float(screenUV.x) + 1f, float(screenUV.y) + 1f)).b;

	float r = dot(op[0], Ir[0]) + dot(op[1], Ir[1]) + dot(op[2], Ir[2]);
	float g = dot(op[0], Ig[0]) + dot(op[1], Ig[1]) + dot(op[2], Ig[2]);
	float b = dot(op[0], Ib[0]) + dot(op[1], Ib[1]) + dot(op[2], Ib[2]);
	return vec3(r, g, b);
}

void fragment()
{
	//vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);
	mat3 op = mat3(vec3(1.0, 2.0, 1.0), vec3(0.0, 1.0, 0.0), vec3(-1.0, -2.0, -1.0));
	vec3 v = applyRGB( op, SCREEN_TEXTURE, SCREEN_UV)
	COLOR = vec4(v, 1f);
	
}
*/


shader_type canvas_item;

uniform float brightness = 1.0;
uniform float contrast = 1.1;
uniform float saturation = 1.1;

void fragment() {
    vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;

    c.rgb = mix(vec3(0.0), c.rgb, brightness);
    c.rgb = mix(vec3(0.5), c.rgb, contrast);
    c.rgb = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, saturation);

    COLOR.rgb = c;
}

/*
shader_type spatial;
void fragment() {
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
    float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	
	ALBEDO = vec3(0.f, 0f, 0f);
}*/