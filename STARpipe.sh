####################### STAR pipeline Loops ##############################################
### Before beginning, you will need:
###		1) An overrep file (made by using fastqc)
###		2) Annotation files in gtf format
###		3) An indexed genome file
####################### Step 1: clean and filter #########################################

cd /data/student/jkrausch/Trial_With_STAR/DataRaw

	for OUTPUT1 in $(ls *1.fq.gz)
		do
			cd /tools/BBtools/bbmap/
			./bbduk.sh \
			-in1=/data/student/jkrausch/Trial_With_STAR/DataRaw/${OUTPUT1} \
			-in2=/data/student/jkrausch/Trial_With_STAR/DataRaw/${OUTPUT1%%"1.fq.gz"}2.fq.gz \
			-out1=/data/student/jkrausch/Trial_With_STAR/DataClean/${OUTPUT1%%"fq.gz"}fastq.gz \
			-out2=/data/student/jkrausch/Trial_With_STAR/DataClean/${OUTPUT1%%"1.fq.gz"}2.fastq.gz \
			-ref=/data/student/jkrausch/Trial_With_STAR/Adapter_Ref.fa \
			-qtrim=r -trimq=30 -ktrim=r -k=31 -hdist=1 -tpe=f -tbo=f -t=12
		done

####################### Step 2) gunzip fastq files #######################################

cd /data/student/jkrausch/Trial_With_STAR/DataClean

gunzip *fastq.gz

####################### Step 3) Mapping reads to the genome ##############################

cd /data/student/jkrausch/Trial_With_STAR/DataClean

for OUTPUT2 in $(ls *1.fastq)
		do
			cd /tools/Star/STAR-2.7.9a/bin/Linux_x86_64
			./STAR --runThreadN 12 \
			--genomeDir /data/student/jkrausch/Trial_With_STAR/GenomeDir \
			--readFilesIn /data/student/jkrausch/Trial_With_STAR/DataClean/${OUTPUT2},\
			/data/student/jkrausch/Trial_With_STAR/DataClean/${OUTPUT2%%"1.fastq"}2.fastq \
			--outSAMtype BAM Unsorted SortedByCoordinate \
			--outFileNamePrefix /data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM/${OUTPUT2%%"R1.fastq"} \
			--sjdbOverhang 100
		done

####################### Step 4) Summary stats for BAM files ##############################

cd /data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM

for OUTPUT3 in $(ls *sortedByCoord.out.bam)
    do
        cd /data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM
        echo ${OUTPUT3%%"Aligned.sortedByCoord.out.bam"} >> \
		/data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM/MappingQC.txt
        cd /tools/Samtools-1.13/bin/
        ./samtools flagstat /data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM/${OUTPUT3} >> \
		/data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM/MappingQC.txt
    done
	
####################### Step 5) Indexing sorted BAM files ################################

cd /data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM

for OUTPUT4 in $(ls *sortedByCoord.out.bam)
	do
		cd /tools/Samtools-1.13/bin/
		./samtools index /data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM/${OUTPUT4}
	done

####################### Step 6) Counting RNA-sequencing reads ############################

cd /data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM/
	
for OUTPUT5 $(ls *sortedByCoord.out.bam)
	do
		cd /tools/Samtools-1.13/bin/
		htseq-count -f bam -r pos -s no --idattr Parent \
		/data/student/jkrausch/Trial_With_STAR/OutputBAMandSAM/${OUTPUT5} \
		/data/student/jkrausch/Trial_With_STAR/AnnotationDir/Qrubra_687_v2_1_gene_exons.gtf > \
		/data/student/jkrausch/Trial_With_STAR/CountFiles/${OUTPUT5%%"Aligned.sortedByCoord.out.bam"}_Count.txt
	done

####################### End STAR pipeline Loops ##########################################
### REMEMBER TO QC THE CLEAN/FILTERED READS USING fastqc
##########################################################################################