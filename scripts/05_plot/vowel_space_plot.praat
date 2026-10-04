# vowel_space_plot.praat
# 母音空間図（F1×F2）を描く
#
# 『Praatで学ぶ音声研究の方法』付録A-36（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# F1×F2平面に母音を配置した図（母音空間図）をPDFで描く。
#
# 入力: root/話者名/*.wav という構成のフォルダ
# 出力: 母音空間図のPDF 1枚（話者ごとに色分け）
#
# 読み方・注意:
#   - F1・F2とも軸を反転してある。こうすると左上が /i/、
#     右下が /a/ となり、図の配置が舌の位置（前後・高低）に対応する。
#     音声学の慣習であり、反転させない図は読み手を混乱させる。
#   - 母音記号はファイル名の最後の「_」以降から取る
#     （例: spk1_a.wav → a）。命名が違う場合はその1行を書き換える。
#   - 話者の声道長が違うと、同じ母音でも位置がずれる。
#     話者をまたいで比べるなら formant_lobanov.praat で
#     正規化した値を使うほうがよい。
#   - PDFはベクタ形式なので、拡大しても劣化しない。
#     論文の図としてそのまま使える。

form Vowel space plot
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Root_folder
  sentence Output_pdf
  positive Max_formant_hz 5500
  positive F1_max 1200
  positive F2_max 3000
  positive Measure_at_relative 0.5
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if root_folder$ = ""
  root_folder$ = pbs_root$ + "/sample/bySpeaker/"
endif
if output_pdf$ = ""
  output_pdf$ = pbs_root$ + "/results/vowel_space_plot.pdf"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 構成は root/話者名/*.wav を前提とする。
# 母音記号はファイル名の最後の「_」以降から取る（例: spk1_a.wav → a）。
# 慣習に合わない命名の場合はこの1行を書き換えること。
#
# 母音空間図では F1・F2 とも軸を反転させる。左上が /i/、右下が /a/ となり、
# 調音位置（前後・高低）と図の配置が対応するためである。

Create Strings as directory list: "dirs", root_folder$
dirs = selected("Strings")
n_spk = Get number of strings

Erase all
Select outer viewport: 0, 6, 0, 6
Axes: f2_max, 0, f1_max, 0
Draw inner box
Marks bottom every: 1, 500, "yes", "yes", "no"
Marks left every: 1, 200, "yes", "yes", "no"
Text bottom: "yes", "F2 (Hz)"
Text left: "yes", "F1 (Hz)"
Text top: "no", "母音空間"

colours$# = {"Blue", "Red", "Green", "Magenta", "Maroon", "Navy"}
n_pts = 0

for s from 1 to n_spk
  selectObject: dirs
  spk$ = Get string: s
  ci = (s - 1) mod size(colours$#) + 1
  Colour: colours$# [ci]

  Create Strings as file list: "wavs", root_folder$ + spk$ + "/*.wav"
  wavs = selected("Strings")
  nf = Get number of strings

  for i from 1 to nf
    selectObject: wavs
    f$ = Get string: i
    stem$ = f$ - ".wav"
    # 最後の "_" 以降を母音記号とみなす
    vowel$ = stem$
    pos = index_regex(stem$, "_[^_]*$")
    if pos > 0
      vowel$ = mid$(stem$, pos + 1, length(stem$) - pos)
    endif

    snd = Read from file: root_folder$ + spk$ + "/" + f$
    dur = Get total duration
    formant = To Formant (burg): 0, 5, max_formant_hz, 0.025, 50
    f1 = Get value at time: 1, measure_at_relative * dur, "hertz", "linear"
    f2 = Get value at time: 2, measure_at_relative * dur, "hertz", "linear"
    removeObject: formant, snd

    if f1 <> undefined and f2 <> undefined
      Text special: f2, "centre", f1, "half", "Helvetica", 14, "0", vowel$
      n_pts = n_pts + 1
    endif
  endfor
  removeObject: wavs
endfor

Colour: "Black"
Save as PDF file: output_pdf$
removeObject: dirs
appendInfoLine: "描画 ", n_pts, " 点 / ", n_spk, " 話者 → ", output_pdf$
