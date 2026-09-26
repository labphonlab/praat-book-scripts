# label_replace.praat
# ラベルを一括置換する
#
# 『Praatで学ぶ音声研究の方法』付録A-32（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

# ── このスクリプトについて ───────────────────────────────
# 指定した層のラベルを一括で置き換える。表記の揺れを揃えるのに使う。
#
# 入力: TextGridの入ったフォルダ、対象の層、検索語、置換語
# 出力: 置換済みTextGrid、および replace_report.csv
#   filename     ファイル名
#   n_replaced   そのファイルでの置換件数
#
# 読み方・注意:
#   - 既定は「ラベル全体が一致したときだけ置換」である。
#     whole_label_only を0にすると部分一致になるが、
#     "a" が "sa" の中まで書き換わる。既定のまま使うのが安全。
#   - 置換の前に、textgrid_stats.praat でどんなラベルが
#     何件あるかを確かめること。想定外のラベルが混じっていることは多い。
#   - n_replaced の合計が想定と違うなら、その場で止めて原因を見る。
#     置換は元に戻せない。

form Replace labels
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_folder
  positive Tier 1
  sentence Search_for a
  sentence Replace_with A
  boolean Whole_label_only 1
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/label_replace/"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# whole_label_only を立てると、ラベル全体が一致したときだけ置換する。
# 部分一致で置換すると "a" が "sa" の中まで書き換わる。既定は全体一致。

createDirectory: output_folder$
Create Strings as file list: "files", input_folder$ + "*.TextGrid"
list = selected("Strings")
n = Get number of strings
total = 0

writeFileLine: output_folder$ + "replace_report.csv", "filename,n_replaced"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  tg = Read from file: input_folder$ + f$
  n_int = Get number of intervals: tier
  n_rep = 0

  for k from 1 to n_int
    selectObject: tg
    lab$ = Get label of interval: tier, k
    if whole_label_only
      if lab$ = search_for$
        Set interval text: tier, k, replace_with$
        n_rep = n_rep + 1
      endif
    else
      if index(lab$, search_for$) > 0
        new$ = replace$(lab$, search_for$, replace_with$, 0)
        Set interval text: tier, k, new$
        n_rep = n_rep + 1
      endif
    endif
  endfor

  selectObject: tg
  Save as text file: output_folder$ + f$
  removeObject: tg
  total = total + n_rep
  appendFileLine: output_folder$ + "replace_report.csv", f$, ",", n_rep
endfor

removeObject: list
appendInfoLine: "処理 ", n, " ファイル / 置換 ", total, " 件"
appendInfoLine: "「", search_for$, "」→「", replace_with$, "」"
