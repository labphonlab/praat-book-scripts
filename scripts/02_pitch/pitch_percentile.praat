# pitch_percentile.praat
# F0のパーセンタイルを求める
#
# 『Praatで学ぶ音声研究の方法』付録A-16（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# F0の分位点（パーセンタイル）を出す。平均と標準偏差より頑健な要約になる。
#
# 入力: WAVの入ったフォルダ
# 出力: pitch_percentile.csv
#   filename            ファイル名
#   p5, p10, ..., p95   各パーセンタイルのF0（Hz）
#   iqr_hz              四分位範囲（p75 - p25）
#
# 読み方・注意:
#   - F0分布は右に歪みやすく、平均は分布の代表値になりにくい。
#     中央値（p50）のほうが「ふつうの高さ」に近い。
#   - オクターブ誤りは分布の端に出る。p5・p95 を使えば
#     最小・最大を使うより影響を受けにくい。
#   - iqr_hz は声の高さに依存して大きくなる。話者間で比べるときは
#     半音に換算するか、pitch_range_hz_st.praat を使う。
#   - 話者の pitch_floor / ceiling を決めるとき、p5 と p95 の
#     外側に余裕を取った値が目安になる。

form Pitch percentiles
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Pitch_floor 75
  positive Pitch_ceiling 600
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/pitch_percentile.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 平均・標準偏差より分位点のほうがよい場面がある。F0分布は右に歪みやすく、
# また外れ値（オクターブ誤り）が平均を引っ張るためである。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,p5,p10,p25,p50,p75,p90,p95,iqr_hz"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  pitch = To Pitch: 0, pitch_floor, pitch_ceiling

  p05 = Get quantile: 0, 0, 0.05, "Hertz"
  p10 = Get quantile: 0, 0, 0.10, "Hertz"
  p25 = Get quantile: 0, 0, 0.25, "Hertz"
  p50 = Get quantile: 0, 0, 0.50, "Hertz"
  p75 = Get quantile: 0, 0, 0.75, "Hertz"
  p90 = Get quantile: 0, 0, 0.90, "Hertz"
  p95 = Get quantile: 0, 0, 0.95, "Hertz"

  if p50 = undefined
    appendFileLine: output_csv$, f$, ",NA,NA,NA,NA,NA,NA,NA,NA"
  else
    appendFileLine: output_csv$, f$, ",", fixed$(p05,2), ",", fixed$(p10,2), ",",
    ... fixed$(p25,2), ",", fixed$(p50,2), ",", fixed$(p75,2), ",",
    ... fixed$(p90,2), ",", fixed$(p95,2), ",", fixed$(p75 - p25, 2)
  endif

  removeObject: pitch, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
