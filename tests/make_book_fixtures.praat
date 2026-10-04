# make_fixtures.praat
# テスト用の最小データ一式を生成する。実データ・実話者音声は同梱しない。
#
# 3話者 × 3母音（/a/ /i/ /u/）をKlattGrid合成で作る。
# 話者差は f0 と声道長スケールで与える。真値が分かっているので、
# 抽出スクリプトが妥当な値を返しているかを検証できる。

form Make fixtures
  sentence Outdir /tmp/pbs_fx/
endform
createDirectory: outdir$
createDirectory: outdir$ + "audio"
createDirectory: outdir$ + "results"
createDirectory: outdir$ + "bySpeaker"

names$# = {"spk1", "spk2", "spk3"}
f0# = {110, 190, 145}
# 声道長スケール（1に対する比）。短いほどフォルマントが高くなる。
scale# = {1.00, 1.18, 1.08}

vowels$# = {"a", "i", "u"}
# 男性話者を基準にした目標値（Hz）
f1_# = {800, 300, 350}
f2_# = {1200, 2300, 900}
f3_# = {2500, 3000, 2400}

writeFileLine: outdir$ + "fixture_truth.csv", "speaker,vowel,f0_hz,f1_target,f2_target,f3_target"

for s from 1 to 3
  createDirectory: outdir$ + "bySpeaker/" + names$# [s]
  for v from 1 to 3
    f1 = f1_# [v] * scale# [s]
    f2 = f2_# [v] * scale# [s]
    f3 = f3_# [v] * scale# [s]
    kg = Create KlattGrid from vowel: "v", 0.4, f0# [s],
    ... f1, 50, f2, 70, f3, 100, f3 + 500, 0.05, 1000
    snd = To Sound
    base$ = names$# [s] + "_" + vowels$# [v]
    Save as WAV file: outdir$ + "audio/" + base$ + ".wav"
    Save as WAV file: outdir$ + "bySpeaker/" + names$# [s] + "/" + base$ + ".wav"
    removeObject: snd, kg
    appendFileLine: outdir$ + "fixture_truth.csv", names$# [s], ",", vowels$# [v], ",",
    ... f0# [s], ",", fixed$(f1,0), ",", fixed$(f2,0), ",", fixed$(f3,0)
  endfor
endfor

# 短いファイル（A-8 の検出対象）
Create Sound as pure tone: "short", 1, 0, 0.12, 22050, 300, 0.2, 0.01, 0.01
Save as WAV file: outdir$ + "audio/tiny.wav"
Remove

# TextGrid。WAVと対になるものと、ならないものを両方作る。
snd = Read from file: outdir$ + "audio/spk1_a.wav"
tg = To TextGrid: "phone word tone", "tone"
selectObject: tg
Insert boundary: 1, 0.10
Insert boundary: 1, 0.28
Set interval text: 1, 1, "s"
Set interval text: 1, 2, "a"
Set interval text: 1, 3, ""
Insert boundary: 2, 0.20
Set interval text: 2, 1, "sa"
Set interval text: 2, 2, "ka"
Insert point: 3, 0.15, "H"
Insert point: 3, 0.33, "L"
Save as text file: outdir$ + "audio/spk1_a.TextGrid"
Save as text file: outdir$ + "audio/orphan.TextGrid"
removeObject: tg, snd

# TextGrid処理のテスト用フォルダ。統合（A-31）は同名ファイルの対を要求する。
createDirectory: outdir$ + "tg_a"
createDirectory: outdir$ + "tg_b"
snd = Read from file: outdir$ + "audio/spk1_a.wav"
for side from 1 to 2
  if side = 1
    dir$ = outdir$ + "tg_a/"
    tiers$ = "phone"
  else
    dir$ = outdir$ + "tg_b/"
    tiers$ = "word"
  endif
  selectObject: snd
  tg = To TextGrid: tiers$, ""
  Insert boundary: 1, 0.10
  Insert boundary: 1, 0.28
  Set interval text: 1, 1, "s"
  Set interval text: 1, 2, "a"
  Save as text file: dir$ + "spk1_a.TextGrid"
  Remove
endfor
selectObject: snd
tg = To TextGrid: "phone", ""
Insert boundary: 1, 0.2
Set interval text: 1, 1, "a"
Save as text file: outdir$ + "tg_a/lonely.TextGrid"
removeObject: tg, snd

# --- 書籍スクリプト用の追加データ ---------------------------------
createDirectory: outdir$ + "in"
createDirectory: outdir$ + "out"
createDirectory: outdir$ + "rater1"
createDirectory: outdir$ + "rater2"

# 検者間信頼性スクリプト用: 同名TextGridを2名分
snd = Read from file: outdir$ + "audio/spk1_a.wav"
for r from 1 to 2
  selectObject: snd
  tg = To TextGrid: "phone", ""
  Insert boundary: 1, 0.10 + (r - 1) * 0.008
  Insert boundary: 1, 0.28 + (r - 1) * 0.005
  Set interval text: 1, 1, "s"
  Set interval text: 1, 2, "a"
  Set interval text: 1, 3, "k"
  if r = 1
    Save as text file: outdir$ + "rater1/spk1_a.TextGrid"
  else
    Save as text file: outdir$ + "rater2/spk1_a.TextGrid"
  endif
  Remove
endfor
removeObject: snd

# 汎用の表。book/ の各スクリプトが要求する列名をすべて含める。
# 列が足りないと「no column named ...」で落ちるが、それは
# スクリプトの不具合ではなく入力の不備なので、まとめて用意する。
vow$# = {"a", "i", "u", "e", "o"}
writeFileLine: outdir$ + "in/table.csv",
... "id,file,filename,speaker,speaker_id,vowel,sex,age,dialect,status,"
... + "value_t1,value_t2,label_t1,label_t2,f0_mean,f1_mean,f2_mean,"
... + "time_norm,duration_ms,stimulus,response,reactionTime"
for i from 1 to 15
  v$ = vow$# [(i - 1) mod 5 + 1]
  appendFileLine: outdir$ + "in/table.csv",
  ... "id", i, ",spk", (i mod 3) + 1, "_", v$, ".wav,spk", (i mod 3) + 1, "_", v$, ",spk", (i mod 3) + 1, ",spk",
  ... (i mod 3) + 1, ",", v$, ",", if (i mod 2) = 0 then "F" else "M" fi, ",",
  ... 20 + i, ",Tokyo,ok,",
  ... fixed$(500 + i * 7, 2), ",", fixed$(500 + i * 7 + 3, 2), ",", v$, ",", v$, ",",
  ... fixed$(110 + i * 2, 2), ",", fixed$(700 + i * 9, 1), ",", fixed$(1200 + i * 21, 1), ",",
  ... fixed$((i - 1) / 14, 4), ",", fixed$(120 + i * 6, 1), ",",
  ... "stim", i, ",", v$, ",", fixed$(400 + i * 13, 1)
endfor

# --- VOT関連スクリプト用のTextGrid ---------------------------------
# vot_measure は 層2=破裂点(point)・層3=母音(point) を要求する
createDirectory: outdir$ + "in/vot_measure"
snd = Read from file: outdir$ + "audio/spk1_a.wav"
tg = To TextGrid: "word burst vowel", "burst vowel"
Insert point: 2, 0.08, "b"
Insert point: 3, 0.10, "a"
Insert point: 2, 0.22, "b"
Insert point: 3, 0.25, "a"
Save as text file: outdir$ + "in/vot_measure/spk1_a.TextGrid"
Remove

# vot_continuum は 層1=破裂点(point)・層2=母音(interval) を要求する
selectObject: snd
tg = To TextGrid: "burst vowel", "burst"
Insert point: 1, 0.08, "b"
Insert boundary: 2, 0.10
Insert boundary: 2, 0.30
Set interval text: 2, 2, "a"
Save as text file: outdir$ + "in/vot_base.TextGrid"
removeObject: tg, snd

# --- ExperimentMFC の結果表（Praat Table形式）------------------------
# mfc_to_r は CSV ではなく Praat の Table ファイルを読む
mfc = Create Table with column names: "mfc", 10, "stimulus response reactionTime"
for i from 1 to 10
  Set string value: i, "stimulus", "vot_" + string$(i * 10) + "ms"
  if i mod 2 = 0
    Set string value: i, "response", "ba"
  else
    Set string value: i, "response", "pa"
  endif
  Set numeric value: i, "reactionTime", 0.4 + i * 0.05
endfor
Save as text file: outdir$ + "in/mfc_result.Table"
Remove

# --- セッション初期化スクリプト用のフォルダ -------------------------
createDirectory: outdir$ + "out/proj"
createDirectory: outdir$ + "out/proj/participants"
createDirectory: outdir$ + "out/proj/participants/sp01"

appendInfoLine: "fixtures ok: ", outdir$
