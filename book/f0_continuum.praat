# f0_continuum.praat
# 13.5　F0 continuumの作成
#
# 『Praatで学ぶ音声研究の方法』Script 13.2掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form F0 Continuum Generator
  sentence Sound_file    audio/target_word.wav
  # To Manipulation の pitch floor
  real     Pitch_floor   75
  # To Manipulation の pitch ceiling
  real     Pitch_ceiling 400
  # 全ステップ共通の開始F0（Hz）
  real     F0_start      80
  # 全ステップ共通の終了F0（Hz）
  real     F0_end        80
  # ピークF0の最小値（最初のステップ）
  real     F0_peak_min   100
  # ピークF0の最大値（最後のステップ）
  real     F0_peak_max   200
  # F0ピークの相対時刻（0.0〜1.0）
  real     Peak_time_pct 0.3
  integer  N_steps       5
  sentence Output_dir    stimuli/f0/
endform

sound_orig = Read from file: sound_file$
selectObject: sound_orig
total_dur  = Get total duration
manipulation = To Manipulation: 0.01, pitch_floor, pitch_ceiling

f0_peak_step = if n_steps > 1 then (f0_peak_max - f0_peak_min) / (n_steps - 1) else 0 fi
peak_time    = total_dur * peak_time_pct

for step from 1 to n_steps
  f0_peak = f0_peak_min + (step - 1) * f0_peak_step

  selectObject: manipulation
  pitch_tier = Extract pitch tier
  selectObject: pitch_tier

  ; 既存の点を全て削除して新しいパターンを設定する
  Remove points between: 0, total_dur
  # 開始点
  Add point: 0,          f0_start
  # ピーク（ステップごとに変化）
  Add point: peak_time,  f0_peak
  # 終了点
  Add point: total_dur,  f0_end

  plusObject: manipulation
  Replace pitch tier
  removeObject: pitch_tier

  selectObject: manipulation
  sound_step = Get resynthesis (overlap-add)

  step_str$ = if step < 10 then "0" + string$(step) else string$(step) fi
  output_file$ = output_dir$ + "f0_step" + step_str$ + "_" +
    ... string$(round(f0_peak)) + "hz.wav"

  selectObject: sound_step
  Scale intensity: 70
  Save as WAV file: output_file$
  appendInfoLine: "保存[", step, "/", n_steps, "]: F0ピーク=", fixed$(f0_peak, 0), " Hz → ", output_file$

  removeObject: sound_step
endfor

removeObject: sound_orig, manipulation
appendInfoLine: "=== F0 continuum完成: ", n_steps, " ステップ ==="
