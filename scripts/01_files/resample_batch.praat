# resample_batch.praat
# サンプリングレートを一括変換する
#
# 『Praatで学ぶ音声研究の方法』付録A-3 の完全版
# 書籍では form の定義のみを示し、本体はここを参照するとしている。
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

# ── このスクリプトについて ───────────────────────────────
# フォルダ内のWAVを、指定したサンプリングレートに一括変換する。
#
# 入力: WAVの入ったフォルダ、目標サンプリングレート
# 出力: 変換したWAV、および resample_log.csv
#   filename       ファイル名
#   rate_before    変換前のサンプリングレート
#   rate_after     変換後
#   resampled      実際に変換したら1
#
# 読み方・注意:
#   - ダウンサンプリングは情報を捨てる操作である。元に戻せない。
#     必ず元ファイルを残しておくこと。
#   - 目標レートの半分（ナイキスト周波数）より上の成分は失われる。
#     16000 Hz にすると 8000 Hz 以上が消えるので、摩擦音の分析には向かない。
#     フォルマント分析なら 16000 Hz でも足りることが多い。
#   - 精度引数（既定50）はsinc補間の窓幅である。大きいほど正確だが遅い。
#     Praatの推奨は50で、通常は変える必要がない。
#   - もともと目標レートのファイルは変換せず複写する。
#     再サンプリングを繰り返すと音質が劣化するため。

form Resample Batch
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  sentence Input_folder
  sentence Output_folder
  positive Target_rate 16000
  positive 精度 50
endform

pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/resample_batch/"
endif
createDirectory: pbs_root$ + "/results"
createDirectory: output_folder$

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings
if n = 0
  exitScript: "WAVファイルが見つからない: ", input_folder$
endif

writeFileLine: output_folder$ + "resample_log.csv",
... "filename,rate_before,rate_after,resampled"
n_res = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  sr = Get sampling frequency

  if sr <> target_rate
    out = Resample: target_rate, 精度
    Save as WAV file: output_folder$ + f$
    removeObject: out
    n_res = n_res + 1
    did = 1
  else
    Save as WAV file: output_folder$ + f$
    did = 0
  endif

  removeObject: snd
  appendFileLine: output_folder$ + "resample_log.csv",
  ... f$, ",", sr, ",", target_rate, ",", did
endfor

removeObject: list
appendInfoLine: "処理 ", n, " ファイル / 変換した ", n_res, " ファイル"
appendInfoLine: "目標 ", target_rate, " Hz（ナイキスト周波数 ", target_rate / 2, " Hz）"
appendInfoLine: "出力: ", output_folder$
