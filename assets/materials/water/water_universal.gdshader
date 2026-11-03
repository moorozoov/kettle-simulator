shader_type spatial;

render_mode blend_mix, depth_prepass_alpha, cull_disabled,
	diffuse_burley, specular_schlick_ggx;

uniform vec4 water_color : source_color = vec4(0.12, 0.55, 0.82, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 0.48;
uniform float roughness : hint_range(0.0, 1.0) = 0.08;
uniform float wave_scale : hint_range(0.1, 20.0) = 4.0;
uniform float wave_speed : hint_range(0.0, 2.0) = 0.18;
uniform float normal_strength : hint_range(0.0, 2.0) = 0.35;
uniform float brightness_variation : hint_range(0.0, 0.5) = 0.08;
uniform sampler2D noise_texture : repeat_enable, filter_linear_mipmap_anisotropic;

void fragment() {
	vec2 uv_a = UV * wave_scale + vec2(TIME * wave_speed, TIME * wave_speed * 0.37);
	vec2 uv_b = UV * wave_scale * 1.41 + vec2(-TIME * wave_speed * 0.53, TIME * wave_speed * 0.71);

	float noise_a = texture(noise_texture, uv_a).r;
	float noise_b = texture(noise_texture, uv_b).r;
	float waves = (noise_a + noise_b) * 0.5;

	vec2 offset = vec2(0.012, 0.0);
	float height_left = texture(noise_texture, uv_a - offset).r;
	float height_right = texture(noise_texture, uv_a + offset).r;
	float height_down = texture(noise_texture, uv_a - offset.yx).r;
	float height_up = texture(noise_texture, uv_a + offset.yx).r;

	float normal_x = (height_left - height_right) * normal_strength;
	float normal_y = (height_down - height_up) * normal_strength;

	NORMAL_MAP = vec3(
		0.5 + normal_x,
		0.5 + normal_y,
		1.0
	);
	NORMAL_MAP_DEPTH = normal_strength;

	float brightness = 1.0 + (waves - 0.5) * brightness_variation;
	ALBEDO = water_color.rgb * brightness;
	METALLIC = 0.0;
	ROUGHNESS = roughness;
	SPECULAR = 0.9;
	ALPHA = clamp(opacity + (waves - 0.5) * 0.08, 0.0, 1.0);
}
