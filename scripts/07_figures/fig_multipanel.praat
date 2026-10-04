# fig_multipanel.praat — 多パネル図（話者別・条件別に並べる）
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集（論文図版編）
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.
#
# ── 何をするか ─────────────────────────────────────────
# CSVを1つの列（既定は speaker）でパネルに分け、格子状に並べる。
# 各パネルの中は、もう1つの列（既定は vowel）で色分けし、信頼楕円を引く。
#
# ── 出力 ───────────────────────────────────────────────
# 同名で .pdf / .eps / .png（600 dpi）
#
# ── 多パネル図の作法 ───────────────────────────────────
#   - 全パネルで軸の範囲を揃える。パネルごとに変えると、
#     大きさの違いが見た目の違いに化けて読み手を誤らせる。
#   - 目盛りラベルは左端の列と下端の行だけに置く。全パネルに置くと
#     図が字で埋まる。このスクリプトはそうしている。
#   - パネル記号 (a) (b) (c) を付ける。本文から参照できるようにするため。

include lib/figstyle.praat
include lib/ellipse.praat

form 多パネル図
  comment 空欄のまま OK で data/vowels.csv を使います。
  sentence Input_csv
  sentence Output_basename
  word Panel_column speaker
  word Group_column vowel
  word X_column f2
  word Y_column f1
  comment 楕円の種類  data=データの散らばり / mean=平均の信頼域 / none=描かない
  optionmenu 楕円の種類: 1
    option data
    option mean
    option none
  positive 信頼水準 0.95
  comment 段組  single=84mm / onehalf=129mm / double=174mm
  optionmenu 段組: 3
    option single
    option onehalf
    option double
  natural 列数 0
endform

pbs$ = defaultDirectory$
if input_csv$ = ""
  input_csv$ = pbs$ + "/../../results/figures/vowels.csv"
endif
if output_basename$ = ""
  output_basename$ = pbs$ + "/../../results/figures/multipanel"
endif
etype$ = 楕円の種類$
preset$ = 段組$

if not fileReadable(input_csv$)
  exitScript: "CSVが読めない: ", input_csv$
endif
tbl = Read Table from comma-separated file: input_csv$
n = Get number of rows

# --- パネルの一覧 ------------------------------------------------
panels$ = ""
n_panel = 0
for r from 1 to n
  selectObject: tbl
  p$ = Get value: r, panel_column$
  if index(panels$, "<" + p$ + ">") = 0
    panels$ = panels$ + "<" + p$ + ">"
    n_panel = n_panel + 1
  endif
endfor
if 列数 = 0
  n_col = ceiling(sqrt(n_panel))
else
  n_col = 列数
endif
n_row = ceiling(n_panel / n_col)

# --- 全パネル共通の軸範囲 ---------------------------------------
# パネルごとに軸を変えると、散らばりの違いが見えなくなる。必ず揃える。
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
xpad = (xmax - xmin) * 0.20
ypad = (ymax - ymin) * 0.20
xmin = xmin - xpad
xmax = xmax + xpad
ymin = ymin - ypad
ymax = ymax + ypad

# パネルが正方形に近くなるように、全体の高さを幅から決める。
# 縦横比を決め打ちにすると、パネル数によって極端に扁平な図になる。
@fig_width: preset$
left_margin = 0.62
bottom_margin = 0.52
panel_w0 = (fig_width.in - left_margin) / n_col
aspect = (bottom_margin + panel_w0 * n_row + 0.18) / fig_width.in
@fig_begin: preset$, aspect
total_w = fig_begin.width_in
total_h = fig_begin.height_in
panel_w = (total_w - left_margin) / n_col
bottom_margin_top = 0.14
panel_h = (total_h - bottom_margin - bottom_margin_top) / n_row

colours$# = {"Blue", "Red", "Green", "Magenta", "Maroon", "Navy"}
labels$# = {"(a)", "(b)", "(c)", "(d)", "(e)", "(f)", "(g)", "(h)", "(i)"}

report$ = output_basename$ + "_ellipses.csv"
createDirectory: output_basename$ - (right$(output_basename$,
... length(output_basename$) - rindex(output_basename$, "/") + 1))
writeFileLine: report$, "panel,group,n,mean_x,mean_y,semi_major,semi_minor,angle_deg,type,level"

pi_ = 0
rest$ = panels$
while index(rest$, "<") > 0
  s_i = index(rest$, "<")
  e_i = index(rest$, ">")
  p$ = mid$(rest$, s_i + 1, e_i - s_i - 1)
  rest$ = right$(rest$, length(rest$) - e_i)
  pi_ = pi_ + 1
  col = (pi_ - 1) mod n_col + 1
  row = (pi_ - 1) div n_col + 1

  x0 = left_margin + (col - 1) * panel_w
  # 1行目を上に置く（row=1 が最上段）
  y0 = bottom_margin_top + (n_row - row) * panel_h
  Select outer viewport: x0, x0 + panel_w, y0, y0 + panel_h
  Axes: xmax, xmin, ymax, ymin
  Draw inner box
  # 目盛りは外周だけ
  if row = n_row
    Marks bottom every: 1, (xmax - xmin) / 2, "yes", "yes", "no"
  else
    Marks bottom every: 1, (xmax - xmin) / 2, "no", "yes", "no"
  endif
  if col = 1
    Marks left every: 1, (ymax - ymin) / 3, "yes", "yes", "no"
  else
    Marks left every: 1, (ymax - ymin) / 3, "no", "yes", "no"
  endif
  Text top: "no", labels$# [min(pi_, size(labels$#))] + " " + p$

  # --- パネル内の群 ---
  groups$ = ""
  for r from 1 to n
    selectObject: tbl
    pp$ = Get value: r, panel_column$
    if pp$ = p$
      g$ = Get value: r, group_column$
      if index(groups$, "<" + g$ + ">") = 0
        groups$ = groups$ + "<" + g$ + ">"
      endif
    endif
  endfor

  gi = 0
  grest$ = groups$
  while index(grest$, "<") > 0
    gs = index(grest$, "<")
    ge = index(grest$, ">")
    g$ = mid$(grest$, gs + 1, ge - gs - 1)
    grest$ = right$(grest$, length(grest$) - ge)
    gi = gi + 1
    col$ = colours$# [(gi - 1) mod size(colours$#) + 1]
    Colour: col$

    cnt = 0
    for r from 1 to n
      selectObject: tbl
      pp$ = Get value: r, panel_column$
      gg$ = Get value: r, group_column$
      if pp$ = p$ and gg$ = g$
        cnt = cnt + 1
      endif
    endfor
    if cnt > 0
      ex# = zero# (cnt)
      ey# = zero# (cnt)
      j = 0
      for r from 1 to n
        selectObject: tbl
        pp$ = Get value: r, panel_column$
        gg$ = Get value: r, group_column$
        if pp$ = p$ and gg$ = g$
          j = j + 1
          ex# [j] = Get value: r, x_column$
          ey# [j] = Get value: r, y_column$
        endif
      endfor
      for k from 1 to cnt
        Paint circle (mm): col$, ex# [k], ey# [k], 0.6
      endfor
      if etype$ <> "none"
        @ellipse_from_points: cnt, etype$, 信頼水準
        if ellipse_from_points.ok
          @ellipse_draw: ellipse_from_points.mx, ellipse_from_points.my,
          ... ellipse_from_points.a, ellipse_from_points.b,
          ... ellipse_from_points.theta, 60
          appendFileLine: report$, p$, ",", g$, ",", cnt, ",",
          ... fixed$(ellipse_from_points.mx, 1), ",", fixed$(ellipse_from_points.my, 1), ",",
          ... fixed$(ellipse_from_points.a, 1), ",", fixed$(ellipse_from_points.b, 1), ",",
          ... fixed$(ellipse_from_points.theta * 180 / pi, 2), ",", etype$, ",", 信頼水準
        else
          appendFileLine: report$, p$, ",", g$, ",", cnt, ",NA,NA,NA,NA,NA,", etype$, ",", 信頼水準
        endif
      endif
    endif
  endwhile
endwhile

# --- 全体の軸名 --------------------------------------------------
Colour: "Black"
Select outer viewport: 0, total_w, 0, total_h
Axes: 0, 1, 0, 1
Text special: (left_margin + (total_w - left_margin) / 2) / total_w, "centre",
... 0.01, "bottom", "Times", fig_begin.font_size, "0", x_column$ + " (Hz)"
Text special: 0.008, "centre",
... (bottom_margin_top + (total_h - bottom_margin - bottom_margin_top) / 2) / total_h,
... "top", "Times", fig_begin.font_size, "90", y_column$ + " (Hz)"

@fig_export: output_basename$
removeObject: tbl

appendInfoLine: ""
appendInfoLine: "パネル ", n_panel, " 枚 (", n_row, "行 × ", n_col, "列)"
appendInfoLine: "楕円の諸元: ", report$
