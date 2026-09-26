#!/bin/sh
# to_tiff.sh — PNG を TIFF に変換する
#
# 『Praatで学ぶ音声研究の方法』論文図版パック
# Copyright (c) 2026 Takeshi Ishihara / 語音研究所
#
# Praat は TIFF を書き出せない。投稿先が TIFF を要求する場合は、
# 600 dpi の PNG を変換して使う。変換しても解像度は落ちない
# （どちらもラスタで、画素はそのまま移る）。
#
# 使い方:  sh tools/to_tiff.sh figures/vowel_space_ellipse.png
#
# macOS は標準の sips を使う。Linux / Windows(WSL・Git Bash) は
# ImageMagick の magick か convert を使う。いずれも無い場合は、
# GIMP や IrfanView など手元の画像ソフトで PNG を開いて TIFF 保存すればよい。

set -e
if [ $# -lt 1 ]; then
  echo "使い方: sh tools/to_tiff.sh <PNGファイル> [出力先]" >&2
  exit 1
fi
src="$1"
dst="${2:-${src%.png}.tif}"

if [ ! -f "$src" ]; then
  echo "ファイルが無い: $src" >&2
  exit 1
fi

if command -v sips >/dev/null 2>&1; then
  sips -s format tiff "$src" --out "$dst" >/dev/null
  echo "変換 (sips): $dst"
elif command -v magick >/dev/null 2>&1; then
  magick "$src" -compress lzw "$dst"
  echo "変換 (magick): $dst"
elif command -v convert >/dev/null 2>&1; then
  convert "$src" -compress lzw "$dst"
  echo "変換 (convert): $dst"
else
  echo "変換できる道具が見つからない。" >&2
  echo "macOS なら sips が標準で入っている。それ以外は ImageMagick を入れるか、" >&2
  echo "画像ソフトで $src を開いて TIFF 形式で保存すること。" >&2
  exit 1
fi
