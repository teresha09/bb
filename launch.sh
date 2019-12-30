#!/bin/bash
cadecarr=()
psytararr=()
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
IFS=$'\n'
for directory in ${SCRIPTPATH}/NER_DIR/cadec_folds_biobert/*
do
for fold in $directory
do
echo $fold
cadecarr+=("$fold")
done
done
for directory1 in ${SCRIPTPATH}/NER_DIR/psytar_folds_biobert/*
do
for fold1 in $directory1
do
echo $fold1
psytararr+=("$fold1")
done
done
mkdir "/tmp/bioner/"
for (( i=0; i < "${#cadecarr[@]}"; i++ ))
do
mkdir "/tmp/bioner/"
mkdir "/tmp/bioner/cadec_fold_0${i}_cadec_test"
outputdir=/tmp/bioner/cadec_fold_0${i}_cadec_test
python3 run_ner.py --do_train=true --do_eval=true --vocab_file=${SCRIPTPATH}/BIOBERT_DIR/vocab.txt \
    --bert_config_file=${SCRIPTPATH}/BIOBERT_DIR/bert_config.json \
    --init_checkpoint=${SCRIPTPATH}/BIOBERT_DIR/biobert_model.ckpt \
    --num_train_epochs=10.0 \
    --data_dir="${cadecarr[$i]}" \
    --output_dir=$outputdir
cp /tmp/bioner/cadec_fold_0${i}_cadec_test -R /tmp/bioner/cadec_fold_0${i}_psytar_test
outputdir1=/tmp/bioner/cadec_fold_0${i}_psytar_test
python3 run_ner.py --do_train=false --do_predict=true --do_eval=true --vocab_file=${SCRIPTPATH}/BIOBERT_DIR/vocab.txt \
    --bert_config_file=${SCRIPTPATH}/BIOBERT_DIR/bert_config.json \
    --init_checkpoint=${SCRIPTPATH}/BIOBERT_DIR/biobert_model.ckpt \
    --num_train_epochs=10.0 \
    --data_dir="${cadecarr[$i]}" \
    --output_dir=$outputdir
python3 run_ner.py --do_train=false --do_predict=true --do_eval=true --vocab_file=${SCRIPTPATH}/BIOBERT_DIR/vocab.txt \
    --bert_config_file=${SCRIPTPATH}/BIOBERT_DIR/bert_config.json \
    --init_checkpoint=${SCRIPTPATH}/BIOBERT_DIR/biobert_model.ckpt \
    --num_train_epochs=10.0 \
    --data_dir="${psytararr[$i]}" \
    --output_dir=$outputdir1
python3 biocodes_detok.py \
--tokens=${outputdir}/token_test.txt \
--labels=${outputdir}/label_test.txt \
--save_to=${outputdir}/NER_result_conll.txt
perl ${SCRIPTPATH}/biocodes/conlleval.pl < ${outputdir}/NER_result_conll.txt
python3 biocodes_detok.py \
--tokens=${outputdir1}/token_test.txt \
--labels=${outputdir1}/label_test.txt \
--save_to=${outputdir1}/NER_result_conll.txt
perl ${SCRIPTPATH}/biocodes/conlleval.pl < ${outputdir1}/NER_result_conll.txt
done
for (( i=0; i < "${#psytararr[@]}"; i++ ))
do
mkdir "/tmp/bioner/psytar_fold_0${i}_cadec_test"
outputdir=/tmp/bioner/psytar_fold_0${i}_cadec_test
python3 run_ner.py --do_train=true --do_eval=true --vocab_file=${SCRIPTPATH}/BIOBERT_DIR/vocab.txt \
    --bert_config_file=${SCRIPTPATH}/BIOBERT_DIR/bert_config.json \
    --init_checkpoint=${SCRIPTPATH}/BIOBERT_DIR/biobert_model.ckpt \
    --num_train_epochs=10.0 \
    --data_dir="${psytararr[$i]}" \
    --output_dir=$outputdir
cp /tmp/bioner/psytar_fold_0${i}_cadec_test -R /tmp/bioner/psytar_fold_0${i}_psytar_test
outputdir1=/tmp/bioner/psytar_fold_0${i}_psytar_test
python3 run_ner.py --do_train=false --do_predict=true --do_eval=true --vocab_file=${SCRIPTPATH}/BIOBERT_DIR/vocab.txt \
    --bert_config_file=${SCRIPTPATH}/BIOBERT_DIR/bert_config.json \
    --init_checkpoint=${SCRIPTPATH}/BIOBERT_DIR/biobert_model.ckpt \
    --num_train_epochs=10.0 \
    --data_dir="${cadecarr[$i]}" \
    --output_dir=$outputdir
python3 run_ner.py --do_train=false --do_predict=true --do_eval=true --vocab_file=${SCRIPTPATH}/BIOBERT_DIR/vocab.txt \
    --bert_config_file=${SCRIPTPATH}/BIOBERT_DIR/bert_config.json \
    --init_checkpoint=${SCRIPTPATH}/BIOBERT_DIR/biobert_model.ckpt \
    --num_train_epochs=10.0 \
    --data_dir="${psytararr[$i]}" \
    --output_dir=$outputdir1
python3 biocodes_detok.py \
--tokens=${outputdir}/token_test.txt \
--labels=${outputdir}/label_test.txt \
--save_to=${outputdir}/NER_result_conll.txt
perl ${SCRIPTPATH}/biocodes/conlleval.pl < ${outputdir}/NER_result_conll.txt
python3 biocodes_detok.py \
--tokens=${outputdir1}/token_test.txt \
--labels=${outputdir1}/label_test.txt \
--save_to=${outputdir1}/NER_result_conll.txt
perl biocodes/conlleval.pl < ${outputdir1}/NER_result_conll.txt
done