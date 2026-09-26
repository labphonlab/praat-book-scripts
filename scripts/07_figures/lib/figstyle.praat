# figstyle.praat — 投稿用図版の体裁と書き出し
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集（論文図版編）
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# ── 寸法プリセットについての注意 ──────────────────────
# ここに入れてある幅は、学術誌で広く使われている値である。
# ただし投稿規定は雑誌ごとに違い、改訂もされる。
# 「この設定なら規定に適合する」とは保証しない。
# 投稿先の Author Guidelines で必ず現行の値を確認すること。
#
#   single   84 mm (3.31 in)  1段組の幅としてよく使われる値
#   onehalf 129 mm (5.08 in)  1.5段
#   double  174 mm (6.85 in)  2段抜き
#
# 高さは幅に対する比で指定する（既定 0.75）。

# 多パネル図では、パネルを正方形に近づけるために先に幅だけ知りたい。
procedure fig_width: .preset$
  if .preset$ = "single"
    .in = 3.31
  elsif .preset$ = "onehalf"
    .in = 5.08
  elsif .preset$ = "double"
    .in = 6.85
  else
    exitScript: "不明なプリセット: ", .preset$
  endif
endproc

procedure fig_begin: .preset$, .aspect
  Erase all
  if .preset$ = "single"
    .width_in = 3.31
  elsif .preset$ = "onehalf"
    .width_in = 5.08
  elsif .preset$ = "double"
    .width_in = 6.85
  else
    exitScript: "不明なプリセット: ", .preset$, " (single / onehalf / double)"
  endif
  .height_in = .width_in * .aspect
  Select outer viewport: 0, .width_in, 0, .height_in
  # 幅が狭いほど文字は相対的に大きく見える。段組幅に応じて字を調整する。
  if .preset$ = "single"
    .font_size = 8
    .line_width = 0.7
  elsif .preset$ = "onehalf"
    .font_size = 9
    .line_width = 0.8
  else
    .font_size = 10
    .line_width = 1.0
  endif
  Times
  Font size: .font_size
  Line width: .line_width
  Colour: "Black"
endproc

# 同じ図を複数の形式で書き出す。
#   PDF  ベクタ。フォントを埋め込む。原稿に貼るならこれ。
#   EPS  ベクタ。古い投稿系で要求されることがある。
#        フォントは埋め込まれず PostScript の標準フォントを参照する。
#        受け取り側に Times が無いと置き換わるので、PDFがあるならPDFを優先する。
#   PNG  ラスタ。600 dpi で出す。査読用や発表資料向け。
procedure fig_export: .basename$
  createDirectory: .basename$ - (right$(.basename$,
  ... length(.basename$) - rindex(.basename$, "/") + 1))
  Save as PDF file: .basename$ + ".pdf"
  Save as EPS file: .basename$ + ".eps"
  Save as 600-dpi PNG file: .basename$ + ".png"
  appendInfoLine: "  書き出し: ", .basename$, ".pdf / .eps / .png (600 dpi)"
  appendInfoLine: "  TIFFが要る場合は tools/to_tiff.sh を使う（Praatは TIFF を出力できない）"
endproc

# 軸の目盛りを控えめに引く。投稿図では目盛りを詰めすぎない。
procedure fig_axes: .xmin, .xmax, .ymin, .ymax, .xstep, .ystep, .xlab$, .ylab$
  Axes: .xmin, .xmax, .ymin, .ymax
  Draw inner box
  Marks bottom every: 1, .xstep, "yes", "yes", "no"
  Marks left every: 1, .ystep, "yes", "yes", "no"
  Text bottom: "yes", .xlab$
  Text left: "yes", .ylab$
endproc
