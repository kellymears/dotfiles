// VT520 phosphor filter for Ghostty.
//
// What this fakes: beam fuzz, amber phosphor, faint scanlines, slight
// tube curvature, and slow-phosphor cursor ghosting.
//
// What it can't fake: true frame persistence (scroll smear). Ghostty
// custom shaders never receive the previous frame's texture, so decay
// of arbitrary old pixels is impossible. The cursor trail below is the
// one temporal ghost Ghostty exposes (via the cursor uniforms).

// ── knobs ─────────────────────────────────────────────────────────────
#define MONO 0            // 1 = crush everything to phosphor color, 0 = keep theme colors
#define PHOSPHOR vec3(1.00, 0.62, 0.18) // amber; green (0.30,1.00,0.35); DEC white (0.92,0.95,1.00)
#define FUZZ 0.35         // beam blur radius in px
#define BLOOM 0.40        // halo strength around bright glyphs
#define SCANLINE 0.10     // 0 = off
#define CURVE 0.006       // barrel distortion; 0 = flat
#define GHOST_DECAY 0.7   // cursor trail speed: lower = longer, lazier smear  <-- tune to taste
#define GHOST_GAIN 0.35   // trail brightness (kept low — cursor also picks up TEXT_GHOST smear)
#define GHOST_MIN_W 4.0   // trail half-thickness floor in px (underline cursor is only ~2px tall)
#define TEXT_GHOST 1      // 0 = off. Standing downward smear on all glyphs (fake persistence)
#define TEXT_GHOST_GAIN 0.30  // smear brightness
#define TEXT_GHOST_LEN 3.0    // px between smear taps; higher = longer drag
// ──────────────────────────────────────────────────────────────────────

float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// cursor uniforms: xy = top-left corner in px, already y-up like fragCoord; zw = size
vec2 cursorCenter(vec4 c) {
    return vec2(c.x + c.z * 0.5, c.y - c.w * 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;

    // tube curvature
    vec2 n = uv * 2.0 - 1.0;
    n *= 1.0 + CURVE * dot(n, n);
    vec2 cuv = n * 0.5 + 0.5;
    if (cuv.x < 0.0 || cuv.x > 1.0 || cuv.y < 0.0 || cuv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // beam fuzz: 5-tap cross blur
    vec2 texel = 1.0 / iResolution.xy;
    vec2 f = texel * FUZZ;
    vec3 col = texture(iChannel0, cuv).rgb * 0.40
             + texture(iChannel0, cuv + vec2( f.x, 0.0)).rgb * 0.15
             + texture(iChannel0, cuv - vec2( f.x, 0.0)).rgb * 0.15
             + texture(iChannel0, cuv + vec2(0.0,  f.y)).rgb * 0.15
             + texture(iChannel0, cuv - vec2(0.0,  f.y)).rgb * 0.15;

    // bloom: 8-tap ring, squared so only bright glyphs halo
    vec3 glow = vec3(0.0);
    for (int i = 0; i < 8; i++) {
        float a = 6.28318 * float(i) / 8.0;
        glow += texture(iChannel0, cuv + vec2(cos(a), sin(a)) * texel * 2.5).rgb;
    }
    glow /= 8.0;
    col += glow * glow * BLOOM;

#if TEXT_GHOST
    // fake persistence: each pixel picks up decaying copies of the glyphs
    // above it, so every glyph drags a fading tail downward. max() keeps
    // the smear from brightening solid text — it only fills dark space.
    vec3 smear = vec3(0.0);
    float wsum = 0.0;
    for (int i = 1; i <= 8; i++) {
        float w = exp(-0.45 * float(i));
        smear += texture(iChannel0, cuv + vec2(0.0, float(i) * TEXT_GHOST_LEN * texel.y)).rgb * w;
        wsum += w;
    }
    col = max(col, (smear / wsum) * TEXT_GHOST_GAIN);
#endif

#if MONO
    col = PHOSPHOR * dot(col, vec3(0.299, 0.587, 0.114));
#endif

    // cursor ghost: fading streak from previous to current position,
    // tail catches up to head as the phosphor "decays"
    vec2 px = cuv * iResolution.xy;
    vec2 cur = cursorCenter(iCurrentCursor);
    vec2 prev = cursorCenter(iPreviousCursor);
    float t = clamp((iTime - iTimeCursorChange) * GHOST_DECAY, 0.0, 1.0);
    float halfW = max(max(iCurrentCursor.w, iCurrentCursor.z * 0.35) * 0.75, GHOST_MIN_W);
    float d = sdSegment(px, mix(prev, cur, t), cur);
    float mask = smoothstep(halfW, halfW * 0.15, d);
    // trails only make sense for horizontal (typing/motion) moves.
    // any vertical component = line change or redraw = teleport, no streak.
    // long horizontal jumps (prompt redraws) also fade out.
    float cellW = max(iCurrentCursor.z, 4.0);
    float jumpFade = (1.0 - smoothstep(8.0, 16.0, abs(cur.x - prev.x) / cellW))
                   * (1.0 - smoothstep(2.0, 6.0, abs(cur.y - prev.y)));
    // fall back to phosphor tint if the cursor color uniform is ~black
    vec3 tint = mix(PHOSPHOR, iCurrentCursorColor.rgb,
                    step(0.15, dot(iCurrentCursorColor.rgb, vec3(1.0))));
    col += tint * mask * exp(-3.0 * t) * GHOST_GAIN * jumpFade;

    // scanlines + corner falloff
    col *= 1.0 - SCANLINE * (0.5 + 0.5 * sin(fragCoord.y * 3.14159));
    col *= 1.0 - 0.18 * dot(n, n);

    fragColor = vec4(col, 1.0);
}
