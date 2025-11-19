// this is a 2D CanvasItem shader
shader_type canvas_item;

uniform float top;
uniform float bottom = 1.0;

uniform float blob_threshold = 1.0;

uniform vec4 background_edge: hint_color = vec4(1.0, 0, 0.6, 1.0);
uniform vec4 background_center: hint_color = vec4(0.4, 0, 1.0, 0.4);

uniform vec4 blob_top: hint_color = vec4(1.0, 0.4, 0.4, 1.0);
uniform vec4 blob_bottom: hint_color = vec4(1.0, 1.0, 0.3, 1.0);

float oscillate(float x, float offset, float speed) {
	return pow(sin(speed * x + offset), 2) * (top - bottom) + bottom;
}

void fragment() {
	// color each fragment the Sprite covers according to the texture
	COLOR = texture(TEXTURE, UV);
	if (COLOR == vec4(1.0, 0.0, 1.0, 1.0)) {
		vec4 background_color_here = mix(background_center, background_edge, abs(0.5 - UV.x));
		COLOR = background_color_here;
		// declare the blob_centers as
		// a changing array of vec3s
		// with length 2 (2 elements)
		vec3 blob_centers[6];
		// define the blob centers
		// we start counting at 0
		blob_centers[0] = vec3(0.5, oscillate(TIME, 0.2, 0.2), 80.0);
		blob_centers[1] = vec3(0.4, oscillate(TIME, 0.5, 0.1), 60.0);
		blob_centers[2] = vec3(0.6, oscillate(TIME, 0.3, 0.3), 50.0);
		blob_centers[3] = vec3(0.4, oscillate(TIME, 0.1, 0.1), 30.0);
		blob_centers[4] = vec3(0.5, oscillate(TIME, 0.4, 0.1), 50.0);
		blob_centers[5] = vec3(0.6, oscillate(TIME, 0.3, 0.2), 30.0);
		// start counting influence at 0
		float influence = 0.0;
		// for each of the blobs, we add some influence based on how close
		// this point is to each blob
		for (int i = 0; i < blob_centers.length(); i++) {
			// TODO: explain each of these variables
			float distance_to_blob_center = distance(blob_centers[i].xy / TEXTURE_PIXEL_SIZE, UV / TEXTURE_PIXEL_SIZE);
			influence += blob_centers[i].z * (1.0 / distance_to_blob_center);
		}
		// if influence is larger than a certain threshold, set the color at this
		// point to the gradient
		COLOR = mix(background_color_here, mix(blob_top, blob_bottom, (UV.y - top) / (bottom - top)), pow(influence, 6));
		if (influence > blob_threshold) {
			COLOR = mix(blob_top, blob_bottom, (UV.y - top) / (bottom - top));
		}
	}
}
