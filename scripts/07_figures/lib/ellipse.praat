# ellipse.praat — 信頼楕円の計算と描画
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集（論文図版編）
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# Praat には信頼楕円を描くコマンドが無いので、共分散行列から自分で求める。
# 手順は次のとおり。
#
#   1. 2変数の標本共分散行列 S を作る
#   2. S の固有値 λ1 ≧ λ2 と、第1固有ベクトルの傾き θ を求める
#      （2×2 なので閉形式で解ける）
#   3. 半長軸 a = sqrt(λ1 * k)、半短軸 b = sqrt(λ2 * k)
#   4. 中心 (mx, my)、傾き θ の楕円として描く
#
# k の取り方で楕円の意味が変わる。混同しやすいので両方を用意した。
#
#   data     … データの散らばりを表す楕円。k = χ²(p, 2)
#              「母集団の p 割がこの中に入る」を表す（正規性を仮定）
#   mean     … 平均の信頼楕円。k = 2(n-1)/(n-2) * F(p, 2, n-2)
#              「母平均がこの中にある」を表す。n が増えると小さくなる
#
# 論文で「95%信頼楕円」と書かれた図の多くは data 楕円である。
# どちらを描いたかは図の説明に明記すること。

procedure ellipse_from_points: .n, .type$, .p
  # 呼び出す前に ex# と ey# に値を入れておくこと
  if .n < 3
    ellipse_from_points.ok = 0
    goto SKIP
  endif
  .mx = 0
  .my = 0
  for .i from 1 to .n
    .mx = .mx + ex# [.i]
    .my = .my + ey# [.i]
  endfor
  .mx = .mx / .n
  .my = .my / .n

  .sxx = 0
  .syy = 0
  .sxy = 0
  for .i from 1 to .n
    .dx = ex# [.i] - .mx
    .dy = ey# [.i] - .my
    .sxx = .sxx + .dx * .dx
    .syy = .syy + .dy * .dy
    .sxy = .sxy + .dx * .dy
  endfor
  .sxx = .sxx / (.n - 1)
  .syy = .syy / (.n - 1)
  .sxy = .sxy / (.n - 1)

  # 2×2 対称行列の固有値（閉形式）
  .tr = .sxx + .syy
  .det = .sxx * .syy - .sxy * .sxy
  .disc = sqrt(max(.tr * .tr / 4 - .det, 0))
  .lam1 = .tr / 2 + .disc
  .lam2 = .tr / 2 - .disc

  if .type$ = "data"
    .k = invChiSquareQ(1 - .p, 2)
  elsif .type$ = "mean"
    if .n <= 2
      ellipse_from_points.ok = 0
      goto SKIP
    endif
    .k = 2 * (.n - 1) / (.n * (.n - 2)) * invFisherQ(1 - .p, 2, .n - 2)
  else
    exitScript: "楕円の種類は data か mean: ", .type$
  endif

  .a = sqrt(max(.lam1, 0) * .k)
  .b = sqrt(max(.lam2, 0) * .k)
  if abs(.sxy) < 1e-12 and abs(.sxx - .syy) < 1e-12
    .theta = 0
  else
    .theta = 0.5 * arctan2(2 * .sxy, .sxx - .syy)
  endif
  ellipse_from_points.ok = 1
  label SKIP
endproc

# 楕円を折れ線で描く。segments を増やすと滑らかになる。
procedure ellipse_draw: .mx, .my, .a, .b, .theta, .segments
  .ct = cos(.theta)
  .st = sin(.theta)
  for .i from 0 to .segments - 1
    .t0 = 2 * pi * .i / .segments
    .t1 = 2 * pi * (.i + 1) / .segments
    .x0 = .mx + .a * cos(.t0) * .ct - .b * sin(.t0) * .st
    .y0 = .my + .a * cos(.t0) * .st + .b * sin(.t0) * .ct
    .x1 = .mx + .a * cos(.t1) * .ct - .b * sin(.t1) * .st
    .y1 = .my + .a * cos(.t1) * .st + .b * sin(.t1) * .ct
    Draw line: .x0, .y0, .x1, .y1
  endfor
endproc
