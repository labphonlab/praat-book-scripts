# readme_gen.praat
# README.txtの自動生成
#
# 『Praatで学ぶ音声研究の方法』ch15掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form README Generator
  sentence Project_name   vot_categorical_perception
  sentence Praat_version  7.0.02
  sentence Investigator   [研究者名]
  sentence Irb_approval   [承認番号]
  sentence Project_dir    experiment_project/
endform

readme_file$ = project_dir$ + "README.txt"

writeFileLine: readme_file$, "=============================="
appendFileLine: readme_file$, "プロジェクト名: ", project_name$
appendFileLine: readme_file$, "=============================="
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "使用ソフトウェア: Praat ", praat_version$
appendFileLine: readme_file$, "倫理承認: ", irb_approval$
appendFileLine: readme_file$, "担当者: ", investigator$
appendFileLine: readme_file$, "作成日: ", date$()
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "フォルダ構成:"
appendFileLine: readme_file$, "  stimuli/     - 刺激音声（WAV）"
appendFileLine: readme_file$, "  experiments/ - ExperimentMFC設定ファイル（MFC）"
appendFileLine: readme_file$, "  participants/ - 参加者別結果（個人情報含む・要管理）"
appendFileLine: readme_file$, "  results/     - 前処理済みCSV（R分析用）"
appendFileLine: readme_file$, "  scripts/     - Praat・Rスクリプト一式"
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "スクリプト実行順序:"
appendFileLine: readme_file$, "  1. scripts/vot_continuum.praat    → stimuli/vot/*.wav"
appendFileLine: readme_file$, "  2. scripts/randomize_stimuli.praat→ experiments/stimulus_list.txt"
appendFileLine: readme_file$, "  3. scripts/latin_square.praat     → 参加者別条件順序"
appendFileLine: readme_file$, "  4. Praat で ExperimentMFC を実行"
appendFileLine: readme_file$, "  5. scripts/mfc_to_r.praat         → results/*_clean.csv"
appendFileLine: readme_file$, "  6. R/analysis.R                   → 統計分析"

appendInfoLine: "README.txt 生成完了: ", readme_file$
