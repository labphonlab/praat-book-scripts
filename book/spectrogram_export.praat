# spectrogram_export.praat
# Script 16.1：スペクトログラム＋TextGrid overlay をPDFで出力する
#
# 『Praatで学ぶ音声研究の方法』ch16掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Spectrogram Export
  sentence Sound_file    audio/sp01_sentence.wav
  sentence Textgrid_file textgrids/sp01_sentence.TextGrid
  real     Window_length  0.005
  real     Dynamic_range  60
  real     Freq_max       8000
  real     Width_in        6
  real     Height_in       3.2
  sentence Output_pdf    figures/spectrogram.pdf
endform

sound = Read from file: sound_file$
tg    = Read from file: textgrid_file$
selectObject: sound
specgram = To Spectrogram: window_length, freq_max, 0.002, 20, "Gaussian"

Erase all
Font size: 10
Line width: 1

; スペクトログラム本体（上70%）。TextGridと同じviewportに
; SoundとTextGridを対象にDrawすると、そのウィンドウ独自の
; 波形＋ティア表示がPaintの上に重なって描かれてしまう（実機で確認済み）。
; そのためスペクトログラムとTextGridは別々のviewportに分けて描く
Select outer viewport: 0, width_in, 0, height_in * 0.7
selectObject: specgram
Paint: 0, 0, 0, freq_max, 100, "yes", dynamic_range, 6, 0, "no"
Colour: "black"
Draw inner box
Marks left every: 1, 1000, "yes", "yes", "no"
Text left: "yes", "Frequency (Hz)"

; TextGridオーバーレイ表示（下30%）。TextGrid単体を対象にすることで
; 余計な波形パネルを描かせない
Select outer viewport: 0, width_in, height_in * 0.7, height_in
selectObject: tg
Draw: 0, 0, "yes", "yes", "no"
Colour: "black"
Marks bottom every: 1, 0.1, "yes", "yes", "no"
Text bottom: "yes", "Time (s)"

Select outer viewport: 0, width_in, 0, height_in
Save as PDF file: output_pdf$
appendInfoLine: "保存: ", output_pdf$

removeObject: sound, tg, specgram
