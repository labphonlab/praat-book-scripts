# voiced_fraction.praat
# 有声区間率を計算する
#
# 『Praatで学ぶ音声研究の方法』付録A-14（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# 発話のうち有声だったフレームの割合を出す。
# 発話速度や無声化の指標、またはF0抽出がどれだけ成功したかの目安になる。
#
# 入力: WAVの入ったフォルダ
# 出力: voiced_fraction.csv
#   filename          ファイル名
#   duration_s        長さ（秒）
#   n_frames          Pitchオブジェクトの全フレーム数
#   n_voiced          有声と判定されたフレーム数
#   voiced_fraction   n_voiced / n_frames
#
# 読み方・注意:
#   - この値は音声そのものの性質と、F0抽出の設定の両方を反映する。
#     pitch_floor を高くしすぎると低い声が無声と判定され、値が下がる。
#     解釈の前に、設定が話者に合っているかを確かめること。
#   - 極端に低い値（0.2未満など）は、雑音の多い録音か設定の誤りを疑う。
#   - フレーム数は録音長と時間刻みで決まる。刻みを変えると
#     n_frames は変わるが、割合はおおむね保たれる。

form Voiced fraction
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
  output_csv$ = pbs_root$ + "/results/voiced_fraction.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,duration_s,n_frames,n_voiced,voiced_fraction"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  pitch = To Pitch: 0, pitch_floor, pitch_ceiling

  n_frames = Get number of frames
  n_voiced = Count voiced frames

  if n_frames > 0
    frac$ = fixed$(n_voiced / n_frames, 4)
  else
    frac$ = "NA"
  endif

  appendFileLine: output_csv$, f$, ",", fixed$(dur, 4), ",", n_frames, ",", n_voiced, ",", frac$
  removeObject: pitch, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
