# spectrogram_export.praat
# Script 16.1：スペクトログラム＋TextGrid overlay をPDFで出力する
#
# 『Praatで学ぶ音声研究の方法』ch16掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Spectrogram Export
  sentence Sound_file    audio/sp01_sentence.wav
  sentence Textgrid_file textgrids/sp01_sentence.TextGrid
  real     Window_length  0.005
  real     Dynamic_range  60
  real     Freq_max       8000
  real     Width_cm       15
  real     Height_cm       8
  sentence Output_pdf    figures/spectrogram.pdf
endform

sound = Read from file: sound_file$
tg    = Read from file: textgrid_file$
selectObject: sound
specgram = To Spectrogram: window_length, freq_max, 0.002, 20, "Gaussian"

Erase all
Font size: 10
Line width: 1
Select outer viewport: 0, width_cm, 0, height_cm

; スペクトログラム本体
selectObject: specgram
Paint: 0, 0, 0, freq_max, 100, "yes", dynamic_range, 6, 0, "no"

; TextGridオーバーレイ表示
selectObject: sound
plusObject: tg
Draw: 0, 0, "yes", "yes", "no"

; 軸・ラベル
Colour: "black"
Draw inner box
Marks bottom every: 1, 0.1, "yes", "yes", "no"
Text bottom: "yes", "Time (s)"
Marks left every: 1, 1000, "yes", "yes", "no"
Text left: "yes", "Frequency (Hz)"

Save as PDF file: output_pdf$
appendInfoLine: "保存: ", output_pdf$

removeObject: sound, tg, specgram
