# 10_1_textgrid_basics.praat
# 基本操作コマンド一覧
#
# 『Praatで学ぶ音声研究の方法』ch10掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

tg = Read from file: "textgrids/sp01_vowel.TextGrid"
selectObject: tg

; --- Tier情報 ---
n_tiers = Get number of tiers
for i from 1 to n_tiers
  selectObject: tg
  tier_name$ = Get tier name: i
  # IntervalTierなら1、TextTier（PointTier）なら0を返す
  is_interval = Is interval tier: i
  if is_interval = 1
    tier_type$ = "IntervalTier"
  else
    tier_type$ = "TextTier"
  endif
  appendInfoLine: "Tier ", i, ": ", tier_name$, " (", tier_type$, ")"
endfor

; --- IntervalTierの区間情報 ---
selectObject: tg
n_int  = Get number of intervals: 1
# Tier 1 の第3区間のラベル
label$ = Get label of interval: 1, 3
# 開始時刻
xmin   = Get start time of interval: 1, 3
# 終了時刻
xmax   = Get end time of interval:   1, 3
dur    = xmax - xmin

; --- 時刻から区間番号を逆引きする ---
# 0.5秒時点の区間番号
i_at      = Get interval at time: 1, 0.5
selectObject: tg
label_at$ = Get label of interval: 1, i_at

; --- TextTier（PointTier）の点情報 ---
n_pts    = Get number of points: 3
# Tier 3 の第1点の時刻
t_point  = Get time of point:  3, 1
# 第1点のラベル
mark$    = Get label of point: 3, 1

removeObject: tg
