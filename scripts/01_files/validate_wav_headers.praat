# validate_wav_headers.praat
# WAVヘッダー（サンプリングレート・チャンネル数）を検証する
#
# 『Praatで学ぶ音声研究の方法』付録A-10（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。
#   Praat --run --FULL-TRUST validate_wav_headers.praat <引数...>

# ── このスクリプトについて ───────────────────────────────
# WAVのサンプリングレートとチャンネル数が期待どおりかを検査する。
# 収録機材や受け渡し経路が混ざったデータで、設定の違いを見つけるのに使う。
#
# 入力: WAVの入ったフォルダ、期待するサンプリングレートとチャンネル数
# 出力: header_check.csv
#   filename        ファイル名
#   sample_rate     実際のサンプリングレート（Hz）
#   channels        実際のチャンネル数
#   bit_depth_est   常に NA（下記参照）
#   duration_s      長さ（秒）
#   status          ok / SR不一致 / チャンネル数不一致 / その両方
#
# 読み方・注意:
#   - ビット深度は NA を返す。Praatは読み込み時に内部表現へ変換するため、
#     原ファイルのビット深度をスクリプトから取得できない。
#     推測値を書くと誤った根拠になるので、取得できないことを明示している。
#   - サンプリングレートが混在したまま分析すると、フォルマントの
#     上限設定が一部のファイルで意味を失う。分析前に必ず揃える。

form Validate WAV headers
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  positive Expected_sample_rate 44100
  positive Expected_channels 1
  sentence Output_csv
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/validate_wav_headers.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,sample_rate,channels,bit_depth_est,duration_s,status"
n_bad = 0

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  sr = Get sampling frequency
  ch = Get number of channels
  dur = Get total duration
  removeObject: snd

  status$ = "ok"
  if sr <> expected_sample_rate
    status$ = "SR不一致"
  endif
  if ch <> expected_channels
    if status$ = "ok"
      status$ = "チャンネル数不一致"
    else
      status$ = status$ + "+チャンネル数不一致"
    endif
  endif
  if status$ <> "ok"
    n_bad = n_bad + 1
  endif

  # Praatは読み込み時に浮動小数へ変換するので、ビット深度は原ファイルから直接は得られない。
  # ここでは推定せず、未取得であることを明示する。
  appendFileLine: output_csv$, f$, ",", sr, ",", ch, ",NA,", fixed$(dur, 4), ",", status$
endfor

removeObject: list
appendInfoLine: "検査 ", n, " ファイル / 不適合 ", n_bad, " ファイル"
appendInfoLine: "期待値: ", expected_sample_rate, " Hz, ", expected_channels, " ch"
appendInfoLine: "レポート: ", output_csv$
