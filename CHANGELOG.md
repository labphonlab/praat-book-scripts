# 変更履歴

## 1.0.4 — 2026-10-04

- 書籍全体の事実確認に合わせて、書籍掲載スクリプト15本を本文から再抽出
  - 動かなかった箇所の修正：procedure_example（未定義変数）、qa_check（列名の不一致）、session_init（フォルダの作成）、reliability_intra（文字列の書き方）、vowel_space_plot（`Paint circle (mm):` に変更）、session_log（変数名）
  - 付属データに合わせた修正：10_1_textgrid_basics、cejc_open、utilities、mfc_to_r、readme_gen
  - 出力やコメントの修正：version_check、report_pitch_parameters、script_8_4_batch_full、create_research_project
- 骨格の完全版・補助スクリプト・テスト用スクリプト45本の冒頭コメントのライセンス表記を、MIT Licenseに統一（購入者限定の旧表記が残っていた）
- README・CONTRIBUTINGの実習データの説明を、パスワードなしの実習データZIP（CC BY 4.0）に合わせた

## 1.0.3 — 2026-10-04

- 書籍掲載スクリプト4本（script_8_3_pitch_batch・script_8_4_batch_full・10_2_tier_cross・vowel_extractor）のPitch分析を、旧式の `To Pitch (ac)` から本書の標準である `To Pitch (filtered autocorrelation)` に変更
  - フォームの既定値を floor 50 Hz・top 800 Hz（filtered autocorrelation法の既定値）に、変数名を `ceiling` から `top` に変更

## 1.0.2 — 2026-10-04

- f0_trajectory_plot.praat：横軸ラベルの `%` がPraatで斜体指定と解釈されて表示されなかった不具合を修正（`\% ` と書く）

## 1.0.1 — 2026-10-04

- Picture Windowの単位を cm と誤っていた図版スクリプトを、正しいインチ単位に修正（Praat 6.4.45以降、Picture Windowは60×60インチ）
  - spectrogram_export・spectrogram_export_batch・annotated_spectrogram_pdf・f0_trajectory_plot・vowel_space_plot・two_panel_figure
  - フォーム項目 `Width_cm`・`Height_cm` を `Width_in`・`Height_in` に改名
- 書籍掲載スクリプトを最新の書籍本文から再抽出し、本文と一致させた（旧コマンド `To Pitch (ac)` を `To Pitch (raw autocorrelation)` に置き換え、スペクトログラムとTextGridの描画の重なりを修正）
- 書籍掲載スクリプトの冒頭コメントのライセンス表記を、リポジトリのMIT Licenseに統一

## 1.0.0 — 2026-09-27

- 『Praatで学ぶ音声研究の方法—測定・自動化・コーパス分析』（音声学ライブラリ 第1巻）の刊行時固定版
- 公開GitHubリポジトリをコードとNotebookの正本に設定
- MIT License、引用情報、Release用検証を整備
- 参加者データ、第三者コーパス、購入者限定資料を公開対象から除外
