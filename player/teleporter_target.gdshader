shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo_texture : source_color;
instance uniform vec3 current_color : source_color;

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * current_color;
	ALPHA = texture(albedo_texture, UV).a;
}
