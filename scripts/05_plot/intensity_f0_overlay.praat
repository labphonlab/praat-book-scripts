# intensity_f0_overlay.praat
# 強度とF0を2軸で重ねて描く
#
# 『Praatで学ぶ音声研究の方法』付録A-40（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# F0（左軸・青）と強度（右軸・赤）を1枚に重ねて描く。
# プロミネンスの分析など、高さと大きさの関係を見たいときに使う。
#
# 入力: WAVの入ったフォルダ
# 出力: ファイルごとに1枚のPDF
#
# 読み方・注意:
#   - 単位の違う2つを重ねている。どちらの線がどちらの軸かを
#     示さないと図として成立しない。図の上に凡例を入れてある。
#   - 縦軸の範囲を変えると、2本の線の見かけの関係は簡単に変わる。
#     「F0と強度が連動している」という印象は範囲の取り方で作れてしまう。
#     主張したいことがあるなら、図ではなく数値で示すこと。
#   - 強度の絶対値は録音レベルに依存する。録音条件の違うファイル間で
#     dB値をそのまま比べてはいけない。

form Intensity and F0 overlay
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_folder
  positive Pitch_floor 75
  positive Pitch_ceiling 400
  positive Intensity_min_db 40
  positive Intensity_max_db 90
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/intensity_f0_overlay/"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 左軸をF0、右軸を強度にする。単位の違うものを重ねるときは、
# どちらの線がどちらの軸かを凡例で必ず示すこと。

createDirectory: output_folder$
Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  stem$ = f$ - ".wav"
  snd = Read from file: input_folder$ + f$
  dur = Get total duration

  Erase all
  Select outer viewport: 0, 6, 0, 4

  # F0（左軸・青）
  selectObject: snd
  pitch = To Pitch: 0, pitch_floor, pitch_ceiling
  Colour: "Blue"
  Draw: 0, 0, pitch_floor, pitch_ceiling, "no"
  Axes: 0, dur, pitch_floor, pitch_ceiling
  Marks left every: 1, 50, "yes", "yes", "no"
  Text left: "yes", "F0 (Hz)"

  # 強度（右軸・赤）
  selectObject: snd
  intensity = To Intensity: pitch_floor, 0, "yes"
  Colour: "Red"
  Draw: 0, 0, intensity_min_db, intensity_max_db, "no"
  Axes: 0, dur, intensity_min_db, intensity_max_db
  Marks right every: 1, 10, "yes", "yes", "no"
  Text right: "yes", "強度 (dB)"

  Colour: "Black"
  Draw inner box
  Marks bottom every: 1, 0.1, "yes", "yes", "no"
  Text bottom: "yes", "時間 (s)"
  Text top: "no", "青: F0 ／ 赤: 強度"

  Save as PDF file: output_folder$ + stem$ + ".pdf"
  removeObject: pitch, intensity, snd
endfor

removeObject: list
appendInfoLine: "作図 ", n, " 件 → ", output_folder$
