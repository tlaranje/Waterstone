RM        := rm -rf
PROJ_NAME := src/src.csproj

SGOINFRE  := $(shell [ -d "$(HOME)/sgoinfre" ] \
	&& echo "$(HOME)/sgoinfre/hs_overlay" \
	|| echo "$(CURDIR)/.local")

DOTNET_ROOT     := $(SGOINFRE)/.dotnet
NUGET_PACKAGES  := $(SGOINFRE)/.nuget
DOTNET_CLI_HOME := $(SGOINFRE)/.dotnet_home
DIRENV_BIN      := $(HOME)/.local/bin/direnv
DOTNET          := $(DOTNET_ROOT)/dotnet

all: install build

install: install-direnv install-dotnet
	@$(DOTNET) new install Avalonia.Templates --force

install-direnv:
	@if ! command -v direnv >/dev/null 2>&1 \
		&& [ ! -x "$(DIRENV_BIN)" ]; then \
		curl -sfL https://direnv.net/install.sh | bash; \
	fi
	@direnv allow >/dev/null 2>&1 \
		|| $(DIRENV_BIN) allow >/dev/null 2>&1 || true

install-dotnet:
	@mkdir -p "$(DOTNET_ROOT)" "$(NUGET_PACKAGES)" "$(DOTNET_CLI_HOME)"
	@if [ ! -x "$(DOTNET)" ]; then \
		curl -sSL https://raw.githubusercontent.com/dotnet/\
install-scripts/main/src/dotnet-install.sh \
			-o /tmp/dotnet-install.sh; \
		chmod +x /tmp/dotnet-install.sh; \
		/tmp/dotnet-install.sh \
			--install-dir "$(DOTNET_ROOT)" --channel 9.0; \
	fi

build:
	@$(DOTNET) build $(PROJ_NAME)

run:
	@clear
	@$(DOTNET) run --project $(PROJ_NAME) $(ARGS)

clean:
	@$(RM) src/bin src/obj .templateengine

fclean: clean
	@$(RM) ".local"

.PHONY: all install build run install-direnv install-dotnet clean fclean