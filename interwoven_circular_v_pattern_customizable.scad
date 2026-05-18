// ==================================
// Interwoven circular V pattern
// ==================================

/* [基本サイズ] */

$fn = 96;
// 完成品の外径(mm)
outer_d = 49;
// 先端の半径
tip_r = 22.7;
// 厚み(mm)
thickness = 2;
// V字ユニット数
units = 10;

/* [V字の基本バランス] */

// 根元の半径
root_r = 10.3;

// 根元から開き始める角度
root_half = 4.2;

// 根元でキュッと開く強さ
root_kink = 0.65;

// 隣のV字と外側で入れ替わる角度
swap_tip_angle = 27;

/* [V字の膨らみ] */

// 外側へのふくらみ量
v_bulge_angle = 8;

// どの半径位置で一番ふくらませるか
v_bulge_r = 19.0;

// ふくらみの出方
v_softness = 0.55;

/* [線の太さ] */
// V字の根元側の線径
root_d = 4.0;

// 先端側の線径
tip_d = 3.5;

/* [曲線のなめらかさ] */
// 曲線分割数
steps = 28;


// =====================================================
// Internal values
// ここから下は上の設定から自動で決まる値
// =====================================================

outer_r    = outer_d / 2;
unit_pitch = 360 / units;        // 1ユニットの角度
tip_pitch  = 360 / (units * 2);  // 先端側の基準角度
tip_half   = tip_pitch / 2;


// ---------- utility ----------
function lerp(a, b, t) = a + (b - a) * t;
function clamp(x, lo, hi) = min(max(x, lo), hi);
function rev_list(xs) = [for(i = [len(xs) - 1:-1:0]) xs[i]];

function polar(r, a) = [
    r * cos(a),
    r * sin(a)
];

function cbez_point(p0, p1, p2, p3, t) =
[
    pow(1 - t, 3) * p0[0]
  + 3 * pow(1 - t, 2) * t * p1[0]
  + 3 * (1 - t) * pow(t, 2) * p2[0]
  + pow(t, 3) * p3[0],

    pow(1 - t, 3) * p0[1]
  + 3 * pow(1 - t, 2) * t * p1[1]
  + 3 * (1 - t) * pow(t, 2) * p2[1]
  + pow(t, 3) * p3[1]
];

function cbez_points(p0, p1, p2, p3, n = 20) =
    [ for(i = [0:n]) cbez_point(p0, p1, p2, p3, i / n) ];

module stroke_path(points, d0, d1) {
    segs = len(points) - 1;

    for(i = [0:segs - 1]) {
        t0 = i / segs;
        t1 = (i + 1) / segs;

        hull() {
            translate(points[i])
                circle(d = lerp(d0, d1, t0));

            translate(points[i + 1])
                circle(d = lerp(d0, d1, t1));
        }
    }
}

module stroke_path_profile(points, ds) {
    segs = len(points) - 1;

    for(i = [0:segs - 1]) {
        hull() {
            translate(points[i])
                circle(d = ds[i]);

            translate(points[i + 1])
                circle(d = ds[i + 1]);
        }
    }
}

module cubic_stroke(p0, p1, p2, p3, d0, d1, n = 20) {
    stroke_path(cbez_points(p0, p1, p2, p3, n), d0, d1);
}

function arm_points(a, side, n = 20) =
    let(
        a_tip = a + side * swap_tip_angle,
        kink = clamp(root_kink, 0, 1),
        root_kink_t = lerp(0.40, 0.10, kink),
        root_open_angle = lerp(root_half * 0.70, root_half * 1.20, kink),
        p0 = polar(root_r, a),
        p1 = polar(
            lerp(root_r, v_bulge_r, root_kink_t),
            a + side * root_open_angle
        ),
        p2 = polar(
            v_bulge_r,
            a + side * (swap_tip_angle + v_bulge_angle * v_softness)
        ),
        p3 = polar(tip_r, a_tip)
    )
    cbez_points(p0, p1, p2, p3, n);


// ---------- 1本の線のように見えるV字 ----------
module v_stroke(a) {
    left_points  = arm_points(a, -1, steps);
    right_points = arm_points(a,  1, steps);
    points = concat(
        rev_list(left_points),
        [for(i = [1:len(right_points) - 1]) right_points[i]]
    );

    center_i = len(left_points) - 1;
    max_dist = center_i;
    ds = [
        for(i = [0:len(points) - 1])
            lerp(root_d, tip_d, abs(i - center_i) / max_dist)
    ];

    stroke_path_profile(points, ds);
}


// ---------- one V unit ----------
module v_unit(i) {
    a = i * unit_pitch;

    // 左右の腕を1本の連続線として描く
    // 根元で丸い継ぎ目が自然に出る
    v_stroke(a);
}


// ---------- full pattern ----------
module pattern2d() {
    intersection() {
        offset(r = 0.08)
        offset(delta = -0.08)
        union() {
            for(i = [0:units - 1]) {
                v_unit(i);
            }
        }

        circle(r = outer_r);
    }
}


// ---------- output ----------
color("black")
linear_extrude(height = thickness, convexity = 10)
    pattern2d();
