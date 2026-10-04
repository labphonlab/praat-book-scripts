# version_guard.praat
# Script 1.2：バージョンガード付きスクリプトの骨格
#
# 『Praatで学ぶ音声研究の方法』ch01掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

# 例: "7.0.02"
ver$   = praatVersion$
# ピリオドで区切ってmajor/minor/patchを取得
major  = number(left$(ver$, index(ver$, ".") - 1))
rest$  = mid$(ver$, index(ver$, ".") + 1, 100)
minor  = number(left$(rest$, index(rest$, ".") - 1))
patch  = number(mid$(rest$, index(rest$, ".") + 1, 100))
ver_num = major * 10000 + minor * 100 + patch
; 例: 7.0.02 → 70002, 6.4.67 → 60467, 6.4.14 → 60414

# 6.4.14が最低要件のとき
min_ver_num = 60414
if ver_num < min_ver_num
  pauseScript: "警告: このスクリプトはPraat 6.4.14以降を想定しています。" +
    ... newline$ + "現在のバージョン（" + ver$ + "）では動作が保証されません。" +
    ... newline$ + "続けますか？"
endif

appendInfoLine: "バージョン確認OK: Praat ", ver$
