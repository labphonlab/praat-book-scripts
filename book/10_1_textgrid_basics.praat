# 10_1_textgrid_basics.praat
# 基本操作コマンド一覧
#
# 『Praatで学ぶ音声研究の方法』ch10掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

tg = Read from file: "textgrids/sp01_vowel.TextGrid"
selectObject: tg

; --- Tier情報 ---
n_tiers = Get number of tiers
# 区間系のコマンドに使うIntervalTierの番号（付属データではphone tier＝第4層）
phone_tier = 4
# TextTierの番号（見つからなければ0のまま）
tone_tier = 0
for i from 1 to n_tiers
  selectObject: tg
  tier_name$ = Get tier name: i
  # IntervalTierなら1、TextTier（PointTier）なら0を返す
  is_interval = Is interval tier: i
  if is_interval = 1
    tier_type$ = "IntervalTier"
  else
    tier_type$ = "TextTier"
    tone_tier = i
  endif
  appendInfoLine: "Tier ", i, ": ", tier_name$, " (", tier_type$, ")"
endfor

; --- IntervalTierの区間情報 ---
selectObject: tg
n_int  = Get number of intervals: phone_tier
# phone tier の第3区間のラベル
label$ = Get label of interval: phone_tier, 3
# 開始時刻
xmin   = Get start time of interval: phone_tier, 3
# 終了時刻
xmax   = Get end time of interval:   phone_tier, 3
dur    = xmax - xmin

; --- 時刻から区間番号を逆引きする ---
# 0.5秒時点の区間番号
i_at      = Get interval at time: phone_tier, 0.5
selectObject: tg
label_at$ = Get label of interval: phone_tier, i_at

; --- TextTier（PointTier）の点情報 ---
# 付属のsp01_vowel.TextGridにはTextTierがないので、TextTierがある場合だけ実行する
if tone_tier > 0
  selectObject: tg
  n_pts    = Get number of points: tone_tier
  # TextTier の第1点の時刻
  t_point  = Get time of point:  tone_tier, 1
  # 第1点のラベル
  mark$    = Get label of point: tone_tier, 1
endif

removeObject: tg
