# annotated_spectrogram_pdf.praat
# 注釈付きスペクトログラムをPDFで一括出力する
#
# 『Praatで学ぶ音声研究の方法』付録A-35掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Annotated Spectrogram Batch
  sentence Audio_folder /audio/
  sentence Textgrid_folder /textgrid/
  sentence Output_folder results/figures/
  real Window_length 0.005
  real Dynamic_range 60
endform

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings wavfiles"
  wavname$ = Get string: i
  stem$ = wavname$ - ".wav"
  tgpath$ = textgrid_folder$ + stem$ + ".TextGrid"

  Read from file: audio_folder$ + wavname$
  snd = selected("Sound")

  ; 幅6インチ × 高さ2.5インチ（Picture Windowの単位はインチ）
  Select outer viewport: 0, 6, 0, 2.5
  Erase all

  selectObject: snd
  To Spectrogram: window_length, 5000, 0.002, 20, "Gaussian"
  spec = selected("Spectrogram")
  Paint: 0, 0, 0, 0, 100, "yes", dynamic_range, 6, 0, "no"
  removeObject: spec

  if fileReadable(tgpath$)
    Read from file: tgpath$
    tg = selected("TextGrid")
    selectObject: snd, tg
    Draw: 0, 0, "yes", "yes", "no"
    removeObject: tg
  endif

  Select inner viewport: 0, 6, 0, 2.5
  Save as PDF file: output_folder$ + stem$ + ".pdf"

  removeObject: snd
endfor

appendInfoLine: "PDF出力完了: ", n, " ファイル"
