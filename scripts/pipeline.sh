#Download all the files specified in data/filenames
for url in $(cat data/urls) #TODO
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes #TODO

# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

# Merge the samples into a single file
sampleids=$(ls data/*.fastq.gz | cut -d "-" -f1 | sed 's:data/::' | sort | uniq)
mkdir -p out/trimmed log/cutadapt
for sid in $sampleids
do
    bash scripts/merge_fastqs.sh data out/merged $sid
    # TODO: run cutadapt for all merged files
    # cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
    #     -o <trimmed_file> <input_file> > <log_file>
    if [[ -e out/trimmed/$sid.trimmed.fastq.gz ]]; then
      echo "Trimmed file out/trimmed/$sid.trimmed.fastq.gz already exists. Skipping cutadapt."
      continue
    fi
    touch log/cutadapt/$sid.log
    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
     -o out/trimmed/$sid.trimmed.fastq.gz out/merged/$sid.fastq.gz > log/cutadapt/$sid.log
done

# TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename

    sid=$(basename "$fname" .trimmed.fastq.gz)
    if [[ -d out/star/$sid ]]; then
      echo "STAR output directory out/star/$sid already exists. Skipping STAR."
      continue
    fi
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
        --outReadsUnmapped Fastx --readFilesIn out/trimmed/$sid.trimmed.fastq.gz \
        --readFilesCommand gunzip -c --outFileNamePrefix out/star/${sid}/
done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
logPipe="log/pipeline.log"

for sid in $sampleids
do
    echo "Sample ID: $sid" >> $logPipe
    grep 'Reads with adapters' log/cutadapt/$sid.log >> $logPipe
    grep 'Total basepairs' log/cutadapt/$sid.log >> $logPipe
    grep 'Uniquely mapped reads %' out/star/$sid/Log.final.out >> $logPipe
    grep '% of reads mapped to multiple loci' out/star/$sid/Log.final.out >> $logPipe
    grep '% of reads mapped to too many loci' out/star/$sid/Log.final.out >> $logPipe
    echo "" >> $logPipe
done