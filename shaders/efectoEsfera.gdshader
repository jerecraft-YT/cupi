shader_type spatial;
//render_mode unshaded;
// Parámetros de forma
uniform float amplitude = 0.5;
uniform float frequency = 10.0;
uniform float sharpness = 2.5;
uniform float noise_strength = 0.15;

// Parámetros de material
uniform vec4 base_color : source_color = vec4(0.2, 0.4, 0.8, 1.0);
uniform float roughness = 0.6;
uniform float metallic = 0.1;

// Función de ruido mejorada
float hash(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

void vertex() {
    // Conservar la normal original de la esfera
    vec3 original_normal = normalize(NORMAL);
    vec3 sphere_pos = normalize(VERTEX);

    // Coordenadas para el patrón
    float theta = acos(sphere_pos.y);
    float phi = atan(sphere_pos.z, sphere_pos.x);

    // Patrón principal de picos
    float main_pattern = cos(frequency * theta) * sin(frequency * 0.7 * phi);

    // Ruido para variación orgánica
    float noise = hash(sphere_pos * 5.0) * noise_strength;

    // Combinar patrones
    float displacement = main_pattern + noise;

    // Aplicar curvatura no lineal para picos agudos
    displacement = pow(abs(displacement), sharpness) * sign(displacement) * amplitude;

    // Desplazar VERTEX a lo largo de la NORMAL original
    VERTEX += original_normal * displacement;

    // Actualizar normal para iluminación
    NORMAL = normalize(VERTEX);
}

void fragment() {
    ALBEDO = base_color.rgb;
    ROUGHNESS = roughness;
    METALLIC = metallic;
}