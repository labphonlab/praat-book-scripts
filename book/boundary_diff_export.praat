# boundary_diff_export.praat
# Script 5.3：境界位置差分のCSV出力
#
# 『Praatで学ぶ音声研究の方法』Script 5.1掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Boundary Difference Export
  sentence Rater1_textgrid textgrids/rater1/sp01.TextGrid
  sentence Rater2_textgrid textgrids/rater2/sp01.TextGrid
  integer  Tier            1
  sentence Output_csv      results/boundary_diffs.csv
endform

tg1 = Read from file: rater1_textgrid$
tg2 = Read from file: rater2_textgrid$

selectObject: tg1
n1 = Get number of intervals: tier
selectObject: tg2
n2 = Get number of intervals: tier

writeFileLine: output_csv$, "boundary_r1_s,nearest_r2_s,diff_ms,status"

; 全ての(rater1境界, rater2境界)候補ペアを距離とともに列挙し、
; 距離の昇順にソートしてから貪欲に1対1でマッチさせる
; （Script 5.2と同じ理由で、境界インデックス順の貪欲法は避ける）
candidates = Create Table with column names: "candidates", 0, "idx1 idx2 dist"
for j from 2 to n1
  selectObject: tg1
  t1 = Get start time of interval: tier, j
  for k from 2 to n2
    selectObject: tg2
    t2 = Get start time of interval: tier, k
    d = abs(t1 - t2)
    selectObject: candidates
    Append row
    nrow = Get number of rows
    Set numeric value: nrow, "idx1", j
    Set numeric value: nrow, "idx2", k
    Set numeric value: nrow, "dist", d
  endfor
endfor

selectObject: candidates
Sort rows: "dist"
n_cand = Get number of rows

used1 = Create Table with column names: "used1", n1, "flag"
selectObject: used1
for j from 1 to n1
  Set numeric value: j, "flag", 0
endfor

used2 = Create Table with column names: "used2", n2, "flag"
selectObject: used2
for k from 1 to n2
  Set numeric value: k, "flag", 0
endfor

; マッチ結果を保持する表（rater1境界のインデックスごとに対応するrater2の時刻・距離）
results = Create Table with column names: "results", n1, "t2 diff_ms matched"
selectObject: results
for j from 1 to n1
  Set numeric value: j, "matched", 0
endfor

for row from 1 to n_cand
  selectObject: candidates
  j = Get value: row, "idx1"
  k = Get value: row, "idx2"
  d = Get value: row, "dist"

  selectObject: used1
  flag1 = Get value: j, "flag"
  selectObject: used2
  flag2 = Get value: k, "flag"

  if flag1 = 0 and flag2 = 0
    selectObject: tg2
    t2 = Get start time of interval: tier, k

    selectObject: used1
    Set numeric value: j, "flag", 1
    selectObject: used2
    Set numeric value: k, "flag", 1

    selectObject: results
    Set numeric value: j, "t2", t2
    Set numeric value: j, "diff_ms", d * 1000
    Set numeric value: j, "matched", 1
  endif
endfor

for j from 2 to n1
  selectObject: tg1
  t1 = Get start time of interval: tier, j

  selectObject: results
  matched = Get value: j, "matched"

  if matched = 1
    nearest = Get value: j, "t2"
    diff_ms = Get value: j, "diff_ms"
    if diff_ms <= 5
      status$ = "excellent"
    elsif diff_ms <= 20
      status$ = "acceptable"
    else
      status$ = "poor"
    endif
    appendFileLine: output_csv$,
      ... fixed$(t1, 4), ",", fixed$(nearest, 4), ",",
      ... fixed$(diff_ms, 2), ",", status$
  else
    # rater2側に対応する境界が（他のより近いペアに使われて）残っていなかった場合
    appendFileLine: output_csv$,
      ... fixed$(t1, 4), ",NA,NA,unmatched"
  endif
endfor

removeObject: tg1, tg2, candidates, used1, used2, results
appendInfoLine: "差分データ出力完了 → ", output_csv$
appendInfoLine: ""
appendInfoLine: "=== 境界差分の簡易サマリー ==="

; Script 5.3の出力CSVを再読み込みして簡易集計する
summary_table = Read Table from comma-separated file: output_csv$
selectObject: summary_table
n_all = Get number of rows
# excellent (≤5ms)
n_exc = 0
# acceptable (≤20ms)
n_acc = 0
# poor (>20ms)
n_poor = 0
for i from 1 to n_all
  selectObject: summary_table
  status$ = Get value: i, "status"
  if status$ = "excellent"
    n_exc = n_exc + 1
  elsif status$ = "acceptable"
    n_acc = n_acc + 1
  else
    n_poor = n_poor + 1
  endif
endfor
removeObject: summary_table

appendInfoLine: "excellent (≤5ms):   ", n_exc,  " / ", n_all
appendInfoLine: "acceptable (≤20ms): ", n_acc,  " / ", n_all
appendInfoLine: "poor (>20ms):       ", n_poor, " / ", n_all
if n_all > 0
  appendInfoLine: "一致率 (≤20ms許容): ",
    ... fixed$((n_exc + n_acc) / n_all * 100, 1), "%"
endif
