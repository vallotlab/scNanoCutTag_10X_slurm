#!/bin/bash
sample_sheet=$1

cores=8
mem=60G
walltime=164:00:00


#CREATE CONFIG FILE : HUMAN, BEADS CURIE, IP, BED = 20k +50k
cd /mnt/beegfs/home/gjouault/Gitlab/scNanoCutTag_10X_slurm

while IFS= read -r line
do

  DATASET_NUMBER=$(echo "$line" | cut -d',' -f1)
  DATASET_NAME=$(echo "$line" | cut -d',' -f2)
  CLEAN_NAME=$(echo "$line" | cut -d',' -f3)
  ASSEMBLY=$(echo "$line" | cut -d',' -f4)
  NANOBC=$(echo "$line" | cut -d',' -f5)
  MARK=$(echo "$line" | cut -d',' -f6)
  DESIGN_TYPE=LBC
  
  echo $DATASET_NUMBER
  echo $DATASET_NAME
  echo $CLEAN_NAME
  echo $ASSEMBLY
  echo $NANOBC
  echo $MARK 
  echo $DESIGN_TYPE
  
  FINAL_NAME=${CLEAN_NAME}_${NANOBC}_${MARK}
  
  echo $FINAL_NAME 
  
  # OUTPUT_DIR=/mnt/beegfs/home/gjouault/stageout/kdi_workspace/1184/02.00/results/scCutTag/${ASSEMBLY}/${FINAL_NAME}
  # or # 
  OUTPUT_DIR=/mnt/beegfs/home/gjouault/stageout/kdi_workspace/1760/02.00/results/scCutTag/${ASSEMBLY}/${FINAL_NAME}

  # FASTQ_DIR=/mnt/beegfs/home/gjouault/stagein/kdi_workspace/1184/02.00/data/${DATASET_NUMBER}/FastqForAllSamples/
  # or # 
  FASTQ_DIR=/mnt/beegfs/home/gjouault/stagein/kdi_workspace/1760/02.00/data/${DATASET_NUMBER}/FastqForAllSamples/


  OUTPUT_CONFIG=/mnt/beegfs/home/gjouault/persistent/tmp_configs/CONFIG_scNanoCutTag_10X_${FINAL_NAME}
  mkdir -p /mnt/beegfs/home/gjouault/persistent/tmp_configs

#Check if we can remove the -- mark
  ./schip_processing.sh GetConf --template  CONFIG_TEMPLATE --configFile species_design_configs.csv --designType ${DESIGN_TYPE} --genomeAssembly ${ASSEMBLY} --outputConfig ${OUTPUT_CONFIG}
 #--mark ${MARK}
 
  # OUTPUT_DIR=/data/kdi_prod/project_result/1184/02.00/results/scCutTag/${ASSEMBLY}/${FINAL_NAME}
  #FASTQ_DIR=/data/kdi_prod/dataset/${DATASET_NUMBER}/export/user/FastqForAllSamples/ 
  # FASTQ_DIR=/data/kdi_prod/dataset/${DATASET_NUMBER}/export/user/fastqs/${DATASET_NAME}/
  # FASTQ_DIR=/data/tmp/gjouault/10X/fastq/${DATASET_NAME}/


  #echo "cd ~/GitLab/scNanoCutTag_10X_slurm/; ./schip_processing.sh All -i ${FASTQ_DIR} -d ${DATASET_NAME} -c ${OUTPUT_CONFIG} -o ${OUTPUT_DIR} --name ${FINAL_NAME} --nanobc ${NANOBC}" | qsub -l "nodes=1:ppn=8,mem=80gb" -N job_${DATASET_NAME}_${MARK}_${ASSEMBLY}

  mkdir -p "$OUTPUT_DIR"
  mkdir -p "$OUTPUT_DIR/logs"

  sbatch \
    --job-name="job_${DATASET_NAME}_${MARK}_${ASSEMBLY}" \
    --cpus-per-task="$cores" \
    --mem="$mem" \
    --time="$walltime" \
    --output="$OUTPUT_DIR/logs/slurm-%j.out" \
    --error="$OUTPUT_DIR/logs/slurm-%j.err" \
    --wrap="cd /mnt/beegfs/home/gjouault/Gitlab/scNanoCutTag_10X_slurm/; ./schip_processing.sh All -i ${FASTQ_DIR} -d ${DATASET_NAME} -c ${OUTPUT_CONFIG} -o ${OUTPUT_DIR} --name ${FINAL_NAME} --nanobc ${NANOBC}"


done < "$sample_sheet"


