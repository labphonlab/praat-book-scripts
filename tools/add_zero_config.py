#!/usr/bin/env python3
"""全スクリプトに「空欄のまま実行できる」既定値解決を挿入する。

読者に最初に要求するのがフォルダ設定では、そこで脱落する。
同梱サンプルを既定にして、展開→開く→Run→OK で結果が出る状態にする。
"""
import pathlib, re, sys

ROOT = pathlib.Path(__file__).parent.parent

# フィールド名 → 既定値（$root$ はリポジトリ直下に置き換える）
FOLDER_DEFAULT = {
    "input_folder":   '$root$ + "/sample/audio/"',
    "root_folder":    '$root$ + "/sample/bySpeaker/"',
    "folder_a":       '$root$ + "/sample/tg_a/"',
    "folder_b":       '$root$ + "/sample/tg_b/"',
    "source_textgrid": '$root$ + "/sample/tg_b/spk1_a.TextGrid"',
    "target_textgrid": '$root$ + "/sample/tg_a/spk1_a.TextGrid"',
}
COMMENT = [
    "comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。",
    "comment 自分のデータを使うときだけフォルダを指定してください。",
]

def out_default(field, stem):
    if field.endswith("_csv"):
        return f'$root$ + "/results/{stem}.csv"'
    if field.endswith("_pdf"):
        return f'$root$ + "/results/{stem}.pdf"'
    if field.endswith("_textgrid"):
        return f'$root$ + "/results/{stem}.TextGrid"'
    return f'$root$ + "/results/{stem}/"'

def process(path):
    text = path.read_text()
    if "既定値の解決" in text:
        return False
    m = re.search(r'^form .*?\n(.*?)^endform\n', text, re.S | re.M)
    if not m:
        return False
    body = m.group(1)
    fields = re.findall(r'^\s*(sentence|text)\s+([A-Za-z_][A-Za-z0-9_]*)', body, re.M)
    if not fields:
        return False

    depth = len(path.relative_to(ROOT).parts) - 1
    root_expr = 'defaultDirectory$ + "/' + "/".join([".."] * depth) + '"'
    stem = path.stem

    lines = ["", "# --- 既定値の解決 ------------------------------------------------",
             "# 空欄で実行された項目を、同梱サンプルと results/ で埋める。",
             "# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。",
             f"pbs_root$ = {root_expr}"]
    for _, name in fields:
        var = name[0].lower() + name[1:]
        var = var.lower()
        if var in FOLDER_DEFAULT:
            d = FOLDER_DEFAULT[var].replace("$root$", "pbs_root$")
        else:
            d = out_default(var, stem).replace("$root$", "pbs_root$")
        lines.append(f'if {var}$ = ""')
        lines.append(f'  {var}$ = {d}')
        lines.append("endif")
    lines.append('createDirectory: pbs_root$ + "/results"')
    lines.append("# -----------------------------------------------------------------")
    lines.append("")

    # フォーム冒頭に案内コメントを入れる
    form_line_end = text.index("\n", text.index("form ")) + 1
    text = text[:form_line_end] + "".join(f"  {c}\n" for c in COMMENT) + text[form_line_end:]

    idx = text.index("endform\n") + len("endform\n")
    text = text[:idx] + "\n".join(lines) + text[idx:]
    path.write_text(text)
    return True

if __name__ == "__main__":
    n = 0
    for p in sorted(ROOT.glob("scripts/*/*.praat")):
        if process(p):
            n += 1
    print(f"{n} 本に無設定起動を追加した")
