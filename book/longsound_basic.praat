# longsound_basic.praat
# 基本的な使い方
#
# 『Praatで学ぶ音声研究の方法』ch01掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

longSound = Open long sound file: "/path/to/corpus/speaker01.wav"
textGrid  = Read from file: "/path/to/corpus/speaker01.TextGrid"

# TextGridEditorで波形・スペクトログラムを確認
selectObject: longSound
plusObject: textGrid
View & Edit

# 使用後は削除
removeObject: longSound, textGrid
