shader_type spatial;

render_mode blend_mix, unshaded, cull_disabled, depth_draw_never;

uniform vec4 particle_color : source_color = vec4(0.33, 0.75, 1.0, 0.68);
uniform float edge_softness : hint_range(0.01, 0.5) = 0.18;

void fragment() {
	vec2 centered_uv = UV * 2.0 - 1.0;
	vec2 droplet_shape = vec2(centered_uv.x * 1.35, centered_uv.y);
	float distance_from_center = length(droplet_shape);
	float soft_alpha = 1.0 - smoothstep(
		1.0 - edge_softness,
		1.0,
		distance_from_center
	);

	ALBEDO = particle_color.rgb;
	ALPHA = particle_color.a * soft_alpha;
}
