shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
// Mantener los mismos uniforms
group_uniforms segments;
	uniform float segments: hint_range(2.0, 48.0, 1.0) = 6.0;
	uniform bool segmentReflect = true;
group_uniforms;
group_uniforms polar;
	uniform vec2 polarOffset = vec2(0.5, 0.5);
	uniform float polarAngle: hint_range(0.0, 360.0) = 0.0;
group_uniforms;
group_uniforms source;
	uniform vec2 sourceOffset = vec2(0.5, 0.5);
	uniform float sourceScale = 2.0;
	uniform float sourceAngle: hint_range(0.0, 360.0) = 0.0;
group_uniforms;

vec2 simpleRotate(vec2 uv, float rotation) {
    return vec2(
        cos(rotation) * uv.x + sin(rotation) * uv.y,
        cos(rotation) * uv.y - sin(rotation) * uv.x
    );
}

vec2 kaleid(vec2 uv, float addAngle, vec2 origin, float segCount, bool doReflect) {
	
	// Convert UV to polar coordinates.
	uv -= origin;
	float radius = sqrt(dot(uv, uv));
	float angle = atan(uv.y, uv.x) + addAngle;
	
	// Find the angle needed for each segments.
	// Then shift the angle so we repeat properly.
	float segmentAngle = TAU / segCount;
	angle -= segmentAngle * floor(angle / segmentAngle);
	
	// Reflect down the middle if specified to.
	if (doReflect) {
		angle = min(angle, segmentAngle - angle);
	}
	
	// Convert polar back to UV coordinates.
	return vec2(cos(angle), sin(angle)) * radius;
	
}

void fragment() {
	
	// USAR SCREEN_UV en lugar de UV para afectar al fondo
	vec2 screen_uv = SCREEN_UV;
	
	// Aplicar el efecto kaleidoscopio
	vec2 newUV = kaleid(screen_uv, radians(polarAngle), polarOffset, segments, segmentReflect);
	
	newUV = simpleRotate(newUV, radians(sourceAngle));
	newUV += sourceOffset;
	newUV *= sourceScale;
	
	// Leer de la textura de pantalla (SCREEN_TEXTURE)
	vec4 finalColor = texture(SCREEN_TEXTURE, fract(newUV));
	
	COLOR = finalColor;
	
}