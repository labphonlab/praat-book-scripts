# script_8_2_duration.praat
# Script 8.2：duration一括計測（CSVに出力する）
#
# 『Praatで学ぶ音声研究の方法』ch08掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Duration Batch
  sentence Audio_folder audio/
  sentence Output_csv   results/durations.csv
endform

# ヘッダー（上書き）
writeFileLine: output_csv$, "filename,duration_s"

Create Strings as file list: "fileList", audio_folder$ + "*.wav"
selectObject: "Strings fileList"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings fileList"
  filename$ = Get string: i
  snd = Read from file: audio_folder$ + filename$
  dur = Get total duration
  appendFileLine: output_csv$, filename$ - ".wav", ",", fixed$(dur, 4)
  # ← ループ内で毎回削除する
  removeObject: snd
endfor

removeObject: "Strings fileList"
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
