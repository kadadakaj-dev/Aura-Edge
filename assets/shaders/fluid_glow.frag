#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform float u_time;
uniform float u_thickness;
uniform float u_radius;
uniform vec4 u_color1;
uniform vec4 u_color2;
uniform float u_cutout_type; // 0=Default, 1=Notch, 2=Hole, 3=Infinity
uniform float u_is_snake_mode;
uniform float u_snake_length;

out vec4 fragColor;

// SDF for rounded rectangle
float roundedBoxSDF(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + vec2(r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
}

void main() {
    vec2 p = FlutterFragCoord();
    vec2 center = u_size / 2.0;

    // Distance to screen borders
    vec2 boxSize = center - u_thickness / 2.0;
    float distToBorder = roundedBoxSDF(p - center, boxSize, u_radius);

    // Create the border mask
    float glowMask = smoothstep(u_thickness, 0.0, abs(distToBorder));
    glowMask = pow(glowMask, 2.5);

    if (glowMask < 0.05) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 uv = p / u_size;

    // Fluid / Water effect logic combined with green charging color
    // We animate y-axis based on time to simulate filling/rising or flowing liquid
    float wave1 = sin(uv.y * 10.0 - u_time * 3.0) * 0.5 + 0.5;
    float wave2 = cos(uv.x * 15.0 + u_time * 2.5) * 0.5 + 0.5;
    float fluidPattern = (wave1 + wave2) * 0.5;

    // Base Green (Charging) mixed with Cyan for dynamic liquid look
    // Even though color1 and color2 are provided, we force a charging green aesthetic here
    vec3 baseColor = vec3(0.0, 1.0, 0.3); // Bright neon green
    vec3 highlightColor = vec3(0.2, 1.0, 0.6); // Cyan-green highlight
    vec3 mixedColor = mix(baseColor, highlightColor, fluidPattern);

    // Increase brightness at the bottom to look like it's charging up
    float gradient = smoothstep(1.0, 0.0, uv.y);
    mixedColor += vec3(gradient * 0.3);

    fragColor = vec4(mixedColor * glowMask, glowMask);
}
