# 変更履歴

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
