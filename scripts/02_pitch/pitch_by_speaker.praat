# pitch_by_speaker.praat
# 話者別（サブフォルダ別）にpitch統計を集計する
#
# 『Praatで学ぶ音声研究の方法』付録A-15（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# 話者（サブフォルダ）ごとにF0統計をまとめる。
# 話者の声域を把握し、以降の分析で pitch_floor / ceiling を
# 話者ごとに設定するための材料にする。
#
# 入力: root/話者名/*.wav という構成のフォルダ
# 出力: pitch_by_speaker.csv
#   speaker      話者名（サブフォルダ名）
#   n_files      そのフォルダのファイル数
#   n_analyzed   F0が1つでも取れたファイル数
#   mean_hz      有声フレーム全体の平均F0
#   sd_hz        同じく標準偏差
#   median_hz    常に NA（下記参照）
#   min_hz       最小値
#   max_hz       最大値
#   range_st     最小から最大までの幅（半音）
#
# 読み方・注意:
#   - 話者IDはフォルダ名から取る。ファイル名から切り出す方式は、
#     命名規則が崩れたときに黙って壊れる。構造に持たせるほうが安全である。
#   - ファイルごとの平均をさらに平均すると、長いファイルの重みが
#     不当に小さくなる。ここでは全フレームをまとめて集計している。
#   - median_hz は NA を返す。中央値は全フレームを保持しないと
#     厳密には出せず、近似値を書くと誤った根拠になるためである。
#     分位点が必要なら pitch_percentile.praat を使う。
#   - min/max はオクターブ誤りの影響を受けやすい。range_st が
#     12（1オクターブ）を大きく超える話者は、抽出結果を目視すること。

form Pitch statistics by speaker
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Root_folder
  sentence Output_csv
  positive Pitch_floor 75
  positive Pitch_ceiling 600
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if root_folder$ = ""
  root_folder$ = pbs_root$ + "/sample/bySpeaker/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/pitch_by_speaker.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 話者ごとの1サブフォルダ、という構成を前提にする:
#   root/spk1/*.wav, root/spk2/*.wav, ...
# 話者IDをファイル名から切り出す方式は、命名規則が崩れた時に黙って壊れる。
# フォルダ構造に持たせるほうが事故が少ない。

Create Strings as directory list: "dirs", root_folder$
dirs = selected("Strings")
n_spk = Get number of strings
if n_spk = 0
  exitScript: "サブフォルダが見つからない: ", root_folder$
endif

writeFileLine: output_csv$, "speaker,n_files,n_analyzed,mean_hz,sd_hz,median_hz,min_hz,max_hz,range_st"

for s from 1 to n_spk
  selectObject: dirs
  spk$ = Get string: s

  Create Strings as file list: "wavs", root_folder$ + spk$ + "/*.wav"
  wavs = selected("Strings")
  n_files = Get number of strings

  # 話者内の全フレームをまとめて扱いたいので、ファイルごとの平均ではなく
  # 値を蓄積してから統計を取る。ファイル長が不均一なとき結果が変わる。
  sum_hz = 0
  sum_sq = 0
  n_val = 0
  min_hz = 1e9
  max_hz = 0
  n_analyzed = 0

  for i from 1 to n_files
    selectObject: wavs
    f$ = Get string: i
    snd = Read from file: root_folder$ + spk$ + "/" + f$
    pitch = To Pitch: 0, pitch_floor, pitch_ceiling
    n_frames = Get number of frames

    got = 0
    for fr from 1 to n_frames
      selectObject: pitch
      v = Get value in frame: fr, "Hertz"
      if v <> undefined
        sum_hz = sum_hz + v
        sum_sq = sum_sq + v * v
        n_val = n_val + 1
        got = 1
        if v < min_hz
          min_hz = v
        endif
        if v > max_hz
          max_hz = v
        endif
      endif
    endfor
    if got
      n_analyzed = n_analyzed + 1
    endif
    removeObject: pitch, snd
  endfor

  if n_val > 1
    mean_hz = sum_hz / n_val
    var = (sum_sq - n_val * mean_hz * mean_hz) / (n_val - 1)
    if var < 0
      var = 0
    endif
    sd_hz = sqrt(var)
    range_st = 12 * log2(max_hz / min_hz)
    # 中央値は全フレームを保持しないと厳密には出せない。
    # ここでは近似せず、算出していないことを明示する。
    appendFileLine: output_csv$, spk$, ",", n_files, ",", n_analyzed, ",",
    ... fixed$(mean_hz, 2), ",", fixed$(sd_hz, 3), ",NA,",
    ... fixed$(min_hz, 2), ",", fixed$(max_hz, 2), ",", fixed$(range_st, 3)
  else
    appendFileLine: output_csv$, spk$, ",", n_files, ",0,NA,NA,NA,NA,NA,NA"
  endif

  removeObject: wavs
endfor

removeObject: dirs
appendInfoLine: "完了: ", n_spk, " 話者 → ", output_csv$
