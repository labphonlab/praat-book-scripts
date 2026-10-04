# split_by_time.praat
# 長い音声を一定時間ごとに分割する
#
# 『Praatで学ぶ音声研究の方法』付録A-4 の完全版
# 書籍では form の定義のみを示し、本体はここを参照するとしている。
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# ── このスクリプトについて ───────────────────────────────
# 1本の長い録音を、指定した秒数ごとに切り分けて連番で書き出す。
# 長時間録音を扱いやすい単位にする下ごしらえである。
#
# 入力: WAVファイル1本、1区間の長さ（秒）
# 出力: <元の名前>_001.wav ... と split_index.csv
#   segment      区間番号
#   filename     書き出したファイル名
#   start_s      元ファイル内の開始時刻
#   end_s        終了時刻
#   duration_s   長さ
#
# 読み方・注意:
#   - 時間で機械的に切るので、語や発話の途中で切れる。
#     分析単位として使うのではなく、注釈作業を分けるための便宜と考えること。
#   - overlap を指定すると区間を重ねて切り出せる。境界付近の現象を
#     取りこぼしたくないときに使う。既定は0（重なりなし）。
#   - 最後の区間は指定より短くなる。既定では、極端に短い切れ端
#     （最小長未満）は書き出さない。件数は報告する。
#   - split_index.csv があれば、区間内の時刻を元ファイルの時刻に戻せる。

form Split by Time
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  sentence Input_file
  sentence Output_folder
  positive Segment_length_s 0.2
  real Overlap_s 0
  real 最小区間長_s 0.05
endform

pbs_root$ = defaultDirectory$ + "/../.."
if input_file$ = ""
  input_file$ = pbs_root$ + "/sample/audio/spk1_a.wav"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/split_by_time/"
endif
createDirectory: pbs_root$ + "/results"
createDirectory: output_folder$

if not fileReadable(input_file$)
  exitScript: "ファイルが読めない: ", input_file$
endif
if overlap_s >= segment_length_s
  exitScript: "重なりが区間長以上になっている。無限に切り出されるので中止する。"
endif

snd = Read from file: input_file$
total = Get total duration
name$ = right$(input_file$, length(input_file$) - rindex(input_file$, "/"))
stem$ = name$ - ".wav"

writeFileLine: output_folder$ + "split_index.csv",
... "segment,filename,start_s,end_s,duration_s"

step = segment_length_s - overlap_s
k = 0
n_written = 0
n_skipped = 0
t = 0
while t < total
  k = k + 1
  st = t
  en = min(t + segment_length_s, total)
  dur = en - st

  if dur >= 最小区間長_s
    selectObject: snd
    part = Extract part: st, en, "rectangular", 1, "no"
    seq$ = string$(k)
    while length(seq$) < 3
      seq$ = "0" + seq$
    endwhile
    out$ = stem$ + "_" + seq$ + ".wav"
    Save as WAV file: output_folder$ + out$
    removeObject: part
    n_written = n_written + 1
    appendFileLine: output_folder$ + "split_index.csv", k, ",", out$, ",",
    ... fixed$(st, 4), ",", fixed$(en, 4), ",", fixed$(dur, 4)
  else
    n_skipped = n_skipped + 1
  endif

  t = t + step
endwhile

removeObject: snd
appendInfoLine: "元の長さ ", fixed$(total, 3), " 秒 → ", n_written, " 区間"
if n_skipped > 0
  appendInfoLine: "短すぎて書き出さなかった切れ端: ", n_skipped, " 件"
endif
appendInfoLine: "出力: ", output_folder$
