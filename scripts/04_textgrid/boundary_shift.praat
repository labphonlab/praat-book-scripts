# boundary_shift.praat
# 層の境界位置を一定量ずらす
#
# 『Praatで学ぶ音声研究の方法』付録A-29（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# 指定した層の境界位置を、一定量だけまとめてずらす。
# 自動アライメントに系統的なずれがあるときの一括補正に使う。
#
# 入力: TextGridの入ったフォルダ、対象の層番号、ずらす秒数
# 出力: 補正済みTextGrid（別フォルダ）
#
# 読み方・注意:
#   - Praatには境界を直接動かすコマンドが無い。このスクリプトは
#     新しいTextGridを組み直している。層の構成（層名・区間層か点層か）
#     は引き継がれる。
#   - ずらした結果が時間領域の外に出る境界は飛ばし、件数を報告する。
#     報告された件数が多いなら、ずらし量が大きすぎる。
#   - 系統的なずれかどうかは、まず何件かを手で測って確かめること。
#     ずれがランダムなら、一律の補正はかえって悪化させる。
#   - 補正量の根拠（何件測って平均何ミリ秒だったか）は記録に残す。

form Shift boundaries
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_folder
  positive Tier 1
  real Shift_s 0.01
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/boundary_shift/"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 自動アライメントに系統的なずれがある場合の一括補正を想定する。
# Praatには境界を直接動かすコマンドが無いので、新しいTextGridを組み直す。
# ずらした結果が区間の順序を壊す場合はその区間を飛ばし、件数を報告する。

createDirectory: output_folder$
Create Strings as file list: "files", input_folder$ + "*.TextGrid"
list = selected("Strings")
n = Get number of strings
n_skipped = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  tg = Read from file: input_folder$ + f$
  tmin = Get start time
  tmax = Get end time
  n_tiers = Get number of tiers

  # 層構成をそのまま引き継いだ空のTextGridを作る
  tier_names$ = ""
  point_names$ = ""
  for t from 1 to n_tiers
    selectObject: tg
    nm$ = Get tier name: t
    is_interval = Is interval tier: t
    tier_names$ = tier_names$ + nm$ + " "
    if not is_interval
      point_names$ = point_names$ + nm$ + " "
    endif
  endfor
  new = Create TextGrid: tmin, tmax, tier_names$, point_names$

  for t from 1 to n_tiers
    selectObject: tg
    is_interval = Is interval tier: t
    if is_interval
      n_int = Get number of intervals: t
      for k from 1 to n_int
        selectObject: tg
        bnd = Get end time of interval: t, k
        lab$ = Get label of interval: t, k
        # 最終区間の右端は領域の端なので動かさない
        if k < n_int
          if t = tier
            bnd = bnd + shift_s
          endif
          if bnd > tmin and bnd < tmax
            selectObject: new
            nowarn Insert boundary: t, bnd
          else
            n_skipped = n_skipped + 1
          endif
        endif
      endfor
      # 境界を入れ終えてからラベルを移す
      selectObject: new
      n_new = Get number of intervals: t
      for k from 1 to n_new
        selectObject: tg
        if k <= n_int
          lab$ = Get label of interval: t, k
          selectObject: new
          Set interval text: t, k, lab$
        endif
      endfor
    else
      n_pt = Get number of points: t
      for k from 1 to n_pt
        selectObject: tg
        pt = Get time of point: t, k
        lab$ = Get label of point: t, k
        if t = tier
          pt = pt + shift_s
        endif
        if pt > tmin and pt < tmax
          selectObject: new
          Insert point: t, pt, lab$
        else
          n_skipped = n_skipped + 1
        endif
      endfor
    endif
  endfor

  selectObject: new
  Save as text file: output_folder$ + f$
  removeObject: tg, new
endfor

removeObject: list
appendInfoLine: "処理 ", n, " ファイル / 領域外で飛ばした境界 ", n_skipped, " 件"
appendInfoLine: "出力: ", output_folder$
