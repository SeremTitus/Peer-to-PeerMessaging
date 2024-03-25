shader_type canvas_item;

void fragment() {
    // Calculate distance from center of the circle
    vec2 center = vec2(0.5, 0.5); // Center of the circle
    float radius = 0.5; // Radius of the circle

    // Calculate distance from the center using UV coordinates
    float distance = distance(UV, center);

    // If the distance is greater than the radius, discard the fragment
    if (distance > radius) {
        discard;
    }

    // Output the color of the fragment
    vec4 color = texture(TEXTURE, UV);
    COLOR = color;
}
