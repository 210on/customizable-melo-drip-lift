include <BOSL2/std.scad>

/*
仕様要約
- MeloDrip 本体は「下53 / 上55 / 高さ14 mm」を基準に保持する。
- 保持方式は「内枠 + 3本スポーク + 外周リング + 部分ストッパー」。
- 干渉対策として、落下防止突起は全周リングにせず角度限定のタブにする。
- FDM 造形を前提に、底面フラット・上口リードイン・角丸めを入れる。
- このファイルは BOSL2 の `std.scad` を利用する。OpenSCAD 2 Web Playground 想定。
*/

function ml_clamp(v, lo, hi) = min(max(v, lo), hi);
function ml_lerp(a, b, t) = a + (b - a) * t;
function ml_x_at_z(x1, z1, x2, z2, target_z) =
    abs(z2 - z1) < 0.0001
        ? x2
        : x1 + (x2 - x1) * ((target_z - z1) / (z2 - z1));
function ml_hex_cell_d(cell_w) = cell_w / cos(30);

module ml_round_concave(r) {
    if (r > 0.001) {
        round2d(ir = r)
            children();
    }
    else {
        children();
    }
}

module ml_round_convex(r) {
    if (r > 0.001) {
        round2d(or = r)
            children();
    }
    else {
        children();
    }
}

module ml_polar_array(count, phase = 0) {
    if (count > 0) {
        zrot_copies(n = count, sa = phase)
            children();
    }
}

module ml_ring_band(outer_r, inner_r) {
    difference() {
        circle(r = outer_r);
        circle(r = inner_r);
    }
}

module ml_radial_spokes(count, width, length, phase = 0) {
    ml_polar_array(count, phase)
        translate([0, -width / 2])
            square([length, width]);
}

module ml_honeycomb_pattern(dia, cell_w, wall) {
    step_x = cell_w + wall;
    step_y = (cell_w + wall) * sin(60);
    cols = floor(dia / step_x) + 1;
    rows = floor(dia / step_y) + 1;

    intersection() {
        circle(d = dia - 3);

        for (r = [-rows:rows]) {
            for (c = [-cols:cols]) {
                x = c * step_x + (r % 2 != 0 ? step_x / 2 : 0);
                y = r * step_y;
                translate([x, y])
                    circle(d = ml_hex_cell_d(cell_w), $fn = 6);
            }
        }
    }
}

module ml_flatten_bottom(trim_r, cut_h = 50) {
    translate([0, 0, -cut_h])
        cylinder(h = cut_h, r = trim_r);
}

/* [プレビュー設定] */
show_melodrip = false;          // [true, false]
echo_spec_summary = false;     // [true, false]

/* [メロドリップ本体の基準寸法] */
melo_dia_top = 55.0;           // [40.0:0.1:70.0]
melo_dia_bot = 53.5;           // [40.0:0.1:70.0]
melo_h = 14.0;                 // [5.0:0.1:30.0]

/* [はまりと挿入性] */
fit_clearance = 0.30;          // [0.0:0.05:1.0]
seat_lead_in_clearance = 0.35; // [0.0:0.05:1.0]
seat_lead_in_h = 0.8;          // [0.0:0.1:3.0]

/* [リフト外枠] */
outer_dia_top = 100.0;         // [60.0:0.1:150.0]
outer_dia_bot = 97.0;          // [60.0:0.1:150.0]
outer_h = 6.0;                 // [2.0:0.1:30.0]
outer_thick = 3.0;             // [1.0:0.1:10.0]

/* [内枠と支持高さ] */
inner_thick = 1.5;             // [1.0:0.1:5.0]
melo_z_offset = 4.0;           // [-10.0:0.1:20.0]

/* [橋（スポーク）] */
bridge_count = 3;              // [2:1:8]
bridge_w = 3.0;                // [1.0:0.1:15.0]

/* [部分ストッパー] */
stopper_count = 6;             // [0:1:8]
stopper_angle = 6.0;          // [5.0:1.0:120.0]
stopper_phase = 0.0;           // [0.0:1.0:359.0]
stopper_depth = 1.2;           // [0.0:0.1:3.0]
stopper_rise = 0;            // [0.0:0.1:4.0]
stopper_height = 1.0;          // [0.2:0.1:4.0]
stopper_edge_r = 0.7;          // [0.0:0.1:2.0]
stopper_gap_angle_min = 6.0;   // [0.0:1.0:30.0]

/* [曲面と造形品質] */
concave_r = 6.0;               // [0.0:0.1:15.0]
edge_r = 1.0;                  // [0.0:0.1:3.0]

/* [プレビュー本体] */
preview_shell_t = 1.5;         // [0.5:0.1:3.0]
preview_honeycomb_w = 6.5;     // [3.0:0.1:12.0]
preview_honeycomb_wall = 1.5;  // [0.5:0.1:3.0]

/* [Hidden] */
$fa = 4;
$fs = 0.45;
$fn = 0;
eps = 0.05;
profile_pad_r = 5.0;
profile_cut_z = -2.0;
inner_gap_margin = 0.5;
outer_gap_margin = 0.5;
clip_clearance = 0.1;
preview_bottom_shell_h = 1.5;

// ==========================================
// 1. 派生寸法
// ==========================================
r_bot_in = (melo_dia_bot / 2) + fit_clearance;
r_top_in = (melo_dia_top / 2) + fit_clearance;
r_bot_out = r_bot_in + inner_thick;
r_top_out = r_top_in + inner_thick;

r_out_bot_out = outer_dia_bot / 2;
r_out_top_out = outer_dia_top / 2;
r_out_bot_in = r_out_bot_out - outer_thick;
r_out_top_in = r_out_top_out - outer_thick;

seat_top_z = melo_z_offset + melo_h;
safe_lead_in_h = min(seat_lead_in_h, max(0, melo_h - 0.2));
safe_lead_in_clearance = min(seat_lead_in_clearance, max(0, inner_thick - 0.25));
lead_in_join_z = seat_top_z - safe_lead_in_h;
lead_in_join_t = ml_clamp(
    melo_h > eps ? (lead_in_join_z - melo_z_offset) / melo_h : 0,
    0,
    1
);
lead_in_join_r = ml_lerp(r_bot_in, r_top_in, lead_in_join_t);

base_r_inner = r_top_out + inner_gap_margin;
base_r_outer = min(r_out_top_in, r_out_bot_in) - outer_gap_margin;
gap_2d = base_r_outer - base_r_inner;

safe_concave = min(concave_r, max(0, gap_2d / 2 - 0.5));
safe_edge = min(
    edge_r,
    max(0, inner_thick / 2 - 0.05),
    max(0, outer_thick / 2 - 0.05)
);

stopper_depth_safe = min(stopper_depth, max(0, r_bot_in - clip_clearance));
safe_stopper_edge = min(
    stopper_edge_r,
    max(0, stopper_depth_safe / 2 - 0.05),
    max(0, stopper_height / 2 - 0.05)
);
safe_stopper_angle = stopper_count > 0
    ? min(stopper_angle, max(0, 360 / stopper_count - stopper_gap_angle_min))
    : 0;

x_bridge_bot_ext = ml_x_at_z(r_bot_out, melo_z_offset, r_out_bot_in, 0, profile_cut_z);
x_out_bot_ext = ml_x_at_z(r_out_bot_out, 0, r_out_top_out, outer_h, profile_cut_z);
mask_extrude_h = outer_h + melo_h + abs(profile_cut_z) + 2;
bottom_trim_r = max(r_out_top_out, r_out_bot_out) + profile_pad_r + 10;

preview_inner_d_bot = max(0.1, melo_dia_bot - 2 * preview_shell_t);
preview_inner_d_top = max(0.1, melo_dia_top - 2 * preview_shell_t);
preview_inner_h = max(eps, melo_h - preview_bottom_shell_h + eps);
preview_hex_cut_h = preview_bottom_shell_h + 2.5;

// ==========================================
// 2. 安全制約
// ==========================================
assert(bridge_count >= 2, "bridge_count must be 2 or more.");
assert(bridge_w > 0, "bridge_w must be positive.");
assert(fit_clearance >= 0, "fit_clearance must be zero or positive.");
assert(inner_thick > 0 && outer_thick > 0, "Wall thickness must be positive.");
assert(base_r_outer > base_r_inner, "Inner support and outer ring overlap in top view.");
assert(r_out_bot_in > r_bot_out, "Bottom gap between inner frame and outer ring is too small.");
assert(outer_h > 0, "outer_h must be positive.");
assert(melo_h > 0, "melo_h must be positive.");
assert(stopper_rise + stopper_height <= melo_h + eps, "Stopper height exceeds MeloDrip seat height.");
assert(
    stopper_count == 0 || (360 / stopper_count) > stopper_gap_angle_min || stopper_angle == 0,
    "stopper_gap_angle_min is too large for the stopper count."
);

if (echo_spec_summary) {
    echo(str("seat_inner_bottom_d = ", 2 * r_bot_in, " mm"));
    echo(str("seat_inner_top_d = ", 2 * r_top_in, " mm"));
    echo(str("seat_lead_in_top_d = ", 2 * (r_top_in + safe_lead_in_clearance), " mm"));
    echo(str("stopper_angle_effective = ", safe_stopper_angle, " deg"));
    echo(str("support_gap_2d = ", gap_2d, " mm"));
}

// ==========================================
// 3. 2D/3D 形状
// ==========================================
module lift_plan_2d() {
    ml_round_concave(safe_concave)
        union() {
            circle(r = base_r_inner);
            ml_radial_spokes(bridge_count, bridge_w, base_r_outer + profile_pad_r);
            ml_ring_band(
                max(r_out_top_out, r_out_bot_out) + safe_concave + profile_pad_r,
                base_r_outer
            );
        }
}

module lift_body_profile_2d() {
    ml_round_convex(safe_edge)
        polygon([
            [r_bot_in,        melo_z_offset],
            [r_bot_out,       melo_z_offset],
            [x_bridge_bot_ext, profile_cut_z],
            [x_out_bot_ext,    profile_cut_z],
            [r_out_top_out,   outer_h],
            [r_out_top_in,    outer_h],
            [r_top_out,       seat_top_z],
            [r_top_in,        seat_top_z]
        ]);
}

module stopper_profile_2d() {
    z1 = melo_z_offset + stopper_rise;
    z2 = z1 + stopper_height;

    ml_round_convex(safe_stopper_edge)
        polygon([
            [r_bot_in - stopper_depth_safe, z2],
            [r_bot_in - stopper_depth_safe, z1],
            [r_bot_in,                      melo_z_offset],
            [r_bot_out,                     melo_z_offset],
            [r_bot_out,                     z2],
            [r_bot_in,                      z2]
        ]);
}

module main_body() {
    intersection() {
        linear_extrude(height = mask_extrude_h)
            lift_plan_2d();

        rotate_extrude()
            lift_body_profile_2d();
    }
}

module stopper_tabs() {
    if (stopper_count > 0 && stopper_depth_safe > 0.001 && safe_stopper_angle > 0.001) {
        ml_polar_array(stopper_count, stopper_phase - safe_stopper_angle / 2)
            rotate_extrude(angle = safe_stopper_angle)
                stopper_profile_2d();
    }
}

module seat_lead_in_relief() {
    if (safe_lead_in_h > 0.001 && safe_lead_in_clearance > 0.001) {
        translate([0, 0, lead_in_join_z - eps])
            cylinder(
                h = safe_lead_in_h + 2 * eps,
                r1 = lead_in_join_r,
                r2 = r_top_in + safe_lead_in_clearance
            );
    }
}

module lift_body() {
    difference() {
        union() {
            main_body();
            stopper_tabs();
        }

        ml_flatten_bottom(bottom_trim_r);
        seat_lead_in_relief();
    }
}

// ==========================================
// 4. プレビュー
// ==========================================
module melodrip_preview() {
    color([0.9, 0.9, 0.95, 0.5]) {
        translate([0, 0, melo_z_offset + 0.1]) {
            difference() {
                cylinder(h = melo_h, d1 = melo_dia_bot, d2 = melo_dia_top);

                translate([0, 0, preview_bottom_shell_h])
                    cylinder(
                        h = preview_inner_h,
                        d1 = preview_inner_d_bot,
                        d2 = preview_inner_d_top
                    );

                translate([0, 0, -1])
                    linear_extrude(preview_hex_cut_h)
                        ml_honeycomb_pattern(
                            melo_dia_bot,
                            preview_honeycomb_w,
                            preview_honeycomb_wall
                        );
            }
        }
    }
}

// ==========================================
// 5. 出力
// ==========================================
color("#222222")
    lift_body();

if (show_melodrip) {
    melodrip_preview();
}
