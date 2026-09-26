# make_sample_csv.praat — 図の練習用に測定CSVを作る
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集（論文図版編）
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 図版スクリプトはCSVを入力にする。実務では自分の測定結果を渡すが、
# 動作確認用に、同梱サンプル音声から測定CSVを作れるようにしておく。
# サンプルは母音ごとに5トークンあるので、1母音あたり15点になり楕円が引ける。

form 練習用CSVの作成
  comment 空欄のまま OK で同梱サンプルから作ります。
  sentence Root_folder
  sentence Output_csv
endform

pbs$ = defaultDirectory$
if root_folder$ = ""
  root_folder$ = pbs$ + "/../../sample/tokens"
endif
if output_csv$ = ""
  output_csv$ = pbs$ + "/../../results/figures/vowels.csv"
endif
createDirectory: pbs$ + "/../../results"
createDirectory: pbs$ + "/../../results/figures"

positions# = {0.5}
maxf# = {5000, 5500, 5200}

Create Strings as directory list: "dirs", root_folder$ + "/"
dirs = selected("Strings")
n_spk = Get number of strings

writeFileLine: output_csv$, "speaker,vowel,position,f1,f2"
n_rows = 0

for s from 1 to n_spk
  selectObject: dirs
  spk$ = Get string: s
  Create Strings as file list: "wavs", root_folder$ + "/" + spk$ + "/*.wav"
  wavs = selected("Strings")
  nf = Get number of strings
  for i from 1 to nf
    selectObject: wavs
    f$ = Get string: i
    stem$ = f$ - ".wav"
    # ファイル名は 話者_母音_トークン番号 の形。末尾の _t数字 を先に落としてから
    # 母音を取る。落とさないと "t1" を母音として拾ってしまう。
    core$ = stem$
    tpos = index_regex(core$, "_t[0-9]+$")
    if tpos > 0
      core$ = left$(core$, tpos - 1)
    endif
    v$ = core$
    pos = index_regex(core$, "_[^_]*$")
    if pos > 0
      v$ = mid$(core$, pos + 1, length(core$) - pos)
    endif
    snd = Read from file: root_folder$ + "/" + spk$ + "/" + f$
    dur = Get total duration
    formant = To Formant (burg): 0, 5, maxf# [min(s, 3)], 0.025, 50
    for k from 1 to size(positions#)
      selectObject: formant
      t = positions# [k] * dur
      f1 = Get value at time: 1, t, "hertz", "linear"
      f2 = Get value at time: 2, t, "hertz", "linear"
      if f1 <> undefined and f2 <> undefined
        appendFileLine: output_csv$, spk$, ",", v$, ",", fixed$(positions# [k], 3),
        ... ",", fixed$(f1, 1), ",", fixed$(f2, 1)
        n_rows = n_rows + 1
      endif
    endfor
    removeObject: formant, snd
  endfor
  removeObject: wavs
endfor
removeObject: dirs

writeInfoLine: "練習用CSVを作成: ", output_csv$
appendInfoLine: n_rows, " 行"
