# formant_manual_flag.praat
# 自動測定の疑わしい箇所に手動確認フラグを立てる
#
# 『Praatで学ぶ音声研究の方法』付録A-24（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# 自動測定の結果に、目視確認が要る箇所の印を付ける。
# 自動抽出をそのまま使わないための下ごしらえである。
#
# 入力: WAVの入ったフォルダ、妥当と考える範囲の上下限
# 出力: formant_manual_flag.csv
#   filename    ファイル名
#   f1_hz f2_hz 測定値（Hz）
#   b1_hz b2_hz 帯域幅（Hz）
#   flag        要確認なら1
#   reason      印を付けた理由（複数該当時は「;」で連結）
#
# 判定の基準:
#   測定不能    F1かF2が取れなかった
#   F1>=F2      順序が逆。ほぼ確実に取り違えである
#   F1範囲外    指定した妥当範囲の外
#   F2範囲外    同上
#   B1過大      帯域幅がF1に対して大きすぎる
#
# 読み方・注意:
#   - 既定の範囲は成人の一般的な母音を想定している。
#     子どもや歌唱では範囲を広げる必要がある。
#   - flag が立った件数は、論文の方法欄に書ける情報である。
#     「全体の何%を手動で確認した」と報告できる。
#   - 印は「間違っている」ではなく「確かめるべき」である。
#     確認せずに flag=1 の行を捨てると、特定の母音だけが
#     系統的に抜け落ちる。

form Formant extraction with manual-check flags
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Max_formant_hz 5500
  positive Measure_at_relative 0.5
  positive F1_plausible_min 200
  positive F1_plausible_max 1100
  positive F2_plausible_min 600
  positive F2_plausible_max 3000
  positive Max_bandwidth_ratio 0.5
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/formant_manual_flag.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 自動抽出の結果をそのまま使わないための下ごしらえである。
# フラグが立った行は目視・手動修正に回す。フラグ数を報告に書けるようにもなる。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,f1_hz,f2_hz,b1_hz,b2_hz,flag,reason"
n_flag = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  t = measure_at_relative * dur
  formant = To Formant (burg): 0, 5, max_formant_hz, 0.025, 50
  f1 = Get value at time: 1, t, "hertz", "linear"
  f2 = Get value at time: 2, t, "hertz", "linear"
  b1 = Get bandwidth at time: 1, t, "hertz", "linear"
  b2 = Get bandwidth at time: 2, t, "hertz", "linear"
  removeObject: formant, snd

  reason$ = ""
  if f1 = undefined or f2 = undefined
    reason$ = "測定不能"
  else
    if f1 >= f2
      reason$ = reason$ + "F1>=F2;"
    endif
    if f1 < f1_plausible_min or f1 > f1_plausible_max
      reason$ = reason$ + "F1範囲外;"
    endif
    if f2 < f2_plausible_min or f2 > f2_plausible_max
      reason$ = reason$ + "F2範囲外;"
    endif
    if b1 <> undefined and f1 > 0
      if b1 / f1 > max_bandwidth_ratio
        reason$ = reason$ + "B1過大;"
      endif
    endif
  endif

  if reason$ = ""
    flag = 0
    reason$ = "ok"
  else
    flag = 1
    n_flag = n_flag + 1
  endif

  appendFileLine: output_csv$, f$, ",",
  ... if f1 = undefined then "NA" else fixed$(f1,1) fi, ",",
  ... if f2 = undefined then "NA" else fixed$(f2,1) fi, ",",
  ... if b1 = undefined then "NA" else fixed$(b1,1) fi, ",",
  ... if b2 = undefined then "NA" else fixed$(b2,1) fi, ",", flag, ",", reason$
endfor

removeObject: list
appendInfoLine: "検査 ", n, " ファイル / 要確認 ", n_flag, " 件"
appendInfoLine: "レポート: ", output_csv$
