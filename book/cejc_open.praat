# cejc_open.praat
# PraatでのCEJCファイルの読み込み
#
# 『Praatで学ぶ音声研究の方法』ch07掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

snd = Read from file: "cejc/wav/C001_001_IC01.wav"
tg  = Read from file: "cejc/intonation/C001_001_IC01-xjtobi.TextGrid"
selectObject: snd
plusObject: tg
View & Edit
