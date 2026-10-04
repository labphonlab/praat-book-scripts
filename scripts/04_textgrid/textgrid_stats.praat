# textgrid_stats.praat
# TextGridの構成と注釈量を集計する
#
# 『Praatで学ぶ音声研究の方法』付録A-34（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# TextGridの構成と注釈量を層ごとに集計する。
# 注釈の進み具合の把握と、ファイル間の構成の食い違いの検出に使う。
#
# 入力: TextGridの入ったフォルダ
# 出力: textgrid_stats.csv（1ファイル×1層で1行）
#   filename        ファイル名
#   tier            層番号
#   tier_name       層名
#   tier_type       interval か point か
#   n_items         区間数（点層なら点の数）
#   n_labeled       ラベルが入っているものの数
#   labeled_ratio   n_labeled / n_items
#   duration_s      TextGridの時間領域の長さ
#
# 読み方・注意:
#   - 層数や層名がファイルごとに違うと、後段のバッチ処理が
#     黙って壊れる。tier_name を並べて確かめること。
#   - labeled_ratio は注釈の進み具合の目安になる。ただし
#     区間層では無音区間が空のままなのが正常な場合もある。
#   - duration_s が対応する音声の長さと違うなら、TextGridと音声が
#     対応していない。check_textgrid_pairs.praat で対応を確かめる。

form TextGrid statistics
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/textgrid_stats.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 注釈作業の進み具合や、ファイル間の構成の食い違いを把握するための集計である。
# 層数や層名がファイルごとに違っていると、後段のバッチ処理が黙って壊れる。

Create Strings as file list: "files", input_folder$ + "*.TextGrid"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,tier,tier_name,tier_type,n_items,n_labeled,labeled_ratio,duration_s"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  tg = Read from file: input_folder$ + f$
  tmin = Get start time
  tmax = Get end time
  n_tiers = Get number of tiers

  for t from 1 to n_tiers
    selectObject: tg
    nm$ = Get tier name: t
    is_interval = Is interval tier: t
    n_lab = 0
    if is_interval
      type$ = "interval"
      n_items = Get number of intervals: t
      for k from 1 to n_items
        lab$ = Get label of interval: t, k
        if lab$ <> ""
          n_lab = n_lab + 1
        endif
      endfor
    else
      type$ = "point"
      n_items = Get number of points: t
      for k from 1 to n_items
        lab$ = Get label of point: t, k
        if lab$ <> ""
          n_lab = n_lab + 1
        endif
      endfor
    endif
    if n_items > 0
      ratio$ = fixed$(n_lab / n_items, 4)
    else
      ratio$ = "NA"
    endif
    appendFileLine: output_csv$, f$, ",", t, ",", nm$, ",", type$, ",",
    ... n_items, ",", n_lab, ",", ratio$, ",", fixed$(tmax - tmin, 4)
  endfor
  removeObject: tg
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
