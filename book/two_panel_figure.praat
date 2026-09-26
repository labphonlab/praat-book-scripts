# two_panel_figure.praat
# Script 16.4：2パネル図（スペクトログラム＋F0軌跡）
#
# 『Praatで学ぶ音声研究の方法』Script 16.2掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

sound = Read from file: "audio/sp01_sentence.wav"
tg    = Read from file: "textgrids/sp01_sentence.TextGrid"

selectObject: sound
specgram = To Spectrogram: 0.005, 8000, 0.002, 20, "Gaussian"

; Pitchの前にselectObject: soundを必ず実行する
selectObject: sound
pitch = To Pitch (ac): 0, 75, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, 300

Erase all
Font size: 10
Line width: 1

; === 上パネル：スペクトログラム（縦0〜6cm）===
Select outer viewport: 0, 15, 0, 6
selectObject: specgram
Paint: 0, 0, 0, 8000, 100, "yes", 60, 6, 0, "no"
selectObject: sound
plusObject: tg
Draw: 0, 0, "yes", "yes", "no"
Colour: "black"
Draw inner box
Marks left every: 1, 2000, "yes", "yes", "no"
Text left: "yes", "Frequency (Hz)"
; パネルラベル（左上）
Text: 0, "Left", 8000, "Bottom", "(a)"

; === 下パネル：F0軌跡（縦6〜10cm）===
Select outer viewport: 0, 15, 6, 10
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
Select outer viewport: 0, 15, 0, 10
Save as PDF file: "figures/two_panel.pdf"
appendInfoLine: "保存: figures/two_panel.pdf"

removeObject: sound, tg, specgram, pitch
