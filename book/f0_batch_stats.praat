# f0_batch_stats.praat
# F0の基本統計量を全ファイルで一括抽出する
#
# 『Praatで学ぶ音声研究の方法』付録A-11掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form F0 Batch Statistics
  sentence Audio_folder /audio/
  real Pitch_floor 75
  real Pitch_ceiling 300
  sentence Output_csv results/f0_stats.csv
endform

header$ = "filename,f0_mean,f0_sd,f0_min,f0_max,voiced_fraction"
writeFileLine: output_csv$, header$

Create Strings as file list: "files", audio_folder$ + "*.wav"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings files"
  filename$ = Get string: i
  Read from file: audio_folder$ + filename$
  snd = selected("Sound")
  To Pitch: 0, pitch_floor, pitch_ceiling
  pit = selected("Pitch")

  mean_f0 = Get mean: 0, 0, "Hertz"
  sd_f0   = Get standard deviation: 0, 0, "Hertz"
  min_f0  = Get minimum: 0, 0, "Hertz", "parabolic"
  max_f0  = Get maximum: 0, 0, "Hertz", "parabolic"
  n_frames = Get number of frames
  n_voiced = Count voiced frames
  vfrac    = n_voiced / n_frames

  if mean_f0 <> undefined
    appendFileLine: output_csv$,
      ... filename$, ",",
      ... fixed$(mean_f0, 2), ",",
      ... fixed$(sd_f0,   2), ",",
      ... fixed$(min_f0,  2), ",",
      ... fixed$(max_f0,  2), ",",
      ... fixed$(vfrac,   4)
  else
    appendFileLine: output_csv$, filename$, ",NA,NA,NA,NA,NA"
  endif

  removeObject: pit, snd
endfor
appendInfoLine: "F0統計完了: ", n, " ファイル"
