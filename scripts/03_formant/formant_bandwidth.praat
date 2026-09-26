# formant_bandwidth.praat
# フォルマント周波数と帯域幅を同時に抽出する
#
# 『Praatで学ぶ音声研究の方法』付録A-21（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# フォルマント周波数と帯域幅を同時に出す。帯域幅は測定の信頼性の手がかりになる。
#
# 入力: WAVの入ったフォルダ、測定する相対位置
# 出力: formant_bandwidth.csv
#   filename    ファイル名
#   time_s      測定時刻（秒）
#   f1_hz b1_hz F1とその帯域幅
#   f2_hz b2_hz F2とその帯域幅
#   f3_hz b3_hz F3とその帯域幅
#   b1_ratio    b1_hz / f1_hz
#
# 読み方・注意:
#   - 帯域幅は共鳴の鋭さを表す。狭いほど明瞭な共鳴である。
#   - 極端に広い帯域幅は、LPCが実在しないピークを拾っている疑いがある。
#     b1_ratio が 0.5 を超える行は目視で確かめる。
#   - 帯域幅そのものはLPCの次数に敏感で、絶対値の解釈は難しい。
#     ファイル間の相対比較や、外れ値の検出に使うのが現実的である。

form Formant frequencies and bandwidths
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Max_formant_hz 5500
  positive Measure_at_relative 0.5
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/formant_bandwidth.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 帯域幅は測定の信頼性の手がかりになる。極端に広い帯域幅は、
# LPCが実在しないピークを拾っている可能性を示す。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,time_s,f1_hz,b1_hz,f2_hz,b2_hz,f3_hz,b3_hz,b1_ratio"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  t = measure_at_relative * dur
  formant = To Formant (burg): 0, 5, max_formant_hz, 0.025, 50

  f1 = Get value at time: 1, t, "hertz", "linear"
  b1 = Get bandwidth at time: 1, t, "hertz", "linear"
  f2 = Get value at time: 2, t, "hertz", "linear"
  b2 = Get bandwidth at time: 2, t, "hertz", "linear"
  f3 = Get value at time: 3, t, "hertz", "linear"
  b3 = Get bandwidth at time: 3, t, "hertz", "linear"

  if f1 = undefined or b1 = undefined or f1 <= 0
    ratio$ = "NA"
  else
    ratio$ = fixed$(b1 / f1, 4)
  endif

  appendFileLine: output_csv$, f$, ",", fixed$(t, 4), ",",
  ... if f1 = undefined then "NA" else fixed$(f1,1) fi, ",",
  ... if b1 = undefined then "NA" else fixed$(b1,1) fi, ",",
  ... if f2 = undefined then "NA" else fixed$(f2,1) fi, ",",
  ... if b2 = undefined then "NA" else fixed$(b2,1) fi, ",",
  ... if f3 = undefined then "NA" else fixed$(f3,1) fi, ",",
  ... if b3 = undefined then "NA" else fixed$(b3,1) fi, ",", ratio$

  removeObject: formant, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
