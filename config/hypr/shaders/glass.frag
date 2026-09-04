// Subtle vignette only. Chromatic aberration was tried and removed: the
// channel offset grows toward the edges, and on 4K text it reads as blur.
// A vignette only scales brightness, so it never resamples a pixel.
#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 px = texture(tex, v_texcoord);
    vec2 c = v_texcoord - 0.5;
    float r = dot(c, c);              // 0 centre .. 0.5 corner
    // Untouched inside ~60% radius, ~12% darker in the corners.
    float vig = 1.0 - smoothstep(0.18, 0.75, r) * 0.12;
    fragColor = vec4(px.rgb * vig, px.a);
}
