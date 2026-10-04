# batch_mono_convert.praat
# ステレオ音声を一括でモノラルに変換する
#
# 『Praatで学ぶ音声研究の方法』付録A-2 の完全版
# 書籍では form の定義のみを示し、本体はここを参照するとしている。
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# フォルダ内のWAVを読み、モノラルに変換して別フォルダへ書き出す。
# 元のファイルは変更しない。
#
# 入力: WAVの入ったフォルダ
# 出力: モノラル化したWAV、および convert_log.csv
#   filename          ファイル名
#   channels_before   変換前のチャンネル数
#   channels_after    変換後のチャンネル数（常に1）
#   converted         実際に変換したら1、もともとモノラルなら0
#
# 読み方・注意:
#   - Convert to mono は全チャンネルの平均を取る。左右で位相がずれている
#     録音では、平均によって打ち消しが起き音が痩せることがある。
#     片チャンネルだけを使いたい場合は Extract one channel を使う。
#   - もともとモノラルのファイルはそのまま複写する。無駄な再変換をしない。
#   - 変換の有無を記録するので、あとでどれを触ったかを追える。

form Batch Mono Convert
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  sentence Input_folder
  sentence Output_folder
  boolean 片チャンネルのみ使う 0
  positive 使うチャンネル 1
endform

pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/batch_mono_convert/"
endif
createDirectory: pbs_root$ + "/results"
createDirectory: output_folder$

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings
if n = 0
  exitScript: "WAVファイルが見つからない: ", input_folder$
endif

writeFileLine: output_folder$ + "convert_log.csv",
... "filename,channels_before,channels_after,converted"
n_conv = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  ch = Get number of channels

  if ch > 1
    if 片チャンネルのみ使う
      if 使うチャンネル > ch
        exitScript: "チャンネル番号が範囲外: ", f$, " は ", ch, " チャンネル"
      endif
      out = Extract one channel: 使うチャンネル
    else
      out = Convert to mono
    endif
    Save as WAV file: output_folder$ + f$
    removeObject: out
    n_conv = n_conv + 1
    conv = 1
  else
    # もともとモノラルなら、そのまま書き出す
    Save as WAV file: output_folder$ + f$
    conv = 0
  endif

  removeObject: snd
  appendFileLine: output_folder$ + "convert_log.csv", f$, ",", ch, ",1,", conv
endfor

removeObject: list
appendInfoLine: "処理 ", n, " ファイル / 変換した ", n_conv, " ファイル"
appendInfoLine: "出力: ", output_folder$
