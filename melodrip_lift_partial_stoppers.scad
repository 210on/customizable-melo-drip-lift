/* [プレビュー設定] */
// ハニカム構造の半透明メロドリップを表示しますか？
show_melodrip = true; // [true, false]

/* [メロドリップ本体の寸法] */
// 上部外径
melo_dia_top = 55.0; // [40.0:0.1:70.0]
// 下部外径
melo_dia_bot = 53.0; // [40.0:0.1:70.0]
// 高さ
melo_h = 14.0;       // [5.0:0.1:30.0]
// はまりの基準クリアランス
fit_clearance = 0.30; // [0.0:0.05:1.0]

/* [リフト外枠の設定] */
// 外枠の上端直径（ドリッパー上端に合わせて調整）
outer_dia_top = 100.0; // [60.0:0.1:150.0]
// 外枠の下端直径（下にいくほど細くなるテーパー）
outer_dia_bot = 97.0;  // [60.0:0.1:150.0]
// リフト全体の高さ
outer_h = 6.0;         // [2.0:0.1:30.0]
// 外枠の壁の厚み
outer_thick = 3.0;     // [1.0:0.1:10.0]

/* [内枠（固定部）の設定] */
// 内枠の壁の厚み
inner_thick = 1.5;   // [1.0:0.1:5.0]
// メロドリップが固定される高さ（底面から浮かせる高さ）
melo_z_offset = 4.0; // [-10.0:0.1:20.0]

/* [橋（スポーク）の設定] */
// 橋の本数
bridge_count = 3;    // [2:1:8]
// 橋の幅
bridge_w = 3.0;      // [1.0:0.1:15.0]

/* [部分ストッパーの設定] */
// 落下防止突起の個数。0で無効
stopper_count = 3;       // [0:1:8]
// 1つあたりの角度幅
stopper_angle = 28.0;    // [5.0:1.0:120.0]
// 配置の開始角度
stopper_phase = 0.0;     // [0.0:1.0:359.0]
// 内側への張り出し量
stopper_depth = 0.8;     // [0.0:0.1:3.0]
// 下から立ち上がる高さ
stopper_rise = 1.0;      // [0.0:0.1:4.0]
// 上面の高さ
stopper_height = 1.0;    // [0.2:0.1:4.0]

/* [曲面（触り心地）の設定] */
// 橋の付け根の滑らかさ（水かき）
concave_r = 6.0;     // [0.0:0.1:15.0]
// 手で触れる上下エッジの角の丸み
edge_r = 1.0;        // [0.0:0.1:3.0]

/* [Hidden] */
$fn = 120; // 円の滑らかさ
profile_pad_r = 5.0;
profile_cut_z = -2.0;
inner_gap_margin = 0.5;
outer_gap_margin = 0.5;
clip_clearance = 0.1;

// ==========================================
// ユーティリティ
// ==========================================
function clamp(v, lo, hi) = min(max(v, lo), hi);
function x_at_z(x1, z1, x2, z2, target_z) =
    abs(z2 - z1) < 0.0001
        ? x2
        : x1 + (x2 - x1) * ((target_z - z1) / (z2 - z1));

module round_concave(r) {
    if (r > 0.001) {
        offset(r = -r)
        offset(r = r)
            children();
    }
    else {
        children();
    }
}

module round_convex(r) {
    if (r > 0.001) {
        offset(r = r)
        offset(r = -r)
            children();
    }
    else {
        children();
    }
}

// ==========================================
// 寸法と安全値の事前計算
// ==========================================
r_bot_in = (melo_dia_bot / 2) + fit_clearance;
r_top_in = (melo_dia_top / 2) + fit_clearance;

r_bot_out = r_bot_in + inner_thick;
r_top_out = r_top_in + inner_thick;

r_out_bot_out = outer_dia_bot / 2;
r_out_top_out = outer_dia_top / 2;
r_out_bot_in = r_out_bot_out - outer_thick;
r_out_top_in = r_out_top_out - outer_thick;

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
    edge_r,
    max(0, stopper_depth_safe / 2 - 0.05),
    max(0, stopper_height / 2 - 0.05)
);

x_bridge_bot_ext = x_at_z(r_bot_out, melo_z_offset, r_out_bot_in, 0, profile_cut_z);
x_out_bot_ext = x_at_z(r_out_bot_out, 0, r_out_top_out, outer_h, profile_cut_z);
mask_extrude_h = outer_h + melo_h + abs(profile_cut_z) + 2;
bottom_trim_r = max(r_out_top_out, r_out_bot_out) + profile_pad_r + 10;

assert(bridge_count >= 2, "bridge_count must be 2 or more.");
assert(inner_thick > 0 && outer_thick > 0, "Wall thickness must be positive.");
assert(base_r_outer > base_r_inner, "Inner support and outer ring overlap in top view.");
assert(r_out_bot_in > r_bot_out, "Bottom gap between inner frame and outer ring is too small.");
assert(outer_h > 0, "outer_h must be positive.");

// ==========================================
// 1. リフト本体
// ==========================================
module raw_plan_mask_2d() {
    union() {
        circle(r = base_r_inner);

        for (i = [0:bridge_count - 1]) {
            rotate(i * 360 / bridge_count)
                translate([0, -bridge_w / 2])
                    square([base_r_outer + profile_pad_r, bridge_w]);
        }

        difference() {
            circle(r = max(r_out_top_out, r_out_bot_out) + safe_concave + profile_pad_r);
            circle(r = base_r_outer);
        }
    }
}

module plan_mask_2d() {
    round_concave(safe_concave)
        raw_plan_mask_2d();
}

module raw_body_profile_2d() {
    polygon([
        [r_bot_in,      melo_z_offset],
        [r_bot_out,     melo_z_offset],
        [x_bridge_bot_ext, profile_cut_z],
        [x_out_bot_ext,    profile_cut_z],
        [r_out_top_out, outer_h],
        [r_out_top_in,  outer_h],
        [r_top_out,     melo_z_offset + melo_h],
        [r_top_in,      melo_z_offset + melo_h]
    ]);
}

module body_profile_2d() {
    round_convex(safe_edge)
        raw_body_profile_2d();
}

module main_body() {
    intersection() {
        linear_extrude(height = mask_extrude_h)
            plan_mask_2d();

        rotate_extrude()
            body_profile_2d();
    }
}

module raw_stopper_profile_2d() {
    z0 = melo_z_offset;
    z1 = z0 + stopper_rise;
    z2 = z1 + stopper_height;

    polygon([
        [r_bot_in - stopper_depth_safe, z2],
        [r_bot_in - stopper_depth_safe, z1],
        [r_bot_in,                      z0],
        [r_bot_out,                     z0],
        [r_bot_out,                     z2],
        [r_bot_in,                      z2]
    ]);
}

module stopper_profile_2d() {
    round_convex(safe_stopper_edge)
        raw_stopper_profile_2d();
}

module stopper_tabs() {
    if (stopper_count > 0 && stopper_depth_safe > 0.001 && stopper_angle > 0.001) {
        for (i = [0:stopper_count - 1]) {
            rotate([0, 0, stopper_phase + i * 360 / stopper_count - stopper_angle / 2])
                rotate_extrude(angle = stopper_angle)
                    stopper_profile_2d();
        }
    }
}

module lift_body() {
    difference() {
        union() {
            main_body();
            stopper_tabs();
        }

        // 印刷用に底面を完全に平らにする
        translate([0, 0, -50])
            cylinder(h = 50, r = bottom_trim_r);
    }
}

color("#222222")
    lift_body();

// ==========================================
// 2. メロドリップ本体のプレビュー
// ==========================================
module honeycomb_pattern(dia, w, wall) {
    step_x = w + wall;
    step_y = (w + wall) * sin(60);
    cols = floor(dia / step_x) + 1;
    rows = floor(dia / step_y) + 1;

    intersection() {
        circle(d = dia - 3);

        for (r = [-rows:rows]) {
            for (c = [-cols:cols]) {
                x = c * step_x + (r % 2 != 0 ? step_x / 2 : 0);
                y = r * step_y;
                translate([x, y])
                    circle(d = w / cos(30), $fn = 6);
            }
        }
    }
}

if (show_melodrip) {
    color([0.9, 0.9, 0.95, 0.5]) {
        translate([0, 0, melo_z_offset + 0.1]) {
            difference() {
                cylinder(h = melo_h, d1 = melo_dia_bot, d2 = melo_dia_top);

                translate([0, 0, 1.5])
                    cylinder(h = melo_h, d1 = melo_dia_bot - 3, d2 = melo_dia_top - 3);

                translate([0, 0, -1])
                    linear_extrude(4)
                        honeycomb_pattern(melo_dia_bot, 6.5, 1.5);
            }
        }
    }
}
