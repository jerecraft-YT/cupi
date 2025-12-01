// chromatic aberration FIXED
//---------------------------------
shader_type canvas_item;
render_mode blend_mix; // Remover unshaded si no es necesario

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

void fragment()
{
    // Usar SCREEN_UV directamente y aplicar desplazamiento en pixels
    vec2 r_uv = SCREEN_UV + (SCREEN_PIXEL_SIZE * r_displacement);
    vec2 g_uv = SCREEN_UV + (SCREEN_PIXEL_SIZE * g_displacement);
    vec2 b_uv = SCREEN_UV + (SCREEN_PIXEL_SIZE * b_displacement);

    // Obtener colores de la textura de pantalla
    float r = texture(SCREEN_TEXTURE, r_uv).r;
    float g = texture(SCREEN_TEXTURE, g_uv).g;
    float b = texture(SCREEN_TEXTURE, b_uv).b;

    // IMPORTANTE: Mantener el alpha del fondo original
    float original_alpha = texture(SCREEN_TEXTURE, SCREEN_UV).a;

    COLOR = vec4(r, g, b, original_alpha);
}