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

float sdRoundRect(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + vec2(r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 p = fragCoord - (u_size * 0.5);
    vec2 boxSize = u_size * 0.5;
    
    // Outer Box SDF
    float dOuterBox = sdRoundRect(p, boxSize, u_radius);
    
    // Cutout SDF
    float dCutout = 10000.0;
    if (u_cutout_type > 0.5 && u_cutout_type < 1.5) { // Notch
        vec2 notchSize = vec2(80.0, 15.0);
        vec2 notchCenter = vec2(0.0, -boxSize.y + notchSize.y);
        dCutout = sdRoundRect(p - notchCenter, notchSize, 12.0);
    } else if (u_cutout_type > 1.5 && u_cutout_type < 2.5) { // Hole
        vec2 holeCenter = vec2(0.0, -boxSize.y + 40.0);
        dCutout = length(p - holeCenter) - 18.0;
    }
    
    // Combine bounding box and cutout for outer edge
    float dOuter = max(dOuterBox, -dCutout);
    
    // Inner Box SDF
    float innerR = max(u_radius - u_thickness, 0.0);
    vec2 innerBoxSize = max(boxSize - vec2(u_thickness), vec2(0.0));
    float dInnerBox = sdRoundRect(p, innerBoxSize, innerR);
    
    // Combine inner bounding box and inner cutout
    float dCutoutInner = dCutout - u_thickness;
    float dInner = max(dInnerBox, -dCutoutInner);
    
    float sm = 1.0; 
    float outerMask = smoothstep(sm, -sm, dOuter);
    float innerMask = smoothstep(sm, -sm, dInner);
    
    float borderMask = outerMask - innerMask;

    if (u_is_snake_mode > 0.5) {
        float angle = atan(p.y, p.x);
        float normalizedAngle = (angle / 3.14159265359) * 0.5 + 0.5;
        float snakePos = fract(u_time * 0.2);
        float distToSnake = fract(normalizedAngle - snakePos);
        
        if (distToSnake > u_snake_length) {
            borderMask = 0.0;
        } else if (distToSnake < 0.05) {
            // Pulse the head of the snake
            float pulse = (sin(u_time * 8.0) * 0.5 + 0.5) * 0.5 + 0.5; // 0.5 to 1.0
            borderMask *= pulse * 1.5;
        } else {
            // Add a smooth tail fade for "Glow" effect
            borderMask *= smoothstep(0.0, 0.08, distToSnake);
        }
    }
    
    if (borderMask <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }
    
    float angle = atan(p.y, p.x);
    float t = angle + u_time * 2.0; 
    
    float mixVal = sin(t) * 0.5 + 0.5;
    vec4 color = mix(u_color1, u_color2, mixVal);
    
    fragColor = vec4(color.rgb * color.a * borderMask, color.a * borderMask);
}
