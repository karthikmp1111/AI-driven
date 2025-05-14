#!/bin/bash
set -e

# Cleanup previous package
rm -rf python lambda_function.zip

# Install dependencies
pip install -r requirements.txt -t python/

# Zip dependencies and your function
cd python && zip -r9 ../lambda_function.zip . && cd ..
zip -g lambda_function.zip lambda_function.py