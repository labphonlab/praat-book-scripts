# textgrid_label_count.praat
# TextGridの全ラベル出現頻度を集計する
#
# 『Praatで学ぶ音声研究の方法』付録A-27掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form TextGrid Label Count
  sentence Textgrid_folder /textgrid/
  sentence Target_tier phones
  sentence Output_csv results/label_counts.csv
endform

# ラベルと出現回数を格納する連想配列を模倣
n_labels = 0
for i from 1 to 200
  label_name$[i] = ""
  label_count[i] = 0
endfor

Create Strings as file list: "tgfiles", textgrid_folder$ + "*.TextGrid"
n_files = Get number of strings

for i from 1 to n_files
  selectObject: "Strings tgfiles"
  tgname$ = Get string: i
  Read from file: textgrid_folder$ + tgname$
  tg = selected("TextGrid")
  # tier名から番号を探す（この動作をする単独コマンドはない）
  n_tiers  = Get number of tiers
  tier_idx = 0
  for k from 1 to n_tiers
    tname$ = Get tier name: k
    if tname$ = target_tier$
      tier_idx = k
    endif
  endfor

  if tier_idx > 0
    n_int = Get number of intervals: tier_idx
    for j from 1 to n_int
      lbl$ = Get label of interval: tier_idx, j
      if lbl$ <> ""
        found = 0
        for k from 1 to n_labels
          if label_name$[k] = lbl$
            label_count[k] = label_count[k] + 1
            found = 1
          endif
        endfor
        if found = 0
          n_labels = n_labels + 1
          label_name$[n_labels] = lbl$
          label_count[n_labels] = 1
        endif
      endif
    endfor
  endif
  removeObject: tg
endfor

writeFileLine: output_csv$, "label,count"
for k from 1 to n_labels
  appendFileLine: output_csv$, label_name$[k], ",", label_count[k]
endfor
appendInfoLine: "集計完了: ", n_labels, " 種類のラベル"
