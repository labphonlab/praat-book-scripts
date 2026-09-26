# Praatで学ぶ音声研究の方法 — 公開スクリプト集

[![Validate public package](https://github.com/labphonlab/praat-book-scripts/actions/workflows/validate.yml/badge.svg)](https://github.com/labphonlab/praat-book-scripts/actions/workflows/validate.yml)
[![Release](https://img.shields.io/github/v/release/labphonlab/praat-book-scripts)](https://github.com/labphonlab/praat-book-scripts/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

『Praatで学ぶ音声研究の方法—測定・自動化・コーパス分析』（音声学ライブラリ 第1巻）に対応するPraatスクリプト集です。

## 正本と刊行時固定版

この公開リポジトリの **main** ブランチをコードの正本とします。刊行時点の固定版は [v1.0.0 Release](https://github.com/labphonlab/praat-book-scripts/releases/tag/v1.0.0) から取得できます。ReleaseにはZIPとSHA-256チェックサムを添付します。

## 使い方

1. ReleaseのZIPをダウンロードして展開する
2. scripts フォルダから目的に合うPraatスクリプトを開く
3. Script editorの **Run** を押し、自分の音声・TextGridフォルダを指定する

Praat 7.0.02で検証しています。コマンドラインからファイルを書き出す場合は、Praat 7.0以降の要件に従って FULL-TRUST を有効にしてください。

## 収録内容

| フォルダ | 内容 |
|---|---|
| scripts/01_files | ファイル操作・変換 |
| scripts/02_pitch | ピッチ抽出 |
| scripts/03_formant | フォルマント抽出 |
| scripts/04_textgrid | TextGrid処理 |
| scripts/05_plot | 音響図の作成 |
| scripts/06_ops | 設定ファイル駆動・再開・品質管理 |
| scripts/07_figures | 論文用図版 |
| book | 書籍本文・付録掲載コードの実行可能版 |
| tests | 構造検査と合成テスト音生成用コード |
| tools・util | 検証・保守ツール |

## コードとデータの分離

この公開リポジトリには、Praatコードと検証用設定だけを収録しています。音声、TextGrid、参加者データ、第三者コーパスは含みません。書籍の実習用データは、書籍に記載された購入者向けZIPから取得してください。自分の研究データを使う場合は、その利用条件と倫理手続きを確認してください。

tests 内の生成スクリプトを使うと、PraatのKlattGridから合成テスト音を作成できます。生成音は実話者の録音ではありません。

## 検証

    python tools/validate_repository.py

実データを用いるPraat実行テストは、購入者向けデータまたは自分で生成したテスト音を別途配置して実行します。

## ライセンス

本リポジトリのコードと文書はMIT Licenseで公開しています。購入者向けZIPに含まれる素材には、そのZIP内の利用条件が別途適用されます。

## 正誤・要望

コードの不具合や書籍との不一致は、GitHub Issuesでお知らせください。
