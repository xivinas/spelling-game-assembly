import json
import re
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

text = json.dumps(data)
forbidden = [
    r"\bpushad\b", r"\bpopad\b", r"\bpusha\b", r"\bpopa\b",
    r"\benter\b", r"\bleave\b", r"\bbswap\b",
    r"\bset[a-z]+\b", r"\bcmov[a-z]+\b",
    r"\bfs:\b", r"\bgs:\b",
    r"\beax\b", r"\bebx\b", r"\becx\b", r"\bedx\b", r"\besi\b", r"\bedi\b", r"\bebp\b", r"\besp\b"
]

for pattern in forbidden:
    if re.search(pattern, text, re.IGNORECASE):
        print("Blocked: detected non-8086 instruction/register usage in write request.")
        sys.exit(2)

sys.exit(0)
