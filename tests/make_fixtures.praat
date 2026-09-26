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

appendInfoLine: "fixtures ok: ", outdir$
