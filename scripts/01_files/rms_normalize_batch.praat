# rms_normalize_batch.praat
# 音圧を一括で正規化する
#
# 『Praatで学ぶ音声研究の方法』付録A-5 の完全版
# 書籍では form の定義のみを示し、本体はここを参照するとしている。
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# フォルダ内のWAVの音圧をそろえる。知覚実験の刺激作成や、
# 録音レベルがばらついたデータの前処理に使う。
#
# 入力: WAVの入ったフォルダ、目標強度（dB）
# 出力: 正規化したWAV、および normalize_log.csv
#   filename         ファイル名
#   intensity_before 正規化前の平均強度（dB）
#   intensity_after  正規化後
#   gain_db          かけた利得（after - before）
#   clipped          正規化後に振幅が1を超えたら1
#
# 読み方・注意:
#   - Scale intensity は全体の平均強度を目標値に合わせる。
#     無音部分が長いファイルでは平均が下がるため、
#     有声部分の音量は目標より大きくなる。区間を切ってから
#     正規化するほうが正確なことが多い。
#   - 利得をかけた結果、振幅が1を超えると再生時に歪む。
#     clipped が1の行は目標強度を下げて再実行すること。
#     既定の70 dBは多くの録音で安全な値である。
#   - 正規化は元の音量差の情報を捨てる。音量そのものを分析する場合は
#     正規化してはいけない。

form RMS Normalize
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  sentence Input_folder
  sentence Output_folder
  real Target_intensity_dB 70
endform

pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/rms_normalize_batch/"
endif
createDirectory: pbs_root$ + "/results"
createDirectory: output_folder$

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings
if n = 0
  exitScript: "WAVファイルが見つからない: ", input_folder$
endif

writeFileLine: output_folder$ + "normalize_log.csv",
... "filename,intensity_before,intensity_after,gain_db,clipped"
n_clip = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  before = Get intensity (dB)

  Scale intensity: target_intensity_dB
  after = Get intensity (dB)
  # 振幅の絶対値が1を超えると再生時に歪む
  amax = Get absolute extremum: 0, 0, "None"
  if amax > 1
    clip = 1
    n_clip = n_clip + 1
  else
    clip = 0
  endif

  Save as WAV file: output_folder$ + f$
  removeObject: snd

  if before = undefined
    appendFileLine: output_folder$ + "normalize_log.csv", f$, ",NA,NA,NA,", clip
  else
    appendFileLine: output_folder$ + "normalize_log.csv", f$, ",",
    ... fixed$(before, 2), ",", fixed$(after, 2), ",",
    ... fixed$(after - before, 2), ",", clip
  endif
endfor

removeObject: list
appendInfoLine: "処理 ", n, " ファイル / 目標 ", target_intensity_dB, " dB"
if n_clip > 0
  appendInfoLine: "【注意】", n_clip, " ファイルで振幅が1を超えた。目標強度を下げること。"
endif
appendInfoLine: "出力: ", output_folder$
