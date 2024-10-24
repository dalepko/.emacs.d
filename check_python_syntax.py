#! /usr/bin/env python
import sys

try:
    compile(sys.stdin.read(), "titi.py", "exec")
except SyntaxError:
    sys.exit(1)
