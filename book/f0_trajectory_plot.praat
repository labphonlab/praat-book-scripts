# f0_trajectory_plot.praat
# Script 16.3：F0軌跡をCSVから描画する
#
# 『Praatで学ぶ音声研究の方法』Script 16.2掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form F0 Trajectory Plot
  sentence Csv_file      results/f0_trajectories.csv
  real     F0_min        50
  real     F0_max        300
  real     Width_cm      14
  real     Height_cm      8
  sentence Output_file   figures/f0_trajectory.pdf
endform

table = Read Table from comma-separated file: csv_file$
n_rows = Get number of rows

Erase all
Font size: 11
Line width: 2
Select outer viewport: 0, width_cm, 0, height_cm
Axes: 0, 100, f0_min, f0_max

Colour: "black"
Line width: 2

# Praatは1行に2つの文を書けないため、代入は必ず別行にする
t_prev  = undefined
f0_prev = undefined

for i from 1 to n_rows
  selectObject: table
  t_i  = Get value: i, "time_norm"
  f0_i = Get value: i, "f0_mean"

  ; 両端の値が有効な場合のみ線を引く
  if t_prev <> undefined and f0_prev <> undefined
    if t_i <> undefined and f0_i <> undefined
      Draw line: t_prev, f0_prev, t_i, f0_i
    endif
  endif

  ; 次のループのために現在の値を保存する（必ず別行で代入）
  t_prev  = t_i
  f0_prev = f0_i
endfor

Colour: "black"
Draw inner box
Marks bottom every: 1, 20, "yes", "yes", "no"
Text bottom: "yes", "Normalized time (%)"
Marks left every: 1, 50, "yes", "yes", "no"
Text left: "yes", "F0 (Hz)"

Save as PDF file: output_file$
appendInfoLine: "保存: ", output_file$
removeObject: table
