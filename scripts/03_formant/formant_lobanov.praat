# formant_lobanov.praat
# Lobanov正規化（話者内zスコア）を行う
#
# 『Praatで学ぶ音声研究の方法』付録A-23（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

# ── このスクリプトについて ───────────────────────────────
# Lobanov正規化を行う。話者ごとの平均と標準偏差で標準化し、
# 声道長の違いによる差を取り除いて母音の位置を比べられるようにする。
#
#   F_norm = (F - その話者の平均) / その話者の標準偏差
#
# 入力: root/話者名/*.wav という構成のフォルダ
# 出力: formant_lobanov.csv
#   speaker      話者名
#   filename     ファイル名
#   f1_hz f2_hz  正規化前の測定値（Hz）
#   f1_lobanov f2_lobanov  正規化後のzスコア
#   speaker_n    その話者で測定できた件数
#
# 読み方・注意:
#   - zスコアなので、話者内で平均0・標準偏差1になる。
#     単位は無く、Hzに戻すことはできない。
#   - この手法は「母音の分布が話者間で同じ」ことを仮定する。
#     話者ごとに母音セットが偏っていると、正規化そのものが歪む。
#     少数の母音しか無い話者には使わない。
#   - speaker_n が小さい話者（目安として5未満）の値は信用しない。
#     標準偏差の推定が不安定になる。
#   - 正規化前の値も残してある。正規化が結果を作っていないかを
#     確かめるため、両方で分析して結論が変わらないかを見ること。

form Lobanov normalization
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Root_folder
  sentence Output_csv
  positive Max_formant_hz 5500
  positive Measure_at_relative 0.5
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if root_folder$ = ""
  root_folder$ = pbs_root$ + "/sample/bySpeaker/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/formant_lobanov.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# Lobanov正規化は「話者内の平均と標準偏差で標準化する」手法である:
#   F_norm = (F - mean_speaker) / sd_speaker
# 母音の分布が話者間で同じであることを仮定するので、
# 話者ごとの母音セットが偏っていると正規化そのものが歪む。
# 少数の母音しか無い話者には使わないこと。
#
# 構成は root/話者名/*.wav を前提とする。
# 1回目で話者ごとの平均と標準偏差を求め、2回目で正規化する。

Create Strings as directory list: "dirs", root_folder$
dirs = selected("Strings")
n_spk = Get number of strings
if n_spk = 0
  exitScript: "話者フォルダが見つからない: ", root_folder$
endif

writeFileLine: output_csv$, "speaker,filename,f1_hz,f2_hz,f1_lobanov,f2_lobanov,speaker_n"

for s from 1 to n_spk
  selectObject: dirs
  spk$ = Get string: s
  Create Strings as file list: "wavs", root_folder$ + spk$ + "/*.wav"
  wavs = selected("Strings")
  n_files = Get number of strings

  if n_files >= 2
    f1_vals# = zero# (n_files)
    f2_vals# = zero# (n_files)
    names$# = empty$# (n_files)
    n_ok = 0

    # --- 第1パス: 測定して溜める ---
    for i from 1 to n_files
      selectObject: wavs
      f$ = Get string: i
      snd = Read from file: root_folder$ + spk$ + "/" + f$
      dur = Get total duration
      t = measure_at_relative * dur
      formant = To Formant (burg): 0, 5, max_formant_hz, 0.025, 50
      f1 = Get value at time: 1, t, "hertz", "linear"
      f2 = Get value at time: 2, t, "hertz", "linear"
      removeObject: formant, snd
      if f1 <> undefined and f2 <> undefined
        n_ok = n_ok + 1
        f1_vals# [n_ok] = f1
        f2_vals# [n_ok] = f2
        names$# [n_ok] = f$
      endif
    endfor

    if n_ok >= 2
      m1 = 0
      m2 = 0
      for k from 1 to n_ok
        m1 = m1 + f1_vals# [k]
        m2 = m2 + f2_vals# [k]
      endfor
      m1 = m1 / n_ok
      m2 = m2 / n_ok
      v1 = 0
      v2 = 0
      for k from 1 to n_ok
        v1 = v1 + (f1_vals# [k] - m1) ^ 2
        v2 = v2 + (f2_vals# [k] - m2) ^ 2
      endfor
      sd1 = sqrt(v1 / (n_ok - 1))
      sd2 = sqrt(v2 / (n_ok - 1))

      # --- 第2パス: 正規化して書き出す ---
      for k from 1 to n_ok
        if sd1 > 0
          z1$ = fixed$((f1_vals# [k] - m1) / sd1, 4)
        else
          z1$ = "NA"
        endif
        if sd2 > 0
          z2$ = fixed$((f2_vals# [k] - m2) / sd2, 4)
        else
          z2$ = "NA"
        endif
        appendFileLine: output_csv$, spk$, ",", names$# [k], ",",
        ... fixed$(f1_vals# [k], 1), ",", fixed$(f2_vals# [k], 1), ",",
        ... z1$, ",", z2$, ",", n_ok
      endfor
    endif
  endif

  removeObject: wavs
endfor

removeObject: dirs
appendInfoLine: "完了: ", n_spk, " 話者 → ", output_csv$
