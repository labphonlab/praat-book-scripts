# cejc_open.praat
# PraatでのCEJCファイルの読み込み
#
# 『Praatで学ぶ音声研究の方法』ch07掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

snd = Read from file: "cejc/wav/C001_007.wav"
tg  = Read from file: "cejc/textgrid/C001_007.TextGrid"
selectObject: snd
plusObject: tg
View & Edit
