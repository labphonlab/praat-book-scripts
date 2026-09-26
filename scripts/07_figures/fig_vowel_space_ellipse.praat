# fig_vowel_space_ellipse.praat — 信頼楕円つき母音空間図
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集（論文図版編）
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# ── 入力 ───────────────────────────────────────────────
# CSV。列名は指定できる。既定では vowel（群）・f1（縦軸）・f2（横軸）。
#
# ── 出力 ───────────────────────────────────────────────
# 同名で .pdf / .eps / .png（600 dpi）の3形式。
#
# ── 図の読み方 ─────────────────────────────────────────
# 楕円の意味は2種類あり、混同されやすい。
#   data … 母集団の p 割が入る範囲。標本を増やしても大きさは変わらない
#   mean … 母平均のありか。標本を増やすと小さくなる
# 図の説明文に、どちらを何%で描いたかを必ず書くこと。
# 楕円は2変量正規分布を仮定する。分布が歪んでいる群では実態とずれる。

include lib/figstyle.praat
include lib/ellipse.praat

form 信頼楕円つき母音空間図
  comment 空欄のまま OK で data/vowels.csv を使います。
  sentence Input_csv
  sentence Output_basename
  word Group_column vowel
  word X_column f2
  word Y_column f1
  comment 楕円の種類  data=データの散らばり / mean=平均の信頼域
  optionmenu 楕円の種類: 1
    option data
    option mean
  positive 信頼水準 0.95
  comment 段組  single=84mm / onehalf=129mm / double=174mm
  optionmenu 段組: 1
    option single
    option onehalf
    option double
  boolean 点も描く 1
  comment 軸を手で決めるときだけ入力（0のままなら自動）
  real 横軸最小 0
  real 横軸最大 0
  real 縦軸最小 0
  real 縦軸最大 0
endform

pbs$ = defaultDirectory$
if input_csv$ = ""
  input_csv$ = pbs$ + "/../../results/figures/vowels.csv"
endif
if output_basename$ = ""
  output_basename$ = pbs$ + "/../../results/figures/vowel_space_ellipse"
endif
etype$ = 楕円の種類$
preset$ = 段組$

if not fileReadable(input_csv$)
  exitScript: "CSVが読めない: ", input_csv$, newline$,
  ... "先に make_sample_csv.praat を実行するか、自分のCSVを指定すること。"
endif

tbl = Read Table from comma-separated file: input_csv$
n = Get number of rows

# --- 軸の範囲をデータから決める（余白15%）-----------------------
xmin = 1e9
xmax = -1e9
ymin = 1e9
ymax = -1e9
for r from 1 to n
  selectObject: tbl
  xv = Get value: r, x_column$
  yv = Get value: r, y_column$
  xmin = min(xmin, xv)
  xmax = max(xmax, xv)
  ymin = min(ymin, yv)
  ymax = max(ymax, yv)
endfor
# 楕円は点の外側まで広がるので、余白は点の範囲だけでは足りない。
# 20%取っておき、足りなければフォームで直接指定する。
xpad = (xmax - xmin) * 0.20
ypad = (ymax - ymin) * 0.20
xmin = xmin - xpad
xmax = xmax + xpad
ymin = ymin - ypad
ymax = ymax + ypad
if 横軸最小 <> 0 or 横軸最大 <> 0
  xmin = 横軸最小
  xmax = 横軸最大
endif
if 縦軸最小 <> 0 or 縦軸最大 <> 0
  ymin = 縦軸最小
  ymax = 縦軸最大
endif

@fig_begin: preset$, 0.95
# 母音空間図は両軸を反転する。左上が /i/、右下が /a/ となり、
# 図の配置が舌の位置（前後・高低）に対応する。音声学の慣習である。
@fig_axes: xmax, xmin, ymax, ymin,
... (xmax - xmin) / 4, (ymax - ymin) / 4,
... x_column$ + " (Hz)", y_column$ + " (Hz)"

# --- 群の一覧 ----------------------------------------------------
groups$ = ""
for r from 1 to n
  selectObject: tbl
  g$ = Get value: r, group_column$
  if index(groups$, "<" + g$ + ">") = 0
    groups$ = groups$ + "<" + g$ + ">"
  endif
endfor

colours$# = {"Blue", "Red", "Green", "Magenta", "Maroon", "Navy"}
gi = 0
report$ = output_basename$ + "_ellipses.csv"
createDirectory: output_basename$ - (right$(output_basename$,
... length(output_basename$) - rindex(output_basename$, "/") + 1))
writeFileLine: report$, "group,n,mean_x,mean_y,semi_major,semi_minor,angle_deg,type,level"

rest$ = groups$
while index(rest$, "<") > 0
  s_i = index(rest$, "<")
  e_i = index(rest$, ">")
  g$ = mid$(rest$, s_i + 1, e_i - s_i - 1)
  rest$ = right$(rest$, length(rest$) - e_i)
  gi = gi + 1
  Colour: colours$# [(gi - 1) mod size(colours$#) + 1]

  # この群の点を集める
  cnt = 0
  for r from 1 to n
    selectObject: tbl
    gg$ = Get value: r, group_column$
    if gg$ = g$
      cnt = cnt + 1
    endif
  endfor
  ex# = zero# (cnt)
  ey# = zero# (cnt)
  j = 0
  for r from 1 to n
    selectObject: tbl
    gg$ = Get value: r, group_column$
    if gg$ = g$
      j = j + 1
      ex# [j] = Get value: r, x_column$
      ey# [j] = Get value: r, y_column$
    endif
  endfor

  if 点も描く
    for k from 1 to cnt
      Paint circle (mm): colours$# [(gi - 1) mod size(colours$#) + 1],
      ... ex# [k], ey# [k], 0.7
    endfor
  endif

  @ellipse_from_points: cnt, etype$, 信頼水準
  if ellipse_from_points.ok
    @ellipse_draw: ellipse_from_points.mx, ellipse_from_points.my,
    ... ellipse_from_points.a, ellipse_from_points.b,
    ... ellipse_from_points.theta, 72
    Text special: ellipse_from_points.mx, "centre", ellipse_from_points.my, "half",
    ... "Times", 9, "0", g$
    appendFileLine: report$, g$, ",", cnt, ",",
    ... fixed$(ellipse_from_points.mx, 1), ",", fixed$(ellipse_from_points.my, 1), ",",
    ... fixed$(ellipse_from_points.a, 1), ",", fixed$(ellipse_from_points.b, 1), ",",
    ... fixed$(ellipse_from_points.theta * 180 / pi, 2), ",", etype$, ",", 信頼水準
  else
    appendFileLine: report$, g$, ",", cnt, ",NA,NA,NA,NA,NA,", etype$, ",", 信頼水準
    appendInfoLine: "  群 ", g$, " は点が少なく楕円を引けない（", cnt, " 点）"
  endif
endwhile

Colour: "Black"
@fig_export: output_basename$
removeObject: tbl

appendInfoLine: ""
appendInfoLine: "楕円の諸元: ", report$
appendInfoLine: "図の説明に書くこと: ", fixed$(100 * 信頼水準, 0), "% ",
... if etype$ = "data" then "データ楕円（母集団の散らばり）" else "平均の信頼楕円" fi
