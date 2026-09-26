# make_token_sample.praat — 図版スクリプトの練習用音声を作る
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。再配布は不可。
#
# 3話者 × 3母音 × 5トークンをKlattGrid合成で作る。
# トークンごとに目標フォルマントを少しずつ変えてある。実際の発話でも
# 同じ母音を繰り返せば値はばらつくので、そのばらつきを音の側に持たせている。
# 測定値に後から乱数を足すのとは違う。合成音そのものが異なる。
#
# 目標値は sample/targets.csv に記録する。測定結果と突き合わせられる。

form 練習用音声の作成
  sentence Outdir
  sentence Targets_csv
  positive Tokens_per_vowel 5
endform

if outdir$ = ""
  outdir$ = defaultDirectory$ + "/../sample/tokens"
endif
if targets_csv$ = ""
  targets_csv$ = outdir$ + "/targets.csv"
endif
createDirectory: outdir$

names$# = {"spk1", "spk2", "spk3"}
f0# = {110, 190, 145}
scale# = {1.00, 1.18, 1.08}
vowels$# = {"a", "i", "u"}
f1_# = {800, 300, 350}
f2_# = {1200, 2300, 900}
f3_# = {2500, 3000, 2400}

# トークン間の変動幅（目標値に対する比）。母音ごとに変える。
# /a/ は開口度が安定しにくくF1が動きやすい、/i/ はF2が動きやすい、
# という一般的な傾向をおおまかに反映させている。
jf1# = {0.055, 0.030, 0.035}
jf2# = {0.035, 0.045, 0.050}

writeFileLine: targets_csv$,
... "speaker,vowel,token,f0_target,f1_target,f2_target,f3_target"

for s from 1 to 3
  createDirectory: outdir$ + "/" + names$# [s]
  for v from 1 to 3
    for k from 1 to tokens_per_vowel
      # トークンを円周上に配置する。等間隔に一次元で散らすと、
      # F1とF2が完全に相関し、点が一直線に並んで楕円が潰れる。
      # 円周上に置けば2次元の広がりになる。乱数は使わないので、
      # 誰が実行しても同じ音が得られる。
      ang = 2 * pi * (k - 1) / tokens_per_vowel
      d1 = cos(ang)
      d2 = sin(ang)
      f1 = f1_# [v] * scale# [s] * (1 + jf1# [v] * d1)
      f2 = f2_# [v] * scale# [s] * (1 + jf2# [v] * d2)
      f3 = f3_# [v] * scale# [s]
      kg = Create KlattGrid from vowel: "v", 0.4, f0# [s],
      ... f1, 50, f2, 70, f3, 100, f3 + 500, 0.05, 1000
      snd = To Sound
      base$ = names$# [s] + "_" + vowels$# [v] + "_t" + string$(k)
      Save as WAV file: outdir$ + "/" + names$# [s] + "/" + base$ + ".wav"
      removeObject: snd, kg
      appendFileLine: targets_csv$,
      ... names$# [s], ",", vowels$# [v], ",", k, ",", f0# [s], ",",
      ... fixed$(f1, 1), ",", fixed$(f2, 1), ",", fixed$(f3, 1)
    endfor
  endfor
endfor

appendInfoLine: "練習用音声を作成: ", outdir$
appendInfoLine: 3 * 3 * tokens_per_vowel, " ファイル / 目標値は ", targets_csv$
