# Customizable MeloDrip Lift

Parametric OpenSCAD model for a MeloDrip lift/support, designed to avoid interference by using localized stopper tabs instead of a full inner ring.

メロドリップ用リフトをパラメトリックに調整できる OpenSCAD モデルです。内側の落下防止形状は全周リングではなく、干渉を避けやすい部分ストッパー方式にしています。

## Current spec

- Target MeloDrip body:
  - Bottom diameter `53 mm`
  - Top diameter `55 mm`
  - Height `14 mm`
- Support strategy:
  - Inner support wall
  - Radial bridge spokes
  - Outer support ring
  - Localized anti-drop stopper tabs
- Print assumptions:
  - FDM printing
  - Flat bottom for bed contact
  - Rounded edges for handling comfort
  - Lead-in relief at the upper mouth for easier insertion

## 現在の仕様

- 想定するメロドリップ本体寸法:
  - 下部外径 `53 mm`
  - 上部外径 `55 mm`
  - 高さ `14 mm`
- 保持の考え方:
  - 内枠で位置決め
  - スポークで外周リングへ接続
  - 部分ストッパーで落下を防止
- 造形前提:
  - FDM 造形
  - 底面フラット
  - 手当たり改善の角丸め
  - 差し込みやすさを上げる上口リードイン

## Files

- `melodrip_lift_partial_stoppers.scad`
  - Main model and user-facing parameters.
  - Self-contained single file except for `BOSL2/std.scad`.

## 依存関係

- `include <BOSL2/std.scad>` が必要です。
- OpenSCAD 2 Web Playground: [openscad2](https://ochafik.com/openscad2/) では BOSL2 が利用可能です。
- Playground 用にはローカル `lib/` を参照しない単一ファイル構成にしています。

## Tuning order

1. `fit_clearance`
   - Basic fit against the real MeloDrip body.
2. `stopper_phase`
   - Rotates the partial stopper tabs away from interference points.
3. `stopper_depth` and `stopper_angle`
   - Controls retention strength versus insertion friction.
4. `bridge_count` and `bridge_w`
   - Adjusts rigidity and visual openness.
5. `seat_lead_in_clearance` and `seat_lead_in_h`
   - Fine-tunes ease of insertion at the mouth.

## 調整の順番

1. `fit_clearance`
   - 実物メロドリップとの基本クリアランスを決めます。
2. `stopper_phase`
   - 干渉しやすい位置からストッパーを逃がします。
3. `stopper_depth` と `stopper_angle`
   - 保持力と差し込み抵抗のバランスを詰めます。
4. `bridge_count` と `bridge_w`
   - 剛性と抜け感を調整します。
5. `seat_lead_in_clearance` と `seat_lead_in_h`
   - 上口の入りやすさを微調整します。

## Quality improvements in this version

- Code structure reorganized inside a BOSL2-based single file for playground compatibility.
- BOSL2-based 2D rounding for cleaner edge control.
- Upper lead-in relief added to reduce snagging during insertion.
- Minimum stopper angular gap enforced to avoid merged or over-dense tabs.
- Adaptive curve quality via `$fa` / `$fs` instead of a fixed global `$fn`.

## この版での改善点

- Playground でそのまま動くように、BOSL2 ベースの単一ファイルへ整理しました。
- BOSL2 の `round2d()` を使って角丸め処理を整理しました。
- 差し込み時の引っかかりを減らすため、上口にリードイン逃がしを追加しました。
- ストッパー同士が詰まりすぎないよう、最小角度ギャップを導入しました。
- 固定 `\$fn` ではなく `$fa` / `$fs` ベースにして、曲面品質を調整しやすくしました。
