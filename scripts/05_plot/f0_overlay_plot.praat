# f0_overlay_plot.praat
# 複数ファイルのF0軌跡を重ね描きする
#
# 『Praatで学ぶ音声研究の方法』付録A-37（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# 複数ファイルのF0軌跡を1枚に重ねて描く。
# 発話間でイントネーションの形を見比べるための図である。
#
# 入力: WAVの入ったフォルダ
# 出力: 重ね描きしたPDF 1枚（ファイルごとに色分け）
#
# 読み方・注意:
#   - 既定では時間を0〜1に正規化する。長さの違う発話を
#     重ねるとき、実時間のままでは形を比べられないためである。
#     normalize_time を0にすると実時間軸になる。
#   - 話者の高さが違うときは semitone_scale を1にする。
#     Hz軸のままだと、低い声の話者の変動が小さく見える。
#   - 線が途切れているのは無声区間である。欠測ではない。
#   - 重ねられるのは実用上6〜8本まで。それ以上は色が足りず
#     判別できなくなる。条件ごとに平均した軌跡を描くほうがよい。

form F0 trajectory overlay
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_pdf
  positive Pitch_floor 75
  positive Pitch_ceiling 400
  positive N_points 30
  boolean Normalize_time 1
  boolean Semitone_scale 0
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_pdf$ = ""
  output_pdf$ = pbs_root$ + "/results/f0_overlay_plot.pdf"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 長さの違う発話を重ねるので、既定では時間を0〜1に正規化する。
# 話者の高さが違う場合は半音目盛りにすると比較しやすい。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

Erase all
Select outer viewport: 0, 6, 0, 4
if semitone_scale
  ymin = 12 * log2(pitch_floor / 100)
  ymax = 12 * log2(pitch_ceiling / 100)
  ylab$ = "F0 (semitones re 100 Hz)"
  ystep = 6
else
  ymin = pitch_floor
  ymax = pitch_ceiling
  ylab$ = "F0 (Hz)"
  ystep = 50
endif
if normalize_time
  xmax = 1
  xlab$ = "正規化時間"
  xstep = 0.2
else
  xmax = 0
  for i from 1 to n
    selectObject: list
    f$ = Get string: i
    snd = Read from file: input_folder$ + f$
    d = Get total duration
    removeObject: snd
    if d > xmax
      xmax = d
    endif
  endfor
  xlab$ = "時間 (s)"
  xstep = 0.1
endif

Axes: 0, xmax, ymin, ymax
Draw inner box
Marks bottom every: 1, xstep, "yes", "yes", "no"
Marks left every: 1, ystep, "yes", "yes", "no"
Text bottom: "yes", xlab$
Text left: "yes", ylab$

colours$# = {"Blue", "Red", "Green", "Magenta", "Maroon", "Navy"}
n_drawn = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  pitch = To Pitch: 0, pitch_floor, pitch_ceiling
  Colour: colours$# [(i - 1) mod size(colours$#) + 1]

  prev_x = undefined
  prev_y = undefined
  for k from 1 to n_points
    rel = (k - 0.5) / n_points
    selectObject: pitch
    v = Get value at time: rel * dur, "Hertz", "linear"
    if v = undefined
      y = undefined
    else
      if semitone_scale
        y = 12 * log2(v / 100)
      else
        y = v
      endif
    endif
    if normalize_time
      x = rel
    else
      x = rel * dur
    endif
    if y <> undefined and prev_y <> undefined
      Draw line: prev_x, prev_y, x, y
    endif
    prev_x = x
    prev_y = y
  endfor
  n_drawn = n_drawn + 1
  removeObject: pitch, snd
endfor

Colour: "Black"
Save as PDF file: output_pdf$
removeObject: list
appendInfoLine: "重ね描き ", n_drawn, " 本 → ", output_pdf$
