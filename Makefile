.PHONY: test smoke bench install

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

install:
	@mkdir -p "$(BINDIR)"
	@ln -sf "$(CURDIR)/bin/harness" "$(BINDIR)/harness"
	@test -e "$(BINDIR)/seh" || ln -sf "$(CURDIR)/bin/seh" "$(BINDIR)/seh"
	@echo "Installed: $(BINDIR)/harness"

test:
	PYTHONPATH=src python3 -m pytest -q

smoke:
	PYTHONPATH=src python3 -m seh --version
	PYTHONPATH=src python3 -m seh modules list
	PYTHONPATH=src python3 -m seh optimize status

bench:
	PYTHONPATH=src python3 -m seh bench --trials 10
