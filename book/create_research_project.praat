# create_research_project.praat
# Script 18.1：研究プロジェクト用フォルダ構成を自動生成するPraatスクリプト
#
# 『Praatで学ぶ音声研究の方法』ch18掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Create Research Project
  sentence Project_name   vot_perception_study
  sentence Project_dir    /Users/username/research/
  sentence Praat_version  7.0.02
  sentence Investigator   [研究者名]
endform

base$ = project_dir$ + project_name$ + "/"

; フォルダ構成を作成する（Praatには createFolder: があるが、1階層ずつしか作れない。
; 入れ子のフォルダでは呼び出しを重ねる必要があるため、ここでは手順ガイドをtxtで生成する）
; SETUP_GUIDE.txtとREADME_template.mdはproject_dir$直下に書き出す。
; base$のフォルダ自体はまだ存在しないため、そこに書き込むとエラーになる。
; 実際のフォルダ作成はSETUP_GUIDE.txtの指示に従い、ターミナルまたはファイルマネージャで行う

setup_guide$ = project_dir$ + "SETUP_GUIDE.txt"
writeFileLine: setup_guide$, "=== プロジェクトセットアップガイド ==="
appendFileLine: setup_guide$, "プロジェクト名: ", project_name$
appendFileLine: setup_guide$, "作成日: ", date$()
appendFileLine: setup_guide$, ""
appendFileLine: setup_guide$, "以下のフォルダを手動で作成してください:"
appendFileLine: setup_guide$, "  mkdir -p scripts/praat scripts/R stimuli data results docs"
appendFileLine: setup_guide$, ""
appendFileLine: setup_guide$, "または以下のコマンドをターミナルで実行してください:"
appendFileLine: setup_guide$, "  cd ", project_dir$
appendFileLine: setup_guide$, "  mkdir -p ", project_name$
appendFileLine: setup_guide$, "  cd ", project_name$
appendFileLine: setup_guide$, "  mkdir -p scripts/praat scripts/R stimuli/wav stimuli/vot"
appendFileLine: setup_guide$, "           data results figures docs participants"

; README.md の雛形を生成する
readme_file$ = project_dir$ + "README_template.md"
writeFileLine: readme_file$, "# ", project_name$
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "## 概要"
appendFileLine: readme_file$, "[研究の目的・概要をここに記述]"
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "## 使用ソフトウェア・バージョン"
appendFileLine: readme_file$, "- Praat ", praat_version$
appendFileLine: readme_file$, "- R [バージョン番号]"
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "## フォルダ構成"
appendFileLine: readme_file$, "```"
appendFileLine: readme_file$, "scripts/praat/  Praatスクリプト一式"
appendFileLine: readme_file$, "scripts/R/      R解析スクリプト一式"
appendFileLine: readme_file$, "stimuli/        刺激音声（注:大容量ファイルはGit LFS推奨）"
appendFileLine: readme_file$, "data/           分析用データ（個人情報除外後）"
appendFileLine: readme_file$, "results/        前処理済みCSV・統計出力"
appendFileLine: readme_file$, "docs/           annotation convention等の文書"
appendFileLine: readme_file$, "```"
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "## 再現手順"
appendFileLine: readme_file$, "1. `scripts/praat/vot_continuum.praat` で刺激を生成"
appendFileLine: readme_file$, "2. Praat で ExperimentMFC を実行"
appendFileLine: readme_file$, "3. `scripts/praat/mfc_to_r.praat` でCSVに変換"
appendFileLine: readme_file$, "4. `scripts/R/analysis.R` で統計分析を実行"
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "## データの入手"
appendFileLine: readme_file$, "刺激音声・生データ: OSF プロジェクト [URL: 出版後にサポートページで公開]"
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "## 引用"
appendFileLine: readme_file$, "石原 健 (2026). [論文タイトル]. [ジャーナル名]."
appendFileLine: readme_file$, "コード: https://github.com/labphonlab/", project_name$
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "## ライセンス"
appendFileLine: readme_file$, "スクリプト: MIT License"
appendFileLine: readme_file$, "データ: CC BY 4.0"
appendFileLine: readme_file$, ""
appendFileLine: readme_file$, "## 担当者"
appendFileLine: readme_file$, investigator$

appendInfoLine: "フォルダ構成ガイド: ", setup_guide$
appendInfoLine: "READMEテンプレート: ", readme_file$
appendInfoLine: "=== 次のステップ ==="
appendInfoLine: "1. SETUP_GUIDE.txtの指示に従ってフォルダを作成する"
appendFileLine: setup_guide$, ""
appendInfoLine: "2. README_template.mdをREADME.mdにリネームして編集する"
appendInfoLine: "3. GitHubでリポジトリを作成してpushする"
