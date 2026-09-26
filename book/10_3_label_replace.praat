# 10_3_label_replace.praat
# Script 10.3：ラベルの一括修正スクリプト
#
# 『Praatで学ぶ音声研究の方法』ch10掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Label Replace Batch
  sentence Textgrid_folder    textgrids/
  sentence Output_folder      textgrids_fixed/
  integer  Tier               1
  sentence Old_label          sp
  sentence New_label          sil
endform

Create Strings as file list: "tgfiles", textgrid_folder$ + "*.TextGrid"
selectObject: "Strings tgfiles"
n = Get number of strings
n_replaced = 0

for i from 1 to n
  selectObject: "Strings tgfiles"
  fn$ = Get string: i
  tg  = Read from file: textgrid_folder$ + fn$
  selectObject: tg
  n_int = Get number of intervals: tier

  for j from 1 to n_int
    selectObject: tg
    label$ = Get label of interval: tier, j
    if label$ = old_label$
      # ← ラベルを書き換える
      Set interval text: tier, j, new_label$
      n_replaced = n_replaced + 1
    endif
  endfor

  selectObject: tg
  # 別フォルダに保存
  Save as text file: output_folder$ + fn$
  removeObject: tg
endfor

removeObject: "Strings tgfiles"
appendInfoLine: "完了: ", n, " ファイル / ", n_replaced, " 箇所を置換 → ", output_folder$
