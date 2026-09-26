#!/usr/bin/env python3
"""フォーム定義と既定値解決ブロックの整合を検査する。

フォームの項目を1つ落とすと、コマンドラインからの引数の並びが1つずれ、
別の項目に値が入る。エラーにならず、間違った結果が静かに出る。
実際に一括編集で起きた事故なので、機械で見張る。
"""
import pathlib, re, sys

ROOT = pathlib.Path(__file__).parent.parent

def main():
    bad = []
    for p in sorted(ROOT.glob("scripts/*/*.praat")):
        t = p.read_text()
        m = re.search(r'^form .*?\n(.*?)^endform\n', t, re.S | re.M)
        if not m:
            bad.append((p, "form ブロックが無い")); continue
        # パスを表す項目だけが既定値解決の対象。ラベルや検索語は対象外。
        # 接頭辞だけでは足りない。settings_csv や measurements_csv のように
        # 用途が後ろに付く名前もパスを指す。
        # re.match は先頭一致なので、接尾辞の分岐にも先頭からの経路を書く。
        PATH = re.compile(r'^(?:(?:input_|root_|source_|target_|output_|folder_).*'
                          r'|.*_(?:csv|folder|dir|file|textgrid|pdf|wav|basename))$')
        fields = [f.lower() for f in
                  re.findall(r'^\s*(?:sentence|text)\s+(\w+)', m.group(1), re.M)
                  if PATH.match(f.lower())]
        resolved = re.findall(r'^if (\w+)\$ = ""', t, re.M)
        if fields != resolved:
            bad.append((p, f"form={fields} / 既定値={resolved}"))
        if "defaultDirectory$" not in t:
            bad.append((p, "無設定起動のブロックが無い"))
        # 配布物の利用条件は購入者限定。全ファイルに表示があることを確かめる。
        if "購入者に限り" not in t:
            bad.append((p, "利用条件の表示が無い"))
    n = len(list(ROOT.glob("scripts/*/*.praat")))
    print(f"検査 {n} 本 / 不整合 {len(bad)} 件")
    for p, msg in bad:
        print(f"  ✗ {p.relative_to(ROOT)}: {msg}")
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main())
