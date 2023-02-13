import os

prefix = "XXXXXX Starting: "
with open("out.txt") as f:
    lines = f.readlines()
    for line in lines:
        line = line.strip()
        if not line:
            continue
        if line[0] == "'":
            line = line[1:-1]
        if line.startswith(prefix):
            print("]")
        print('"' + line + '"' + ",")
        if line.startswith(prefix):
            print("[")
print("]")

        