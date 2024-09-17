TED := https://data.europa.eu/api/hub/store/data/ted-contract-award-notices-2023.zip

data/derived/sme_by_country_CPV.csv: src/count_smes.sql data/raw/export_CAN_2023.csv
	mkdir -p $(dir $@)
	duckdb < $< > $@
data/raw/export_CAN_2023.csv: data/raw/ted-contract-award-notices-2023.zip
	unzip -d $(dir $@) $<
	touch $@
data/raw/ted-contract-award-notices-2023.zip: 
	mkdir -p $(dir $@)
	curl -L -o $@ $(TED)