#!/usr/bin/env python3

import json

with open("boli.score", "r") as f:
    # Load the JSON data
    boli_score = json.load(f)

print(boli_score)
