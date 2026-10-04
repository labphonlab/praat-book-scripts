# speech_rate_batch.praat
# Script 7.2：発話速度を一括計算する
#
# 『Praatで学ぶ音声研究の方法』ch07掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Speech Rate Calculation
  sentence Textgrid_folder textgrids/
  integer  Word_tier       2
  sentence Pause_labels    "<sil> <FP> <breath>"
  sentence Output_csv      results/speech_rate.csv
endform

writeFileLine: output_csv$,
  ... "file,total_dur_s,speech_dur_s,n_words,gross_rate,articulation_rate"

Create Strings as file list: "tgfiles", textgrid_folder$ + "*.TextGrid"
selectObject: "Strings tgfiles"
n_files = Get number of strings

for i from 1 to n_files
  selectObject: "Strings tgfiles"
  filename$ = Get string: i
  basename$ = filename$ - ".TextGrid"
  tg = Read from file: textgrid_folder$ + filename$
  selectObject: tg
  total_dur  = Get total duration
  n_int      = Get number of intervals: word_tier
  speech_dur = 0
  n_words    = 0

  for j from 1 to n_int
    selectObject: tg
    label$ = Get label of interval: word_tier, j
    xmin   = Get start time of interval: word_tier, j
    xmax   = Get end time of interval:   word_tier, j
    dur    = xmax - xmin

    ; 完全一致でポーズラベルを確認する（部分一致エラーを防ぐ）
    is_pause = index(" " + pause_labels$ + " ", " " + label$ + " ") > 0

    if label$ <> "" and not is_pause
      speech_dur = speech_dur + dur
      n_words    = n_words + 1
    endif
  endfor

  if total_dur > 0
    gross_rate$ = fixed$(n_words / total_dur, 3)
  else
    gross_rate$ = "NA"
  endif

  if speech_dur > 0
    artrate$ = fixed$(n_words / speech_dur, 3)
  else
    artrate$ = "NA"
  endif

  appendFileLine: output_csv$,
    ... basename$, ",", fixed$(total_dur, 3), ",", fixed$(speech_dur, 3), ",",
    ... n_words, ",", gross_rate$, ",", artrate$

  removeObject: tg
endfor

removeObject: "Strings tgfiles"
appendInfoLine: "完了: ", n_files, " ファイルを処理 → ", output_csv$
