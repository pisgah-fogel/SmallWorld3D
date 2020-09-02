/*
This shader gives a cartoon effect.
Steps ares:
	- Convert to black and white
	- Sobel (2 kernel convolutions and square root of the 2 results)
	- Threshold
	- Multiply with the original color
	- Contrast/Brightness/Saturation
*/

shader_type canvas_item;

uniform float thr_min = 0.4f;
uniform float thr_max = 1.0f;

uniform float brightness = 1.0;
uniform float contrast = 1.1;
uniform float saturation = 1.1;

float bw(vec4 orig) {
	float avg = (orig.r + orig.g + orig.b) / 3f;
	return avg;
}

void fragment() {
	mat3 bloc;
	
	vec4 orig = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	bloc[0][0] = bw(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-1f, -1f)*SCREEN_PIXEL_SIZE));
	bloc[1][0] = bw(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0f, -1f)*SCREEN_PIXEL_SIZE));
	bloc[2][0] = bw(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(1f, -1f)*SCREEN_PIXEL_SIZE));
	
	bloc[0][1] = bw(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-1f, 0f)*SCREEN_PIXEL_SIZE));
	bloc[1][1] = bw(orig);
	bloc[2][1] = bw(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(1f, 0f)*SCREEN_PIXEL_SIZE));
	
	bloc[0][2] = bw(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-1f, 1f)*SCREEN_PIXEL_SIZE));
	bloc[1][2] = bw(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0f, 1f)*SCREEN_PIXEL_SIZE));
	bloc[2][2] = bw(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(1f, 1f)*SCREEN_PIXEL_SIZE));

	mat3 xkernel = mat3(
		vec3(1.0, 2.0, 1.0),
		vec3(0.0, 0.0, 0.0),
		vec3(-1.0, -2.0, -1.0)
	);
	mat3 ykernel = mat3(
		vec3(1.0, 0.0, -1.0),
		vec3(2.0, 0.0, -2.0),
		vec3(1.0, 0.0, -1.0)
	);
	float a = dot(xkernel[0], bloc[0]) + dot(xkernel[1], bloc[1]) + dot(xkernel[2], bloc[2]);
	float b = dot(ykernel[0], bloc[0]) + dot(ykernel[1], bloc[1]) + dot(ykernel[2], bloc[2]);
	float pix = sqrt(pow(a, 2.0)) + sqrt(pow(b, 2.0));
	pix = 1.f - pix;
	
	if (pix < thr_min)
		pix = 0f;
	else if (pix > thr_max)
		pix = 1f;
	
	orig.rgb = mix(vec3(0.0), orig.rgb, brightness);
    orig.rgb = mix(vec3(0.5), orig.rgb, contrast);
    orig.rgb = mix(vec3(dot(vec3(1.0), orig.rgb) * 0.33333), orig.rgb, saturation);
	
	COLOR = vec4(orig.rgb*pix, 1f);
}
