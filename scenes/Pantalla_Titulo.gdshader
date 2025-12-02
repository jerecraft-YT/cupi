shader_type canvas_item;

uniform sampler2D tex;      // La textura a mostrar
uniform vec2 panel_size;    // Tamaño del panel en píxeles

void fragment() {
    vec2 tex_size = vec2(textureSize(tex, 0));  // Tamaño de la textura
    float tex_ratio = tex_size.x / tex_size.y;
    float panel_ratio = panel_size.x / panel_size.y;

    vec2 uv = UV;
    vec2 scale = vec2(1.0);

    if (tex_ratio > panel_ratio) {
        // La textura es más ancha que el panel
        scale.y = panel_ratio / tex_ratio;
        uv.y = (uv.y - 0.5) * scale.y + 0.5;
    } else {
        // La textura es más alta que el panel
        scale.x = tex_ratio / panel_ratio;
        uv.x = (uv.x - 0.5) * scale.x + 0.5;
    }

    // Mostrar la textura, fuera de los bordes queda negro (opcional)
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // fondo negro
    } else {
        COLOR = texture(tex, uv);
    }
}
