# vot_continuum.praat
# Script 13.1：VOT continuumを自動生成するscript（7ステップ）
#
# 『Praatで学ぶ音声研究の方法』ch13掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form VOT Continuum Generator
  sentence Sound_file    audio/ba_base.wav
  sentence Textgrid_file textgrids/ba_base.TextGrid
  # PointTierであること
  integer  Burst_tier    1
  # IntervalTierであること
  integer  Vowel_tier    2
  integer  N_steps       7
  real     Vot_min_ms   10
  real     Vot_max_ms   70
  sentence Output_dir   stimuli/vot/
endform

sound_orig  = Read from file: sound_file$
tg          = Read from file: textgrid_file$
selectObject: sound_orig
sample_rate = Get sampling frequency
total_dur   = Get total duration

; TextGridからburst時刻とvowel開始時刻を取得する
selectObject: tg
t_burst = Get time of point: burst_tier, 1

; 最初の有音インターバルをvowel onsetとして使用する
n_int_v = Get number of intervals: vowel_tier
t_vowel = undefined

for i from 1 to n_int_v
  selectObject: tg
  label$ = Get label of interval: vowel_tier, i
  if label$ <> "" and label$ <> "closure" and label$ <> "sil" and label$ <> "<sil>"
    if t_vowel = undefined
      t_vowel = Get start time of interval: vowel_tier, i
    endif
  endif
endfor

if t_vowel = undefined
  exitScript: "エラー: vowel開始時刻が取得できませんでした。vowel tierのラベルを確認してください。"
endif

appendInfoLine: "burst時刻: ", fixed$(t_burst, 4), " s"
appendInfoLine: "vowel onset: ", fixed$(t_vowel, 4), " s"

; VOTステップの計算
if n_steps > 1
  vot_step_ms = (vot_max_ms - vot_min_ms) / (n_steps - 1)
else
  vot_step_ms = 0
endif
appendInfoLine: "VOT step幅: ", fixed$(vot_step_ms, 1), " ms"

for step from 1 to n_steps
  vot_ms = vot_min_ms + (step - 1) * vot_step_ms
  vot_s  = vot_ms / 1000

  ; セグメント[1]: closure（0〜burst時刻まで）
  selectObject: sound_orig
  pre_burst = Extract part: 0, t_burst, "rectangular", 1, "no"

  ; セグメント[2]: 無音（VOT長分の純粋な無音）
  silence = Create Sound from formula: "silence", 1, 0, vot_s, sample_rate, "0"

  ; セグメント[3]: vowel（vowel onset〜末尾。burst〜t_vowel間のaspirationは使わない）
  selectObject: sound_orig
  post_vot = Extract part: t_vowel, total_dur, "rectangular", 1, "no"

  ; 3セグメントを連結する
  selectObject: pre_burst
  plusObject: silence
  plusObject: post_vot
  # IDで管理する（"Sound chain"は使わない）
  sound_concat = Concatenate

  ; ファイル名を生成して保存する
  step_str$ = if step < 10 then "0" + string$(step) else string$(step) fi
  output_file$ = output_dir$ + "vot_step" + step_str$ + "_" +
    ... string$(round(vot_ms)) + "ms.wav"

  selectObject: sound_concat
  # RMS強度を70 dBに正規化して刺激間の強度差を揃える
  Scale intensity: 70
  Save as WAV file: output_file$
  appendInfoLine: "保存[", step, "/", n_steps, "]: ", output_file$

  removeObject: pre_burst, silence, post_vot, sound_concat
endfor

removeObject: sound_orig, tg
appendInfoLine: "=== VOT continuum完成: ", n_steps, " ステップ ==="
