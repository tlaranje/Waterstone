DOTNET := $(shell command -v dotnet 2> /dev/null)
PROJ_NAME := src/src.csproj

all: install build

install:
	@clear
	@if [ -z "$(DOTNET)" ]; then \
		echo "Instalando .NET SDK em $(DOTNET_ROOT)..."; \
		curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --install-dir $(DOTNET_ROOT) --channel 8.0; \
	else \
		echo ".NET já está disponível via .envrc"; \
	fi
	@dotnet new install Avalonia.Templates --force

build:
	@dotnet build $(PROJ_NAME)

run:
	@clear
	@dotnet run --project $(PROJ_NAME) $(ARGS)

clean:
	@clear
	@echo "Cleaning .NET artifacts..."
	@rm -rf **/bin **/obj .templateengine

.PHONY: all install build run clean