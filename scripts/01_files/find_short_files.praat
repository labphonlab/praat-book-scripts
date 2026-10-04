# find_short_files.praat
# 指定秒数以下の短いファイルを検出する
#
# 『Praatで学ぶ音声研究の方法』付録A-8（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。
#   Praat --run --FULL-TRUST find_short_files.praat <引数...>

# ── このスクリプトについて ───────────────────────────────
# 指定した秒数より短いファイルを洗い出す。
# 録音の失敗、切り出しの誤り、無音ファイルの混入を見つけるのに使う。
#
# 入力: WAVの入ったフォルダ
# 出力: short_files.csv
#   filename           ファイル名
#   duration_s         長さ（秒）
#   below_threshold    しきい値未満なら1
#
# 読み方・注意:
#   - 全ファイルを出力し、該当するものに印を付ける方式にしてある。
#     該当分だけを出すと「全体で何件中の何件か」が分からなくなる。
#   - しきい値は分析対象によって決める。母音1つなら0.05秒、
#     発話単位なら0.5秒あたりが出発点になる。

form Find short files
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  positive Threshold_s 0.5
  sentence Output_csv
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/find_short_files.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,duration_s,below_threshold"
n_short = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  removeObject: snd

  if dur < threshold_s
    flag = 1
    n_short = n_short + 1
  else
    flag = 0
  endif
  appendFileLine: output_csv$, f$, ",", fixed$(dur, 4), ",", flag
endfor

removeObject: list
appendInfoLine: "検査 ", n, " ファイル / ", threshold_s, " 秒未満: ", n_short, " ファイル"
appendInfoLine: "レポート: ", output_csv$
