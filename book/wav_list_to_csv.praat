# wav_list_to_csv.praat
# WAVファイル一覧をCSVに書き出す
#
# 『Praatで学ぶ音声研究の方法』付録A-1掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form WAV List to CSV
  sentence Input_folder /audio/
  sentence Output_csv results/wav_list.csv
endform

Create Strings as file list: "files", input_folder$ + "*.wav"
n = Get number of strings

header$ = "filename,channels,sample_rate,duration_s"
writeFileLine: output_csv$, header$

for i from 1 to n
  selectObject: "Strings files"
  filename$ = Get string: i
  Read from file: input_folder$ + filename$
  obj = selected("Sound")

  ch = Get number of channels
  sr = Get sampling frequency
  dur = Get total duration

  appendFileLine: output_csv$, filename$, ",", ch, ",", sr, ",", fixed$(dur, 4)

  removeObject: obj
endfor

appendInfoLine: "完了: ", n, " ファイルを処理しました"
