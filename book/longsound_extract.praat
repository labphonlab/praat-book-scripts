# longsound_extract.praat
# 区間を抽出してSoundとして処理する（省メモリパターン）
#
# 『Praatで学ぶ音声研究の方法』ch01掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

longSound = Open long sound file: "corpus.wav"

# 30〜60秒の区間のみを抽出
selectObject: longSound
segment = Extract part: 30.0, 60.0, "no"

# 通常のSoundとして処理（例：F0抽出）
selectObject: segment
To Pitch: 0.0, 75, 300
pit = selected("Pitch")
f0_mean = Get mean: 0, 0, "Hertz"
appendInfoLine: "F0平均: ", f0_mean, " Hz"

# 処理後は即座に削除（省メモリ）
removeObject: pit, segment
removeObject: longSound
