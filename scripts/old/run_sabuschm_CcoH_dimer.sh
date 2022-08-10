#!/bin/bash 
 
 module load python-3.7.3 
sudo python3 /home/alphafold/alphafold/docker/run_docker.py --fasta_paths=/home/alphafold/fastas/CcoH.docx --max_template_date=08.07.2022 --model_preset=multimer --data_dir=/home/alphafold/genetic_database_new/ --output_dir=/home/alphafold/results/