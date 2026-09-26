# formant_ceiling_compare.praat
# max_formant値を変えて測定の安定性を比べる
#
# 『Praatで学ぶ音声研究の方法』付録A-22（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# max_formant の値を振って、測定がどれだけ安定しているかを調べる。
# 設定を決め打ちにせず、根拠を持って選ぶための手順である。
#
# 入力: WAVの入ったフォルダ、試す上限値の下限・上限・刻み
# 出力: ceiling_compare.csv（1ファイル×設定ごとに1行）
#   filename      ファイル名
#   ceiling_hz    試した max_formant
#   f1_hz f2_hz f3_hz  その設定での測定値
#
# 読み方・注意:
#   - 適切な範囲では、設定を変えてもF1・F2はほとんど動かない。
#     大きく動く範囲は、その話者・その母音に合っていない。
#   - 表計算ソフトで filename ごとに ceiling_hz を横軸、F1・F2を
#     縦軸にして折れ線にすると、平らな区間が一目で分かる。
#     その平らな区間の中央付近を採用する。
#   - 隣り合う設定で値が倍近く跳ぶのは、フォルマントの
#     取り違え（F2とF3の交代）が起きた印である。

form Compare formant ceilings
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Ceiling_min 4500
  positive Ceiling_max 6000
  positive Ceiling_step 250
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
  output_csv$ = pbs_root$ + "/results/formant_ceiling_compare.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# max_formant を決め打ちにせず、値を振って結果の安定性を見る。
# 適切な範囲では F1・F2 はほとんど動かない。大きく動くなら、
# その話者・その母音では設定が不適切だと分かる。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,ceiling_hz,f1_hz,f2_hz,f3_hz"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  t = measure_at_relative * dur

  ceiling = ceiling_min
  while ceiling <= ceiling_max
    selectObject: snd
    formant = To Formant (burg): 0, 5, ceiling, 0.025, 50
    f1 = Get value at time: 1, t, "hertz", "linear"
    f2 = Get value at time: 2, t, "hertz", "linear"
    f3 = Get value at time: 3, t, "hertz", "linear"
    appendFileLine: output_csv$, f$, ",", ceiling, ",",
    ... if f1 = undefined then "NA" else fixed$(f1,1) fi, ",",
    ... if f2 = undefined then "NA" else fixed$(f2,1) fi, ",",
    ... if f3 = undefined then "NA" else fixed$(f3,1) fi
    removeObject: formant
    ceiling = ceiling + ceiling_step
  endwhile

  removeObject: snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
appendInfoLine: "各ファイルでF1・F2が安定している範囲を確認すること。"
