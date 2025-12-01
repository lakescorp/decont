# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output

fileOutputPath="$2"/$(basename "$1" .tar.gz)

if [[ -e $fileOutputPath ]]; then
  echo "File $fileOutputPath already exists. Skipping download."
else
    wget -q -O "$fileOutputPath" "$1"
    expected_md5=$(wget -qO- "$1.md5" | awk '{print $1}')
    actual_md5=$(md5sum "$fileOutputPath" | awk '{print $1}')
    if [[ "$expected_md5" != "$actual_md5" ]]; then
        echo "MD5 checksum mismatch for $fileOutputPath"
        rm -f "$fileOutputPath"
        exit 1
    fi
fi

if [[ "yes" == "$3" ]]; then
  gunzip -k "$fileOutputPath"
fi
