#!/bin/bash

####################
# Variables - feel free to change these to suit your environment
####################
# Path to dir containing all files to be processed (please include '/' at the end of the final directory)
File_Base="/localdisk/data/BPSM/MyFirstPipeline"
# TIMESTAMP=$(date +"%d_%m_%Y_%H_%M")
TIMESTAMP=test
fqc_out="fast_qc_output_${TIMESTAMP}"
reports="reports_${TIMESTAMP}"
db_name="my_pipeline_database"
sample_file="${File_Base}/Tcongo_genome/Tco2.fqfiles"
####################

# Empty arrary, sequences that pass QC2 will be added to this
keep=()

# output and report directory setup - 
# no clearout of a folder if running again as new folders will be created with new timestamp
# (assumes more than 1 min will pass between repeat runs)
if [[ ! -d ${fqc_out} ]]; then
echo "Creating an output directory for fastqc output - ${fqc_out}"
mkdir ${fqc_out}
fi

if [[ ! -d ${reports} ]]; then
echo "Creating a directory for reports that will be generated - ${reports}"
mkdir ${reports}
fi

# QC1 - fastqc programme
# We process all fq.gz files present in the fastq dir
# --extract flag unzips the fastqc output files for use later
# --delete deletes the original zip files
echo -e "INFO: Starting fastqc analysis"
fastqc -o ${fqc_out} -f fastq --delete --extract ${File_Base}/fastq/*fq.gz
rm -f ${fqc_out}/*.html # Clean up - remove html files (we don't need them)

# QC2 - Based on summary data generated from the above step, we reject any 
# files that contain certain failures. We reference the summary.txt for info because
# it has the info we care about in a nice to parse format. 
echo "INFO: reviewing output from fastqc"
failures="${reports}/failures_from_summaries${TIMESTAMP}.txt"

for item in $(ls ${fqc_out} | grep -v "html" | sort)
do
	# Search summary file for specific failures
	grep "FAIL" ${fqc_out}/${item}/summary.txt | grep -E "Per base sequence quality|Per sequence quality scores|Per base N content|Per sequence GC content" >> ${failures}
	# $? is exit code of previous command. If grep doesn't find anything then it
	# exits with code 1, if it does find something then output it to file and exit w code  0
	if [[ $? == 0 ]]; then
		${keep}+=( ${item} )
	else
	echo "WARN: ${item} has been rejected, please see ${failures} file for info on which checks failed" 
	fi
done

if [[ ! -f ${failures} ]]; then
echo "INFO: All items have passed QC2, moving onto alignment"
else
echo -e "WARN: Some Items have failed QC2, please see ${failures} for more info\nINFO: Moving onto alignment for those that have passed QC2"
fi

# Create database with the data that has passed QC2

makeblastdb -in ${sample} -input_type fasta -dbtype nucl -out ${db_name}

# Run Bowtie

# Convert output

# Bedtools