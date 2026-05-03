# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tlaranje <tlaranje@student.42porto.com>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/02/26 12:06:51 by tlaranje          #+#    #+#              #
#    Updated: 2026/04/06 10:40:48 by tlaranje         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# === VARIABLES ===
RM        := rm -rf
DOTNET    := $(shell command -v dotnet 2>/dev/null)
PROJ_NAME := src/src.csproj

# === DIRENV SETUP ===
DIRENV_BIN := $(HOME)/.local/bin/direnv

define INSTALL_DIRENV
	@if ! command -v direnv >/dev/null 2>&1 && [ ! -x "$(DIRENV_BIN)" ]; then \
		echo "Installing direnv..."; \
		curl -sfL https://direnv.net/install.sh | bash; \
		export PATH="$(HOME)/.local/bin:$$PATH"; \
	else \
		echo "direnv already installed."; \
	fi; \
	direnv allow >/dev/null 2>&1 || true
endef

# === TARGETS ===
all: install build

install: install-direnv
	@clear
	@if [ -z "$(DOTNET)" ]; then \
		echo "Instalando .NET SDK em $(DOTNET_ROOT)..."; \
		curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- \
			--install-dir $(DOTNET_ROOT) \
			--channel LTS; \
	else \
		echo ".NET já está disponível via .envrc"; \
	fi
	@dotnet new install Avalonia.Templates --force

build:
	@dotnet build $(PROJ_NAME)

run:
	@clear
	@dotnet run --project $(PROJ_NAME) $(ARGS)

install-direnv:
	$(INSTALL_DIRENV)

clean:
	@clear
	@echo "Cleaning .NET artifacts..."
	@$(RM) **/bin **/obj .templateengine

fclean: clean
	@echo "Removing sgoinfre cache..."
	@$(RM) $(HOME)/sgoinfre/$(shell basename $(CURDIR))/.venv

.PHONY: all install build run install-direnv clean fclean