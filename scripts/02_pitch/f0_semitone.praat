# f0_semitone.praat
# F0を半音値で出力する
#
# 『Praatで学ぶ音声研究の方法』付録A-13（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# F0を半音（semitone）で出す。話者の声の高さが違う場合、Hzのままでは
# 比べられない。半音は対数尺度なので、高さの違う話者の変動幅を揃えられる。
#
# 入力: WAVの入ったフォルダ、換算の基準にするHz
# 出力: f0_semitone.csv
#   filename           ファイル名
#   mean_hz            F0平均（Hz）
#   mean_st_re_1hz     1 Hz を基準とした半音値（Praat組み込み）
#   mean_st_re_ref     指定した基準に対する半音値
#   ref_hz             使った基準（Hz）
#
# 読み方・注意:
#   - Praatに「Convert to semitones」という単独コマンドは無い。
#     半音は Get... 系コマンドの単位引数として指定する。
#     組み込みで使える基準は "semitones re 1 Hz" である。
#   - 任意の基準に対する半音は 12 * log2(f0 / 基準) で自分で換算する。
#   - mean_st_re_1hz と mean_st_re_ref の差は定数にならない。
#     前者は半音領域での平均、後者はHz平均を半音に換算した値であり、
#     対数変換と平均の順序が違うためである。厳密な比較では前者を使う。
#   - 基準には話者ごとの中央値を使うことが多い。そうすると
#     「その話者にとっての高い・低い」を表す値になる。

form F0 in semitones
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Pitch_floor 75
  positive Pitch_ceiling 600
  positive Reference_hz 100
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/f0_semitone.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# Praatに「Convert to semitones」という単独コマンドは無い。
# 半音は Get... 系コマンドの単位引数として指定する。
# 組み込みの基準は "semitones re 1 Hz"（1 Hz基準）である。
# 任意の基準（話者の中央値など）に対する半音は、Hzから自分で換算する:
#   st = 12 * log2(f0 / reference)

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,mean_hz,mean_st_re_1hz,mean_st_re_ref,ref_hz"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  pitch = To Pitch: 0, pitch_floor, pitch_ceiling

  mean_hz = Get mean: 0, 0, "Hertz"
  mean_st1 = Get mean: 0, 0, "semitones re 1 Hz"

  if mean_hz = undefined
    hz$ = "NA"
    st1$ = "NA"
    stref$ = "NA"
  else
    hz$ = fixed$(mean_hz, 2)
    st1$ = fixed$(mean_st1, 3)
    # 基準を変えた半音は Hz から換算する。半音平均は対数領域の平均なので、
    # Hz平均の換算値とは一致しない点に注意すること。
    stref$ = fixed$(12 * log2(mean_hz / reference_hz), 3)
  endif

  appendFileLine: output_csv$, f$, ",", hz$, ",", st1$, ",", stref$, ",", reference_hz
  removeObject: pitch, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
