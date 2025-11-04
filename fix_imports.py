import os
import re

ROOT = os.path.abspath(".")
TARGET_DIRS = [
    "pkg/ui-components",
    "pkg/core-logic",
    "pkg/db-schema",
    "app/client-web"
]

IMPORT_PATTERN = re.compile(r"import\s+[\'\"]package:([^\'\"]+)[\'\"]\s*;")

def fix_imports():
    for base in TARGET_DIRS:
        for dirpath, _, filenames in os.walk(base):
            for filename in filenames:
                if filename.endswith(".dart"):
                    full_path = os.path.join(dirpath, filename)
                    with open(full_path, "r", encoding="utf-8") as f:
                        content = f.read()

                    def replace(match):
                        package_path = match.group(1)
                        target_path = os.path.join(ROOT, *package_path.split("/"))
                        rel_path = os.path.relpath(target_path, os.path.dirname(full_path))
                        return f"import '{rel_path}';"

                    new_content = IMPORT_PATTERN.sub(replace, content)

                    with open(full_path, "w", encoding="utf-8") as f:
                        f.write(new_content)
                    print(f"✔ fixed: {full_path}")

if __name__ == "__main__":
    fix_imports()
