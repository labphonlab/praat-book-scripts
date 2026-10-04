# empty_interval_fill.praat
# 空の区間にラベルを埋める
#
# 『Praatで学ぶ音声研究の方法』付録A-30（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# 空ラベルの区間に、明示的なラベルを入れる。
# 「注釈し忘れ」と「意図的な無音」を区別できるようにする。
#
# 入力: TextGridの入ったフォルダ、対象の層、入れるラベル
# 出力: 書き換えたTextGrid、および fill_report.csv
#   filename      ファイル名
#   n_intervals   その層の全区間数
#   n_empty       空だった区間数
#   n_filled      実際に埋めた数（report_only時は0）
#
# 読み方・注意:
#   - まず report_only を1にして件数だけ見ること。
#     想定より多いなら、注釈作業自体に漏れがある。
#   - 空ラベルのまま集計すると、多くの処理が黙って無視する。
#     明示的なラベル（sil など）にしておけば、無音の長さや
#     出現位置を分析対象にできる。
#   - 埋めた後は元に戻せない。元のフォルダは残しておくこと。

form Fill empty intervals
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_folder
  positive Tier 1
  sentence Fill_label sil
  boolean Report_only 0
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/empty_interval_fill/"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 空ラベルは「注釈し忘れ」なのか「意図的な無音」なのか区別がつかない。
# 明示的なラベルに置き換えて、後段の集計で数えられるようにする。
# report_only を立てると書き換えずに件数だけ数える。

if not report_only
  createDirectory: output_folder$
endif
Create Strings as file list: "files", input_folder$ + "*.TextGrid"
list = selected("Strings")
n = Get number of strings
total_filled = 0

writeFileLine: output_folder$ + "fill_report.csv", "filename,n_intervals,n_empty,n_filled"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  tg = Read from file: input_folder$ + f$
  n_int = Get number of intervals: tier
  n_empty = 0

  for k from 1 to n_int
    selectObject: tg
    lab$ = Get label of interval: tier, k
    if lab$ = ""
      n_empty = n_empty + 1
      if not report_only
        Set interval text: tier, k, fill_label$
      endif
    endif
  endfor

  if report_only
    n_filled = 0
  else
    n_filled = n_empty
    selectObject: tg
    Save as text file: output_folder$ + f$
  endif
  total_filled = total_filled + n_filled

  appendFileLine: output_folder$ + "fill_report.csv", f$, ",", n_int, ",", n_empty, ",", n_filled
  removeObject: tg
endfor

removeObject: list
appendInfoLine: "処理 ", n, " ファイル / 埋めた区間 ", total_filled, " 件"
