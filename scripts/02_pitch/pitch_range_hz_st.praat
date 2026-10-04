# pitch_range_hz_st.praat
# pitch範囲をHzと半音の両方で出力する
#
# 『Praatで学ぶ音声研究の方法』付録A-18（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# F0の変動幅を、Hzと半音の両方で出す。
#
# 入力: WAVの入ったフォルダ
# 出力: pitch_range.csv
#   filename    ファイル名
#   low_hz      下端（Hz）
#   high_hz     上端（Hz）
#   range_hz    上端 - 下端（Hz）
#   range_st    12 * log2(上端/下端)（半音）
#   method      p5-p95 か min-max か
#
# 読み方・注意:
#   - 既定は5〜95パーセンタイル幅である。最大−最小はオクターブ誤りが
#     1つあるだけで壊れる。use_percentile_range を0にすると
#     最大−最小に切り替わるが、結果を必ず目視すること。
#   - 話者間の比較には range_st を使う。Hz幅は声が高い話者ほど
#     大きく出るため、そのまま比べると高い声の話者が
#     「抑揚が大きい」と誤って評価される。
#   - 目安として、平静な読み上げで4〜8半音、感情的な発話で
#     12半音を超えることがある。

form Pitch range in Hz and semitones
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Pitch_floor 75
  positive Pitch_ceiling 600
  boolean Use_percentile_range 1
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/pitch_range_hz_st.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 最大−最小はオクターブ誤り1つで壊れる。既定では 5–95 パーセンタイル幅を使う。
# Hz幅は話者の高さに依存して大きくなるため、話者間比較には半音幅を使う。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,low_hz,high_hz,range_hz,range_st,method"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  pitch = To Pitch: 0, pitch_floor, pitch_ceiling

  if use_percentile_range
    lo = Get quantile: 0, 0, 0.05, "Hertz"
    hi = Get quantile: 0, 0, 0.95, "Hertz"
    method$ = "p5-p95"
  else
    lo = Get minimum: 0, 0, "Hertz", "parabolic"
    hi = Get maximum: 0, 0, "Hertz", "parabolic"
    method$ = "min-max"
  endif

  if lo = undefined or hi = undefined or lo <= 0
    appendFileLine: output_csv$, f$, ",NA,NA,NA,NA,", method$
  else
    st = 12 * log2(hi / lo)
    appendFileLine: output_csv$, f$, ",", fixed$(lo,2), ",", fixed$(hi,2), ",",
    ... fixed$(hi - lo, 2), ",", fixed$(st, 3), ",", method$
  endif

  removeObject: pitch, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
