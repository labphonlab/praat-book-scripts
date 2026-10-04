# 10_1_interval_traversal.praat
# Script 10.1：全区間の反復処理テンプレート
#
# 『Praatで学ぶ音声研究の方法』ch10掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

tg = Read from file: "textgrids/sp01_vowel.TextGrid"
selectObject: tg

tier  = 1
n_int = Get number of intervals: tier

for i from 1 to n_int
  # ← 重要：毎回選択し直す
  selectObject: tg
  label$ = Get label of interval: tier, i
  xmin   = Get start time of interval: tier, i
  xmax   = Get end time of interval:   tier, i
  dur    = xmax - xmin

  # 空ラベルはスキップ
  if label$ <> ""
    appendInfoLine: i, ": [", label$, "] ",
      ... fixed$(xmin, 4), "〜", fixed$(xmax, 4),
      ... " (", fixed$(dur * 1000, 1), " ms)"
  endif
endfor

removeObject: tg
