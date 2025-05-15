#!/bin/bash
set -e

rm -rf python package.zip

pip install -r requirements.txt -t python/

cd python
zip -r9 ../package.zip .
cd ..

zip -g package.zip lambda_function.py
