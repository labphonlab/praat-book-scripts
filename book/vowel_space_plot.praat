# vowel_space_plot.praat
# Script 16.2：Praatで母音空間図を作成する（比較・確認用）
#
# 『Praatで学ぶ音声研究の方法』Script 16.2掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Vowel Space Plot
  sentence Csv_file      results/vowels_summary.csv
  real     F1_min        200
  real     F1_max        900
  real     F2_min        700
  real     F2_max        2800
  real     Width_in       5
  real     Height_in      4
  sentence Output_file   figures/vowel_space.pdf
endform

table = Read Table from comma-separated file: csv_file$
selectObject: table
n_rows = Get number of rows

Erase all
Font size: 13
Line width: 1.5
Select outer viewport: 0, width_in, 0, height_in

; 軸の方向を音声学慣習に合わせる（F2は左ほど高い、F1は上ほど低い）
; 座標軸: x_min, x_max, y_min, y_max
Axes: f2_max, f2_min, f1_max, f1_min

; グレースケール用のマーカー設定（カテゴリ識別を色に頼らない）
; 各母音にグレーの濃淡と異なるサイズを使う（グレースケール印刷に対応）
for i from 1 to n_rows
  selectObject: table
  vowel$ = Get value: i, "vowel"
  f1$    = Get value: i, "f1_mean"
  f2$    = Get value: i, "f2_mean"
  f1_hz  = number(f1$)
  f2_hz  = number(f2$)

  ; f1, f2が数値として取得できた場合のみプロットする
  if f1_hz <> undefined and f2_hz <> undefined

    ; 母音ごとにグレースケール値（0.0=黒〜1.0=白）を変える
    if vowel$ = "a"
      # 黒
      grey = 0.0
    elsif vowel$ = "i"
      # 暗いグレー
      grey = 0.3
    elsif vowel$ = "u"
      # 中間グレー
      grey = 0.5
    elsif vowel$ = "e"
      # 明るいグレー
      grey = 0.65
    elsif vowel$ = "o"
      # 薄いグレー
      grey = 0.8
    else
      grey = 0.4
    endif

    # 直径3mm の塗りつぶし円（第1引数が色）
    Paint circle: grey, f2_hz, f1_hz, 3
    Colour: "black"
    Text: f2_hz, "Centre", f1_hz - 40, "Bottom", vowel$
  endif
endfor

; 軸・ボックス
Colour: "black"
Draw inner box
Marks bottom every: 1, 200, "yes", "yes", "no"
Marks left every:   1, 100, "yes", "yes", "no"
Text bottom: "yes", "F2 (Hz)"
Text left:   "yes", "F1 (Hz)"

Save as PDF file: output_file$
appendInfoLine: "保存: ", output_file$
removeObject: table
