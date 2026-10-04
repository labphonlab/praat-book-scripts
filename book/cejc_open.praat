# cejc_open.praat
# PraatでのCEJCファイルの読み込み
#
# 『Praatで学ぶ音声研究の方法』ch07掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

snd = Read from file: "cejc/wav/C001_007.wav"
tg  = Read from file: "cejc/textgrid/C001_007.TextGrid"
selectObject: snd
plusObject: tg
View & Edit
