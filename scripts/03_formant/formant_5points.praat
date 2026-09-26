# formant_5points.praat
# F1〜F3を5点等間隔で抽出する
#
# 『Praatで学ぶ音声研究の方法』付録A-20（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# 各ファイルのF1〜F3を、長さで正規化した等間隔の点で取り出す。
# 母音の定常部だけでなく、渡り（transition）の様子も見たいときに使う。
#
# 入力: WAVの入ったフォルダ、点数、max_formant（Hz）
# 出力: formant_5points.csv（縦持ち。1行が1点）
#   filename       ファイル名
#   point          何点目か（1から）
#   rel_position   母音全体を1としたときの相対位置
#   time_s         実時刻（秒）
#   f1_hz f2_hz f3_hz  各フォルマント（Hz）。取れなければ NA
#
# 読み方・注意:
#   - max_formant は話者の声道長で決める。成人男性 5000 Hz、
#     成人女性 5500 Hz が出発点。全話者に同じ値を当てると、
#     一方の性別で系統的にフォルマントを取り違える。
#   - この設定が適切かどうかは formant_ceiling_compare.praat で確かめる。
#   - 単母音でも rel_position 0.2 と 0.8 で値が大きく違うなら、
#     前後の子音の影響を受けている。中央付近（0.4〜0.6）を使う。

form Formants at equidistant points
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive N_points 5
  positive Max_formant_hz 5500
  positive N_formants 5
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/formant_5points.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# max_formant は話者の声道長に依存する。成人男性 5000、成人女性 5500 が目安。
# 全話者に同じ値を当てると系統的な誤りが入るので、話者ごとに設定を変えること。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,point,rel_position,time_s,f1_hz,f2_hz,f3_hz"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  formant = To Formant (burg): 0, n_formants, max_formant_hz, 0.025, 50

  for k from 1 to n_points
    rel = (k - 0.5) / n_points
    t = rel * dur
    selectObject: formant
    f1 = Get value at time: 1, t, "hertz", "linear"
    f2 = Get value at time: 2, t, "hertz", "linear"
    f3 = Get value at time: 3, t, "hertz", "linear"

    f1$ = if f1 = undefined then "NA" else fixed$(f1, 1) fi
    f2$ = if f2 = undefined then "NA" else fixed$(f2, 1) fi
    f3$ = if f3 = undefined then "NA" else fixed$(f3, 1) fi

    appendFileLine: output_csv$, f$, ",", k, ",", fixed$(rel, 4), ",",
    ... fixed$(t, 4), ",", f1$, ",", f2$, ",", f3$
  endfor

  removeObject: formant, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル × ", n_points, " 点 → ", output_csv$
