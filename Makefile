RM      := rm -rf
FIND    := find

LOCAL_LIBS := $(shell pwd)/libs

export LD_LIBRARY_PATH := $(LOCAL_LIBS):$(LD_LIBRARY_PATH)

install:
	@clear && uv sync

run:
	@clear
	@# Rodamos o uv run com o ambiente de bibliotecas configurado
	@uv run python -m src $(ARGS)

debug:
	@clear
	@uv run python -m pdb -m src

clean:
	@clear
	@echo "Cleaning project cache..."
	@$(FIND) . -type d -name "__pycache__" -exec $(RM) {} +
	@$(FIND) . -type d -name ".mypy_cache" -exec $(RM) {} +
	@$(FIND) . -type d -name ".pytest_cache" -exec $(RM) {} +
	@$(FIND) . -type f -name "*.pyc" -delete
	@$(FIND) . -type f -name "*.pyo" -delete
	@$(RM) .venv

lint:
	@clear && uv run flake8 .
	@uv run mypy . --warn-return-any \
		--warn-unused-ignores \
		--ignore-missing-imports \
		--disallow-untyped-defs \
		--check-untyped-defs

lint-strict:
	@clear && uv run flake8 .
	@uv run mypy . --strict

.PHONY: install run debug clean lint lint-strict