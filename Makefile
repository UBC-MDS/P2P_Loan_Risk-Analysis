# P2P Loan Risk Analysis Data Analysis Pipe
# author: Mavis Wong, Yasmin Hassan and Abeba Nigussie Turi
# date: 2024-12-10
# - all: Runs the full pipeline from downloading data to generating the final report.
# - clean: Removes all intermediate and generated files.


.PHONY: all clean

all : reports/p2p_lending_risk_analysis_report.html reports/p2p_lending_risk_analysis_report.pdf reports/p2p_lending_risk_analysis_report_files

# download data
data/raw/loan_data.csv : scripts/download_data.py
	python scripts/download_data.py  \
		--url="https://raw.githubusercontent.com/matmcreative/Lending-Club-Loan-Analysis/refs/heads/main/loan_data.csv" \
		--output_dir=data/raw

# Split data into train and test sets, save to csv
# Data validation 
data/processed/loan_test.csv data/processed/loan_train.csv : data/raw/loan_data.csv scripts/split_validation.py
	python scripts/split_validation.py \
		--data_from=data/raw/loan_data.csv \
		--data_to=data/processed

# EDA
results/figures/boxplot_purpose.png results/figures/boxplot_risk.png results/figures/correlation_heatmap.png results/figures/histograms_grid.png results/figures/loan_category_vs_purpose.png results/figures/risk_categories_distribution.png results/tables/info.csv : data/processed/loan_train.csv
	python scripts/eda.py \
		--input_csv=data/processed/loan_train.csv \
		--output_dir=results
# Preprocessing
results/models/preprocessor.pickle data/processed/scaled_loan_test.csv data/processed/scaled_loan_train.csv : data/processed/loan_test.csv data/processed/loan_train.csv
	python scripts/preprocessing.py \
		--data_from=data/processed \
		--data_to=data/processed \
		--preprocessor_to=results/models

# Model Training
results/tables/cv_results.csv results/tables/target_dist.csv results/figures/param_C_tuning.png : data/processed/loan_train.csv results/models/preprocessor.pickle
	python scripts/model_training.py \
		--data_from=data/processed \
		--data_to=results/tables \
		--preprocessor_from=results/models/preprocessor.pickle

# Model Tuning
results/models/pipeline.pickle results/tables/model_results.csv : data/processed/loan_train.csv results/models/preprocessor.pickle
	python scripts/model_tuning.py \
		--data_from=data/processed \
		--data_to=results/tables \
		--preprocessor_from=results/models/preprocessor.pickle \
		--pipeline_to=results/models

# Model Evaluation
results/tables/test_results.csv results/tables/confusion_matrix.csv results/tables/negative_coef.csv results/tables/positive_coef.csv : data/processed/loan_train.csv data/processed/loan_test.csv results/models/preprocessor.pickle
	python scripts/model_evaluation.py \
		--data_from=data/processed \
		--data_to=results/tables \
		--preprocessor_from=results/models/preprocessor.pickle \
		--pipeline_from=results/models/pipeline.pickle

# build HTML report and copy build to docs folder
reports/p2p_lending_risk_analysis_report.html reports/p2p_lending_risk_analysis_report.pdf: reports/p2p_lending_risk_analysis_report.qmd \
	reports/references.bib \
	results/figures/boxplot_purpose.png \
	results/figures/boxplot_risk.png \
	results/figures/correlation_heatmap.png \
	results/figures/histograms_grid.png \
	results/figures/loan_category_vs_purpose.png \
	results/figures/risk_categories_distribution.png \
	results/figures/param_C_tuning.png \
	results/tables/info.csv \
	results/tables/cv_results.csv \
	results/tables/target_dist.csv \
	results/tables/model_results.csv \
	results/tables/test_results.csv \
	results/tables/confusion_matrix.csv \
	results/tables/negative_coef.csv \
	results/tables/positive_coef.csv 
		quarto render reports/p2p_lending_risk_analysis_report.qmd --to html
		quarto render reports/p2p_lending_risk_analysis_report.qmd --to pdf



# clean up analysis
clean :
	rm -rf data/raw/*

	rm -f  results/models/pipeline.pickle \
	    results/models/preprocessor.pickle 

	rm -f data/processed/loan_test.csv \
	    data/processed/loan_train.csv \
	    data/processed/scaled_loan_test.csv \
		data/processed/scaled_loan_train.csv


#delete images and figures
	rm -f results/figures/boxplot_purpose.png \
		results/figures/boxplot_risk.png \
		results/figures/correlation_heatmap.png \
		results/figures/histograms_grid.png \
		results/figures/loan_category_vs_purpose.png \
		results/figures/risk_categories_distribution.png \
		results/figures/param_C_tuning.png \
	rm -f results/tables/info.csv \
		results/tables/cv_results.csv \
		results/tables/target_dist.csv \
		results/tables/model_results.csv \
		results/tables/test_results.csv\
		results/tables/confusion_matrix.csv \
		results/tables/negative_coef.csv \
		results/tables/positive_coef.csv 

	rm -rf reports/p2p_lending_risk_analysis_report.html \
	    reports/p2p_lending_risk_analysis_report.pdf \
		reports/p2p_lending_risk_analysis_report_files 