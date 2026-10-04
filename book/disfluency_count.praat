# disfluency_count.praat
# Script 7.1：非流暢性の頻度を自動計測する
#
# 『Praatで学ぶ音声研究の方法』ch07掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Disfluency Frequency Count
  sentence Textgrid_folder textgrids/
  integer  Tier            1
  sentence Output_csv      results/disfluency.csv
endform

writeFileLine: output_csv$,
  ... "file,total_dur,n_words,n_FP,n_sil,n_rep,n_rpt,n_breath,",
  ... "FP_rate,sil_rate,total_disfluency_rate"

Create Strings as file list: "tgfiles", textgrid_folder$ + "*.TextGrid"
selectObject: "Strings tgfiles"
n_files = Get number of strings

for i from 1 to n_files
  selectObject: "Strings tgfiles"
  filename$ = Get string: i
  basename$ = filename$ - ".TextGrid"
  tg = Read from file: textgrid_folder$ + filename$
  selectObject: tg
  total_dur = Get total duration
  n_int     = Get number of intervals: tier

  n_words  = 0
  n_FP     = 0
  n_sil    = 0
  n_rep    = 0
  n_rpt    = 0
  n_breath = 0

  for j from 1 to n_int
    selectObject: tg
    label$ = Get label of interval: tier, j
    if label$ = "<FP>"
      n_FP = n_FP + 1
    elsif label$ = "<sil>"
      n_sil = n_sil + 1
    elsif label$ = "<REP>"
      n_rep = n_rep + 1
    elsif label$ = "<RPT>"
      n_rpt = n_rpt + 1
    elsif label$ = "<breath>"
      n_breath = n_breath + 1
    elsif label$ <> ""
      n_words = n_words + 1
    endif
  endfor

  total_tokens = n_words + n_FP + n_sil + n_rep + n_rpt + n_breath

  if total_tokens > 0
    fp_rate  = n_FP  / total_tokens
    sil_rate = n_sil / total_tokens
    dis_rate = (n_FP + n_sil + n_rep + n_rpt) / total_tokens
    fp_rate$  = fixed$(fp_rate,  4)
    sil_rate$ = fixed$(sil_rate, 4)
    dis_rate$ = fixed$(dis_rate, 4)
  else
    fp_rate$  = "NA"
    sil_rate$ = "NA"
    dis_rate$ = "NA"
  endif

  appendFileLine: output_csv$,
    ... basename$, ",", fixed$(total_dur, 3), ",", n_words, ",",
    ... n_FP, ",", n_sil, ",", n_rep, ",", n_rpt, ",", n_breath, ",",
    ... fp_rate$, ",", sil_rate$, ",", dis_rate$

  removeObject: tg
endfor

removeObject: "Strings tgfiles"
appendInfoLine: "完了: ", n_files, " ファイルを処理 → ", output_csv$
