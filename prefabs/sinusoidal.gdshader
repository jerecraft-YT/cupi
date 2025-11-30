shader_type canvas_item;
render_mode blend_mix;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float speed = 5.0;
uniform float frequency = 60.0;
uniform float amplitude = 0.01;

void fragment() {
    // Efecto sinusoidal más simple y eficiente
    vec2 distorted_uv = SCREEN_UV;
    distorted_uv.x += sin(SCREEN_UV.y * frequency + TIME * speed) * amplitude*0.01;

    COLOR = texture(SCREEN_TEXTURE, distorted_uv);
}