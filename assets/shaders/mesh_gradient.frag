#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform float u_time;
uniform vec4 u_color1;
uniform vec4 u_color2;

out vec4 fragColor;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / u_size;
    
    // Slow moving blobs
    float t = u_time * 0.15;
    
    vec2 p1 = vec2(sin(t * 0.7), cos(t * 0.5)) * 0.5 + 0.5;
    vec2 p2 = vec2(cos(t * 0.3), sin(t * 0.8)) * 0.5 + 0.5;
    vec2 p3 = vec2(sin(t * 1.1 + 1.0), cos(t * 0.9 + 2.0)) * 0.5 + 0.5;
    
    float d1 = 1.0 - smoothstep(0.0, 0.8, distance(uv, p1));
    float d2 = 1.0 - smoothstep(0.0, 0.8, distance(uv, p2));
    float d3 = 1.0 - smoothstep(0.0, 0.8, distance(uv, p3));
    
    // Mix colors with a deep black base
    vec3 base = vec3(0.02, 0.02, 0.04); // Deep Midnight
    vec3 col = base;
    
    col = mix(col, u_color1.rgb, d1 * 0.15); // Subtle 15% opacity blobs
    col = mix(col, u_color2.rgb, d2 * 0.15);
    col = mix(col, vec3(0.1, 0.1, 0.2), d3 * 0.05); // Highlight blob
    
    // Add very faint noise for texture
    col += (noise(uv * 100.0 + u_time * 0.5) - 0.5) * 0.01;
    
    fragColor = vec4(col, 1.0);
}
