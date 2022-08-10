#!/bin/bash 
 
 module load python-3.7.3 
sudo python3 /home/alphafold/alphafold/docker/run_docker.py --fasta_paths=/home/alphafold/fastas/paNOX.txt --max_template_date=2022-11-07 --model_preset=monomer --data_dir=/home/alphafold/genetic_database_new/ --output_dir=/home/alphafold/results/