# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

if [[ -e $2/$3.fastq.gz ]]; then
  echo "Merged file $2/$3.fastq.gz already exists. Skipping merge."
  exit 0
fi

mkdir -p $2
files=$(ls $1/$3*.fastq.gz | sort)

for file in $files
do
  gunzip -k "$file"
  uncompressedFile="$1"/$(basename "$file" .gz)
  cat "$uncompressedFile" >> "$2/$3.fastq"
  rm "$uncompressedFile"
done

gzip "$2/$3.fastq"