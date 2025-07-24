# Makefile voor data workflow project

.PHONY: all collect transform analyze report

all: collect transform analyze report

collect:
	bash data_collect.sh

transform:
	bash data_transform.sh

analyze:
	python3 analyze_data.py

report:
	bash raport_data.sh

clean:
