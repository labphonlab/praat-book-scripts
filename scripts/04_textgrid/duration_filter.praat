# duration_filter.praat
# 持続時間で区間を絞り込んで書き出す
#
# 『Praatで学ぶ音声研究の方法』付録A-33（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# 区間を持続時間で絞り込み、範囲内・範囲外を印付きで全件出力する。
#
# 入力: TextGridの入ったフォルダ、対象の層、下限・上限（秒）
# 出力: duration_filter.csv
#   filename     ファイル名
#   interval     区間番号
#   label        ラベル
#   start_s end_s duration_s  開始・終了・長さ（秒）
#   in_range     範囲内なら1
#
# 読み方・注意:
#   - 範囲外の行も出力する。該当分だけ出すと「何件を捨てたか」が
#     分からなくなる。除外件数は論文の方法欄に書くべき情報である。
#   - 極端に短い区間はアライメントの失敗であることが多い。
#     ただし本当に短い音（弾き音など）もある。捨てる前に
#     ラベルごとの分布を見ること。
#   - exclude_empty を1にすると空ラベルの区間を集計から外す。
#     空区間の長さ自体を分析したいときは0にする。

form Filter intervals by duration
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Tier 1
  real Min_duration_s 0.03
  real Max_duration_s 1.0
  boolean Exclude_empty 1
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/duration_filter.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 極端に短い区間はアライメントの失敗であることが多い。
# 分析から外す前に、まず何件あるかを数える。黙って捨てない。

Create Strings as file list: "files", input_folder$ + "*.TextGrid"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,interval,label,start_s,end_s,duration_s,in_range"
n_in = 0
n_out = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  tg = Read from file: input_folder$ + f$
  n_int = Get number of intervals: tier

  for k from 1 to n_int
    selectObject: tg
    lab$ = Get label of interval: tier, k
    if lab$ <> "" or not exclude_empty
      st = Get start time of interval: tier, k
      en = Get end time of interval: tier, k
      dur = en - st
      if dur >= min_duration_s and dur <= max_duration_s
        ok = 1
        n_in = n_in + 1
      else
        ok = 0
        n_out = n_out + 1
      endif
      appendFileLine: output_csv$, f$, ",", k, ",", lab$, ",",
      ... fixed$(st, 4), ",", fixed$(en, 4), ",", fixed$(dur, 4), ",", ok
    endif
  endfor
  removeObject: tg
endfor

removeObject: list
appendInfoLine: "範囲内 ", n_in, " 区間 / 範囲外 ", n_out, " 区間"
appendInfoLine: "範囲: ", min_duration_s, "〜", max_duration_s, " 秒"
appendInfoLine: "出力: ", output_csv$
