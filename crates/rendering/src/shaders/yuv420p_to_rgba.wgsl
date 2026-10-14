@group(0) @binding(0) var y_plane: texture_2d<f32>;
@group(0) @binding(1) var u_plane: texture_2d<f32>;
@group(0) @binding(2) var v_plane: texture_2d<f32>;

@vertex
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> @builtin(position) vec4<f32> {
    var positions = array<vec2<f32>, 3>(
        vec2<f32>(-1.0, -1.0),
        vec2<f32>(3.0, -1.0),
        vec2<f32>(-1.0, 3.0)
    );
    return vec4<f32>(positions[vertex_index], 0.0, 1.0);
}

@fragment
fn fs_main(@builtin(position) position: vec4<f32>) -> @location(0) vec4<f32> {
    let coords = vec2<u32>(position.xy);

    let y_raw = textureLoad(y_plane, coords, 0).r;

    let uv_coords = coords / 2;
    let u_dims = textureDimensions(u_plane);
    let v_dims = textureDimensions(v_plane);
    let u_clamped = min(uv_coords, u_dims - vec2<u32>(1, 1));
    let v_clamped = min(uv_coords, v_dims - vec2<u32>(1, 1));
    let u_raw = textureLoad(u_plane, u_clamped, 0).r;
    let v_raw = textureLoad(v_plane, v_clamped, 0).r;

    let y = (y_raw - 0.0625) * 1.164;
    let u = u_raw - 0.5;
    let v = v_raw - 0.5;

    let r = y + 1.596 * v;
    let g = y - 0.391 * u - 0.813 * v;
    let b = y + 2.018 * u;

    return vec4<f32>(
        clamp(r, 0.0, 1.0),
        clamp(g, 0.0, 1.0),
        clamp(b, 0.0, 1.0),
        1.0
    );
}
