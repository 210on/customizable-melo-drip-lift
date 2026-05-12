# Customizable MeloDrip Lift

Parametric OpenSCAD model for a MeloDrip lift/support.

メロドリップ用リフトをパラメトリックに調整できる OpenSCAD モデルです。

## Main model

- `melodrip_lift_partial_stoppers.scad`
  - Adjustable support body for MeloDrip with partial anti-drop tabs.
  - Tunable fit, bridge count, outer frame dimensions, and stopper placement.

## メインモデル

- `melodrip_lift_partial_stoppers.scad`
  - メロドリップ本体を支えるリフト本体です。
  - はめ合い、ブリッジ本数、外周寸法、ストッパー位置を調整できます。

## Key parameters

- `fit_clearance`
  - Base fit clearance against the MeloDrip body.
- `stopper_count`
  - Number of localized stopper tabs.
- `stopper_angle`
  - Angular span of each stopper tab.
- `stopper_depth`
  - How far each stopper projects inward.
- `stopper_phase`
  - Rotational offset used to place the stopper tabs away from interference points.

## 主なパラメータ

- `fit_clearance`
  - メロドリップ本体との基準クリアランスです。
- `stopper_count`
  - 部分ストッパーの個数です。
- `stopper_angle`
  - 各ストッパーが占める角度幅です。
- `stopper_depth`
  - ストッパーが内側へ張り出す量です。
- `stopper_phase`
  - 干渉を避けたい位置に合わせてストッパー全体を回転配置するための位相です。

## Usage

1. Open `melodrip_lift_partial_stoppers.scad` in OpenSCAD.
2. Adjust the exposed parameters in the customizer or source.
3. Preview with `F5`.
4. Render/export with `F6` when the fit and stopper placement look correct.

## 使い方

1. OpenSCAD で `melodrip_lift_partial_stoppers.scad` を開きます。
2. カスタマイザまたはソース上のパラメータを調整します。
3. `F5` でプレビューします。
4. はまり具合とストッパー位置が問題なければ `F6` でレンダリングして書き出します。
