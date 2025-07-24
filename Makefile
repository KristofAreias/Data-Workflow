# Makefile voor data workflow project

.PHONY: all setup collect transform analyze report

all: setup collect transform analyze report

setup:
	chmod +x data_collect.sh data_transform.sh raport_data.sh

collect:
	bash data_collect.sh

transform:
	bash data_transform.sh

analyze:
	python3 analyze_data.py

report:
	bash raport_data.sh
