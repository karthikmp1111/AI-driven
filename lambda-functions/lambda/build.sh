# #!/bin/bash
# set -e

# # Cleanup previous package
# rm -rf python lambda_function.zip

# # Install dependencies
# pip install -r requirements.txt -t python/

# # Zip dependencies and your function
# cd python && zip -r9 ../lambda_function.zip . && cd ..
# zip -g lambda_function.zip lambda_function.py

#!/bin/bash
set -e

cd "$(dirname "$0")"

rm -rf python package.zip

pip install -r requirements.txt -t python/

zip -r9 package.zip python/

zip -g package.zip lambda_function.py