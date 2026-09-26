# history_to_script.praat
# Historyの汎用化
#
# 『Praatで学ぶ音声研究の方法』ch09掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form F0 Mean Calculator
  sentence Sound_file /Users/username/audio/sp01_vowel.wav
  real     Floor       75
  real     Ceiling     300
endform

audio = Read from file: sound_file$
selectObject: audio
pitch = To Pitch (ac): 0, floor, 15, "no",
  ... 0.03, 0.45, 0.01, 0.35, 0.14, ceiling

selectObject: pitch
mean_f0 = Get mean: 0, 0, "Hertz"

f0_str$ = if mean_f0 <> undefined then fixed$(mean_f0, 2) else "NA" fi
appendInfoLine: "Mean F0: ", f0_str$, " Hz"

removeObject: audio, pitch
