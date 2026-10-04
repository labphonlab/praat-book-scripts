# reliability_inter.praat
# Script 5.2：inter-rater境界一致率スクリプト
#
# 『Praatで学ぶ音声研究の方法』Script 5.1掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Inter-rater Boundary Agreement
  sentence Rater1_folder textgrids/rater1/
  sentence Rater2_folder textgrids/rater2/
  integer  Tier           1
  real     Tolerance_ms   20
  sentence Output_csv     results/inter_rater_agreement.csv
endform

tolerance_s = tolerance_ms / 1000

writeFileLine: output_csv$,
  ... "file,n_boundaries_r1,n_boundaries_r2,n_matched,",
  ... "precision_pct,recall_pct,f1_pct,mae_ms,max_diff_ms"

Create Strings as file list: "r1files", rater1_folder$ + "*.TextGrid"
selectObject: "Strings r1files"
n_files = Get number of strings

n_total_matched = 0
n_total_r1      = 0
n_total_r2      = 0

for i from 1 to n_files
  selectObject: "Strings r1files"
  fn$ = Get string: i
  stem$ = fn$ - ".TextGrid"

  path_r1$ = rater1_folder$ + fn$
  path_r2$ = rater2_folder$ + fn$

  if fileReadable(path_r1$) and fileReadable(path_r2$)
    tg1 = Read from file: path_r1$
    tg2 = Read from file: path_r2$

    selectObject: tg1
    n1 = Get number of intervals: tier
    selectObject: tg2
    n2 = Get number of intervals: tier

    ; rater1・rater2の全境界時刻を取得する
    # 境界数 = 区間数 - 1（両端を除く）
    n_b1 = n1 - 1
    n_b2 = n2 - 1
    n_matched = 0
    sum_diff  = 0
    max_diff  = 0

    ; 許容範囲内にある全ての(rater1境界, rater2境界)候補ペアを距離とともに
    ; 列挙し、距離の昇順にソートしてから貪欲に確定させる。
    ; 境界インデックス順（時刻順）に貪欲マッチングすると、先に処理された
    ; 境界がより適切な相手を先取りしてしまい、後続の境界が本来マッチできた
    ; はずの相手を逃す場合がある。距離の昇順に処理することで、この
    ; 順序依存性を避け、より良い（ただし依然として厳密な最適解の保証は
    ; ない貪欲近似）マッチングが得られる
    candidates = Create Table with column names: "candidates", 0, "idx1 idx2 dist"
    for j from 2 to n1
      selectObject: tg1
      t1 = Get start time of interval: tier, j
      for k from 2 to n2
        selectObject: tg2
        t2 = Get start time of interval: tier, k
        d = abs(t1 - t2)
        if d <= tolerance_s
          selectObject: candidates
          Append row
          nrow = Get number of rows
          Set numeric value: nrow, "idx1", j
          Set numeric value: nrow, "idx2", k
          Set numeric value: nrow, "dist", d
        endif
      endfor
    endfor

    selectObject: candidates
    Sort rows: "dist"
    n_cand = Get number of rows

    ; rater1・rater2それぞれの境界が使用済みかを記録する表
    ; これがないと1個の境界に複数の相手境界が対応してしまい
    ; 一致率が水増しされる（多対1マッチングの誤り）
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
        n_matched = n_matched + 1
        ; このペアを使用済みとして以後の候補から除外する（1対1対応）
        selectObject: used1
        Set numeric value: j, "flag", 1
        selectObject: used2
        Set numeric value: k, "flag", 1
        # ms単位（この差はマッチしたペアの絶対誤差＝MAEの構成要素）
        sum_diff = sum_diff + d * 1000
        if d * 1000 > max_diff
          max_diff = d * 1000
        endif
      endif
    endfor

    removeObject: candidates, used1, used2

    if n_b1 > 0 and n_b2 > 0
      # precision: rater1境界のうちマッチした割合
      precision = n_matched / n_b1
      # recall: rater2境界のうちマッチした割合
      recall    = n_matched / n_b2
      if precision + recall > 0
        f1 = 2 * precision * recall / (precision + recall)
      else
        f1 = 0
      endif
      precision_pct$ = fixed$(precision * 100, 1)
      recall_pct$    = fixed$(recall * 100, 1)
      f1_pct$        = fixed$(f1 * 100, 1)
      mae$           = if n_matched > 0 then fixed$(sum_diff / n_matched, 2) else "NA" fi
      max_diff$      = fixed$(max_diff, 2)
    else
      precision_pct$ = "NA"
      recall_pct$    = "NA"
      f1_pct$        = "NA"
      mae$           = "NA"
      max_diff$      = "NA"
    endif

    appendFileLine: output_csv$,
      ... stem$, ",", n_b1, ",", n_b2, ",",
      ... n_matched, ",", precision_pct$, ",", recall_pct$, ",",
      ... f1_pct$, ",", mae$, ",", max_diff$

    n_total_matched = n_total_matched + n_matched
    n_total_r1      = n_total_r1 + n_b1
    n_total_r2      = n_total_r2 + n_b2

    removeObject: tg1, tg2
  else
    appendInfoLine: "スキップ（一方のファイルなし）: ", stem$
  endif
endfor

removeObject: "Strings r1files"

if n_total_r1 > 0 and n_total_r2 > 0
  overall_precision = n_total_matched / n_total_r1
  overall_recall    = n_total_matched / n_total_r2
  if overall_precision + overall_recall > 0
    overall_f1 = 2 * overall_precision * overall_recall / (overall_precision + overall_recall)
  else
    overall_f1 = 0
  endif
  appendInfoLine: "=== 全体 precision: ", fixed$(overall_precision * 100, 1),
    ... "%　recall: ", fixed$(overall_recall * 100, 1),
    ... "%　F1: ", fixed$(overall_f1 * 100, 1),
    ... "%　（許容: ±", tolerance_ms, " ms）"
endif
appendInfoLine: "完了 → ", output_csv$
