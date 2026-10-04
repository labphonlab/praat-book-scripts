# check_textgrid_pairs.praat
# WAVとTextGridの対応を確認する
#
# 『Praatで学ぶ音声研究の方法』付録A-7（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。
#   Praat --run --FULL-TRUST check_textgrid_pairs.praat <引数...>

# ── このスクリプトについて ───────────────────────────────
# WAVとTextGridが1対1に対応しているかを確かめる。
# バッチ処理を始める前の点検に使う。片方が欠けたまま走らせると、
# 途中で止まるか、黙って一部のファイルが集計から漏れる。
#
# 入力: WAVとTextGridが同居するフォルダ
# 出力: pair_check.csv
#   stem            拡張子を除いたファイル名
#   has_wav         WAVがあれば1
#   has_textgrid    TextGridがあれば1
#   status          ok / TextGridなし / WAVなし
#
# 読み方・注意:
#   - WAV側から見るだけでは、TextGridだけが余っている場合を取りこぼす。
#     このスクリプトは両方向を調べる。
#   - status が ok 以外の行が1つでもあれば、その原因を確かめてから
#     分析に進むこと。件数のずれは後で必ず問題になる。

form Check TextGrid pairs
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
  output_csv$ = pbs_root$ + "/results/check_textgrid_pairs.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

Create Strings as file list: "wavs", input_folder$ + "*.wav"
wavs = selected("Strings")
nw = Get number of strings
Create Strings as file list: "grids", input_folder$ + "*.TextGrid"
grids = selected("Strings")
ng = Get number of strings

writeFileLine: output_csv$, "stem,has_wav,has_textgrid,status"
missing_grid = 0
orphan_grid = 0

for i from 1 to nw
  selectObject: wavs
  w$ = Get string: i
  stem$ = w$ - ".wav"
  selectObject: grids
  found = 0
  for j from 1 to ng
    g$ = Get string: j
    if g$ = stem$ + ".TextGrid"
      found = 1
    endif
  endfor
  if found
    status$ = "ok"
  else
    status$ = "TextGridなし"
    missing_grid = missing_grid + 1
  endif
  appendFileLine: output_csv$, stem$, ",1,", found, ",", status$
endfor

# TextGrid はあるが WAV が無いものも拾う。片側だけ見ると取りこぼす。
for j from 1 to ng
  selectObject: grids
  g$ = Get string: j
  stem$ = g$ - ".TextGrid"
  selectObject: wavs
  found = 0
  for i from 1 to nw
    w$ = Get string: i
    if w$ = stem$ + ".wav"
      found = 1
    endif
  endfor
  if not found
    appendFileLine: output_csv$, stem$, ",0,1,WAVなし"
    orphan_grid = orphan_grid + 1
  endif
endfor

removeObject: wavs, grids
appendInfoLine: "WAV ", nw, " 件 / TextGrid ", ng, " 件"
appendInfoLine: "TextGrid欠落: ", missing_grid, " / WAV欠落: ", orphan_grid
appendInfoLine: "レポート: ", output_csv$
