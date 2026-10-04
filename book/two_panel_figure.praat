# two_panel_figure.praat
# Script 16.4：2パネル図（スペクトログラム＋F0軌跡）
#
# 『Praatで学ぶ音声研究の方法』Script 16.2掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

sound = Read from file: "audio/sp01_sentence.wav"

selectObject: sound
specgram = To Spectrogram: 0.005, 8000, 0.002, 20, "Gaussian"

; Pitchの前にselectObject: soundを必ず実行する
selectObject: sound
pitch = To Pitch (raw autocorrelation): 0, 75, 300, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14

Erase all
Font size: 10
Line width: 1

; === 上パネル：スペクトログラム（縦0〜2.4インチ）===
; TextGridは描かない。Sound+TextGridを対象にDrawを呼ぶと、
; そのウィンドウ独自の波形+ティア表示が別途描画され、
; 直前にPaintしたスペクトログラムと重なってしまう（実機で確認済み）
Select outer viewport: 0, 6, 0, 2.4
selectObject: specgram
Paint: 0, 0, 0, 8000, 100, "yes", 60, 6, 0, "no"
Colour: "black"
Draw inner box
Marks left every: 1, 2000, "yes", "yes", "no"
Text left: "yes", "Frequency (Hz)"
; パネルラベル（左上）
Text: 0, "Left", 8000, "Bottom", "(a)"

; === 下パネル：F0軌跡（縦2.4〜4インチ）===
Select outer viewport: 0, 6, 2.4, 4
selectObject: pitch
Draw: 0, 0, 50, 350, "no"
Colour: "black"
Draw inner box
Marks bottom every: 1, 0.1, "yes", "yes", "no"
Text bottom: "yes", "Time (s)"
Marks left every: 1, 100, "yes", "yes", "no"
Text left: "yes", "F0 (Hz)"
Text: 0, "Left", 350, "Bottom", "(b)"

; 全体を保存する（全パネルを含むviewportで保存する）
Select outer viewport: 0, 6, 0, 4
Save as PDF file: "figures/two_panel.pdf"
appendInfoLine: "保存: figures/two_panel.pdf"

removeObject: sound, specgram, pitch
