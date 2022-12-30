shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform sampler2D alpha_mask : source_color;
instance uniform vec3 current_color : source_color;

void fragment() {
	ALBEDO = current_color;
	ALPHA = texture(alpha_mask, UV).r;
}
