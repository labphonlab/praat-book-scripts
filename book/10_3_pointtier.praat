# 10_3_pointtier.praat
# PointTierのイベントとIntervalTierの対応
#
# 『Praatで学ぶ音声研究の方法』ch10掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

tg = Read from file: "textgrids/sp01_prosody.TextGrid"
selectObject: tg

# PointTier: tones
tone_tier  = 3
# IntervalTier: phones
phone_tier = 1

n_pts = Get number of points: tone_tier

for i from 1 to n_pts
  selectObject: tg
  t_point = Get time of point:  tone_tier, i
  mark$   = Get label of point: tone_tier, i

  ; この時点が含まれるphone区間を取得
  phone_int    = Get interval at time: phone_tier, t_point
  phone_label$ = Get label of interval: phone_tier, phone_int

  appendInfoLine: "Tone [", mark$, "] t=", fixed$(t_point, 4),
    ... " → phone=[", phone_label$, "]"
endfor

removeObject: tg
