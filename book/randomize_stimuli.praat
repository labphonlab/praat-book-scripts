# randomize_stimuli.praat
# Script 15.1：制約付きランダム化（ExperimentMFC用刺激リスト生成）
#
# 『Praatで学ぶ音声研究の方法』ch15掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Stimulus Randomizer
  sentence Stimuli         "step01 step02 step03 step04 step05 step06 step07"
  integer  N_replications  5
  integer  Max_consecutive 2
  integer  Random_seed     42
  sentence Output_mfc      experiments/stimulus_list.txt
endform

; 刺激リストをスペース区切りで配列に展開する
n_stim = 0
rest$  = stimuli$
while rest$ <> ""
  n_stim = n_stim + 1
  pos = index(rest$, " ")
  if pos > 0
    stim$[n_stim] = left$(rest$, pos - 1)
    rest$          = right$(rest$, length(rest$) - pos)
  else
    stim$[n_stim] = rest$
    rest$          = ""
  endif
endwhile

appendInfoLine: n_stim, " 種類の刺激を読み込みました"

; 全試行リストを作成する（n_stim × n_replications）
n_trials = n_stim * n_replications
for i from 1 to n_stim
  for j from 1 to n_replications
    trial_stim$[(i - 1) * n_replications + j] = stim$[i]
  endfor
endfor

; 乱数シードを固定して再現性を確保する
; 同じシードを与えれば、何度実行しても同一の並びが得られる
random_initializeWithSeedUnsafelyButPredictably (random_seed)

; Fisher-Yates シャッフルを実行する
; Praatのforにstep句はないため、カウンタから添字を逆算する
for k from 1 to n_trials - 1
  i = n_trials + 1 - k
  ; 1〜i の一様乱数（Praatの randomInteger を使用）
  j = randomInteger(1, i)
  ; swap
  tmp$ = trial_stim$[i]
  trial_stim$[i] = trial_stim$[j]
  trial_stim$[j] = tmp$
endfor

; 連続制約のチェックと修正（最大max_consecutive連続まで許容）
max_iter = n_trials * 10
n_iter   = 0
changed  = 1

while changed = 1 and n_iter < max_iter
  changed = 0
  n_iter  = n_iter + 1
  for i from max_consecutive + 1 to n_trials
    all_same = 1
    for k from 0 to max_consecutive - 1
      if trial_stim$[i - k] <> trial_stim$[i - max_consecutive]
        all_same = 0
      endif
    endfor
    if all_same = 1
      ; 連続が発生 → 別の位置と交換を試みる
      for swap_j from i + 1 to n_trials
        if trial_stim$[swap_j] <> trial_stim$[i]
          tmp$ = trial_stim$[i]
          trial_stim$[i] = trial_stim$[swap_j]
          trial_stim$[swap_j] = tmp$
          changed = 1
          # breakの代わり
          swap_j = n_trials
        endif
      endfor
    endif
  endfor
endwhile

if n_iter >= max_iter
  appendInfoLine: "警告: 連続制約の完全な解消ができませんでした。刺激数・反復数・制約を調整してください。"
endif

; ExperimentMFCの刺激リスト部分を出力する（設定ファイルの断片）
writeFileLine: output_mfc$, "; 自動生成の刺激リスト（randomize_stimuli.praat）"
appendFileLine: output_mfc$, "; 生成日時: ", date$()
appendFileLine: output_mfc$, ""
appendFileLine: output_mfc$, "numberOfDifferentStimuli = ", n_trials

for i from 1 to n_trials
  appendFileLine: output_mfc$, "  """, trial_stim$[i], """ """""
endfor

appendInfoLine: "ランダム化完了: ", n_trials, " 試行 → ", output_mfc$
