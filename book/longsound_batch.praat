# longsound_batch.praat
# バッチ処理への応用
#
# 『Praatで学ぶ音声研究の方法』ch01掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

longSound = Open long sound file: "corpus.wav"
tg        = Read from file:       "corpus.TextGrid"

selectObject: tg
n_int = Get number of intervals: 1

writeFileLine: "results/output.csv", "label,duration_ms,f0_mean"

for i from 1 to n_int
  selectObject: tg
  label$ = Get label of interval: 1, i
  # 空ラベルはスキップ
  if label$ = ""
    goto skip
  endif

  xmin = Get start time of interval: 1, i
  xmax = Get end time of interval:   1, i
  # msに変換
  dur  = (xmax - xmin) * 1000

  selectObject: longSound
  segment = Extract part: xmin, xmax, "no"

  ; --- ここに音響処理を書く ---
  To Pitch: 0, 75, 300
  pit = selected("Pitch")
  f0  = Get mean: 0, 0, "Hertz"
  f0$ = if f0 <> undefined then fixed$(f0, 2) else "NA" fi

  appendFileLine: "results/output.csv",
    ... label$, ",", fixed$(dur, 1), ",", f0$

  # 毎ループで削除（メモリリーク防止）
  removeObject: pit, segment

  label skip
  ; （スキップ済み）
endfor

removeObject: longSound, tg
appendInfoLine: "処理完了: ", n_int, " 区間"
