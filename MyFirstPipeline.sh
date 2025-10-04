#!/bin/bash
#

# Path to dir containing all files to be processed (please include '/' at the end of the final directory)
File_Base="/localdisk/data/BPSM/MyFirstPipeline"

TIMESTAMP=$(date +"%d_%m_%Y_%H_%M")
#fqc_out="fast_qc_output_${TIMESTAMP}"
fqc_out="fast_qc_output"
reports="reports"

# output and report directory setup
if [[ ! -d ${fqc_out} ]]; then
mkdir ${fqc_out}
#else
#rm -rf ${fqc_out}/*
fi

if [[ ! -d ${reports} ]]; then
mkdir ${reports}
fi

# QC1 - fastqc
#fastqc -o ${fqc_out} -f fastq --delete --extract ${File_Base}/fastq/*.gz

# QC2 - output summary data to report    
# ####################################### do we do something with basic stats here???? ########################
failures="${reports}/failures_and_warns_from_summaries${TIMESTAMP}.txt"
no_failures="${reports}/passes_from_summaries${TIMESTAMP}.txt"

for item in $(ls ${fqc_out} | grep -v "html" | sort)
do
	grep -E "FAIL|WARN" ${fqc_out}/$item/summary.txt >> ${failures}
#	if [[ $? == 1 ]]; then
#		grep "PASS" ${fqc_out}/$item/summary.txt | cut -f3 | head -1 >> ${no_failures} 
#	fi
done

sort ${failures} -o ${failures}
sed -i '1 a The following failures and warnings were extracted from the fastqc summary output:' ${failures}


