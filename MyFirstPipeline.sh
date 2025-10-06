#!/bin/bash


# Path to dir containing all files to be processed (please include '/' at the end of the final directory)
File_Base="/localdisk/data/BPSM/MyFirstPipeline"

TIMESTAMP=$(date +"%d_%m_%Y_%H_%M")
fqc_out="fast_qc_output_${TIMESTAMP}"
reports="reports_${TIMESTAMP}"

disregard=()
keep=( )

# output and report directory setup
if [[ ! -d ${fqc_out} ]]; then
mkdir ${fqc_out}
fi

if [[ ! -d ${reports} ]]; then
mkdir ${reports}
fi

# QC1 - fastqc
fastqc -o ${fqc_out} -f fastq --delete --extract ${File_Base}/fastq/*fq.gz

# QC2 - output summary data to report    
failures="${reports}/failures_and_warns_from_summaries${TIMESTAMP}.txt"
no_failures="${reports}/passes_from_summaries${TIMESTAMP}.txt"


for item in $(ls ${fqc_out} | grep -v "html" | sort)
do
	grep "FAIL" ${fqc_out}/$item/summary.txt | grep -E "Per base sequence quality|Per sequence quality scores|Per base N content|Per sequence GC content" >> ${failures}
	if [[ $? != 1 ]]; then
		${keep}+=${item}
	fi


done

echo ${keep} 

