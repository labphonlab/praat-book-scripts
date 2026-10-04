# script_8_1_filelist.praat
# Script 8.1：最小構成batch（全WAVのファイル名を表示する）
#
# 『Praatで学ぶ音声研究の方法』ch08掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

dir$ = "/Users/username/audio/"

Create Strings as file list: "fileList", dir$ + "*.wav"
selectObject: "Strings fileList"
n = Get number of strings
appendInfoLine: n, " 個のWAVファイルが見つかりました"

for i from 1 to n
  selectObject: "Strings fileList"
  filename$ = Get string: i
  appendInfoLine: i, ": ", filename$
endfor

# ← 必ずクリーンアップ
removeObject: "Strings fileList"
