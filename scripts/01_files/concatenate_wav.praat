# concatenate_wav.praat
# フォルダ内のWAVを1本に連結する
#
# 『Praatで学ぶ音声研究の方法』付録A-9（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。
#   Praat --run --FULL-TRUST concatenate_wav.praat <引数...>

# ── このスクリプトについて ───────────────────────────────
# フォルダ内のWAVを1本のファイルに連結する。
# 刺激音の作成や、短い断片をまとめて聴いて確認する用途を想定する。
#
# 入力: WAVの入ったフォルダ
# 出力: 連結したWAV1本、および <出力名>_order.csv
#   order        連結された順番
#   filename     元のファイル名
#   duration_s   その長さ（秒）
#
# 読み方・注意:
#   - 連結にはサンプリングレートとチャンネル数の一致が要る。
#     先頭ファイルに合わせて自動で変換する。変換された分は音質が変わる。
#   - 順番は Praat のファイル一覧の順（おおむね辞書順）になる。
#     意図した順に並べたいときは、先に batch_rename.praat で連番を振る。
#   - _order.csv の duration_s を累積すれば、連結後のどの時刻が
#     どの元ファイルに当たるかを計算できる。

form Concatenate WAV
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_wav
  real Silence_between_s 0.0
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_wav$ = ""
  output_wav$ = pbs_root$ + "/results/concatenated.wav"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings
if n = 0
  exitScript: "WAVファイルが見つからない: ", input_folder$
endif

# 連結にはサンプリングレートの一致が要る。先頭に合わせて揃える。
selectObject: list
f$ = Get string: 1
first = Read from file: input_folder$ + f$
sr = Get sampling frequency
n_ch = Get number of channels
removeObject: first

ids# = zero# (n * 2)
n_obj = 0
writeFileLine: output_wav$ - ".wav" + "_order.csv", "order,filename,duration_s"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  # Praatは条件式の中でコマンドを直接呼べない。いったん変数に受ける。
  this_sr = Get sampling frequency
  if this_sr <> sr
    Resample: sr, 50
    removeObject: snd
    snd = selected("Sound")
  endif
  selectObject: snd
  this_ch = Get number of channels
  if this_ch <> n_ch
    Convert to mono
    removeObject: snd
    snd = selected("Sound")
  endif
  selectObject: snd
  dur = Get total duration
  n_obj = n_obj + 1
  ids# [n_obj] = snd
  appendFileLine: output_wav$ - ".wav" + "_order.csv", i, ",", f$, ",", fixed$(dur, 4)

  if silence_between_s > 0 and i < n
    sil = Create Sound from formula: "sil", n_ch, 0, silence_between_s, sr, "0"
    n_obj = n_obj + 1
    ids# [n_obj] = sil
  endif
endfor

selectObject: ids# [1]
for k from 2 to n_obj
  plusObject: ids# [k]
endfor
Concatenate
Save as WAV file: output_wav$
total = Get total duration
Remove

for k from 1 to n_obj
  removeObject: ids# [k]
endfor
removeObject: list

appendInfoLine: "連結 ", n, " ファイル → ", output_wav$
appendInfoLine: "合計長: ", fixed$(total, 3), " 秒"
