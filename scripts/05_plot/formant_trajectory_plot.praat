# formant_trajectory_plot.praat
# スペクトログラム上にフォルマント軌跡を重ねて描く
#
# 『Praatで学ぶ音声研究の方法』付録A-39（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# スペクトログラムの上にフォルマント抽出結果を重ねた図を出す。
# 抽出設定が妥当かどうかを目で確かめるための図である。
#
# 入力: WAVの入ったフォルダ、max_formant（Hz）
# 出力: ファイルごとに1枚のPDF（赤い点がフォルマント）
#
# 読み方・注意:
#   - 抽出結果を数値だけで確かめるのは難しい。重ねて見れば、
#     追跡が外れている箇所が一目で分かる。設定を詰める段階では
#     必ずこの図を見ること。
#   - 赤い点がスペクトログラムの濃い帯（共鳴）の上に乗っていれば
#     正しい。帯から外れた点、帯を飛び越えている点が問題である。
#   - 点が上下に散らばる区間は、そこが無声か雑音である。
#     母音区間だけを切り出してから測るほうがよい。
#   - max_formant を変えて何枚か出し、いちばん素直に乗る値を選ぶ。
#     数値で確かめたいときは formant_ceiling_compare.praat を使う。

form Formant trajectory plot
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_folder
  positive Max_formant_hz 5500
  positive Spectrogram_max_hz 5000
  positive Dot_size_mm 1.2
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/formant_trajectory_plot/"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 抽出結果を数値だけで確かめるのは難しい。スペクトログラムに重ねると、
# 追跡が外れている箇所が一目で分かる。設定を詰める段階では必ず目で見ること。

createDirectory: output_folder$
Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  stem$ = f$ - ".wav"
  snd = Read from file: input_folder$ + f$

  Erase all
  Select outer viewport: 0, 6, 0, 4
  spec = To Spectrogram: 0.005, spectrogram_max_hz, 0.002, 20, "Gaussian"
  Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "no"

  selectObject: snd
  formant = To Formant (burg): 0, 5, max_formant_hz, 0.025, 50
  Colour: "Red"
  Speckle: 0, 0, spectrogram_max_hz, 30, "no"

  Colour: "Black"
  Marks bottom every: 1, 0.1, "yes", "yes", "no"
  Marks left every: 1, 1000, "yes", "yes", "no"
  Text bottom: "yes", "時間 (s)"
  Text left: "yes", "周波数 (Hz)"
  Draw inner box

  Save as PDF file: output_folder$ + stem$ + ".pdf"
  removeObject: spec, formant, snd
endfor

removeObject: list
appendInfoLine: "作図 ", n, " 件 → ", output_folder$
