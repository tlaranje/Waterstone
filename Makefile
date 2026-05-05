# --- Configurações de Caminho ---
NAME          := HS_Overlay
PROJ_DIR      := src
CS_PROJ       := $(PROJ_DIR)/src.csproj
SGOINFRE      := $(shell [ -d "$(HOME)/sgoinfre" ] \
                 && echo "$(HOME)/sgoinfre/$(USER)/$(NAME)" \
                 || echo "$(HOME)/.local/share/$(NAME)")

DOTNET_ROOT   := $(SGOINFRE)/dotnet
PREFIX        := $(SGOINFRE)/local_libs
VENV          := $(SGOINFRE)/.venv
DOTNET        := $(DOTNET_ROOT)/dotnet
MESON         := $(VENV)/bin/meson
NINJA         := $(VENV)/bin/ninja

# --- Variáveis de Ambiente ---
export PATH            := $(DOTNET_ROOT):$(VENV)/bin:$(PATH)
export LD_LIBRARY_PATH := $(PREFIX)/lib/x86_64-linux-gnu:$(PREFIX)/lib:$(LD_LIBRARY_PATH)
export PKG_CONFIG_PATH := $(PREFIX)/lib/x86_64-linux-gnu/pkgconfig:$(PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH)

all: install build

install: install-dotnet install-venv install-libs
	@echo "🔥 Configurando projeto .NET com GTK3..."
	@if [ ! -f $(CS_PROJ) ]; then \
		$(DOTNET) new console -o $(PROJ_DIR); \
		$(DOTNET) add $(PROJ_DIR) package GtkSharp; \
	fi

install-dotnet:
	@mkdir -p "$(DOTNET_ROOT)"
	@if [ ! -x "$(DOTNET)" ]; then \
		echo "📥 Baixando .NET SDK..." ; \
		curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
			--install-dir "$(DOTNET_ROOT)" --channel 8.0; \
	fi

install-venv:
	@if [ ! -d "$(VENV)" ]; then \
		echo "🐍 Criando .venv para ferramentas de build..."; \
		python3 -m venv $(VENV); \
		$(VENV)/bin/pip install meson ninja; \
	fi

# MUDANÇA AQUI: Clonando a versão GTK3 do layer-shell
install-libs:
	@mkdir -p "$(SGOINFRE)/build"
	@if [ ! -f "$(PREFIX)/lib/libgtk-layer-shell.so" ]; then \
		echo "🛠️ Compilando gtk-layer-shell (GTK3)..."; \
		cd $(SGOINFRE)/build && \
		rm -rf gtk-layer-shell && \
		git clone https://github.com/wmww/gtk-layer-shell.git --recursive && \
		cd gtk-layer-shell && \
		$(MESON) setup build --prefix=$(PREFIX) -Dintrospection=false -Dexamples=false -Dtests=false && \
		$(NINJA) -C build install; \
	fi

build:
	@$(DOTNET) build $(CS_PROJ)

run:
	@$(DOTNET) run --project $(CS_PROJ)

clean:
	@rm -rf $(PROJ_DIR)/bin $(PROJ_DIR)/obj $(SGOINFRE)/build

fclean: clean
	@rm -rf $(SGOINFRE)

.PHONY: all install install-dotnet install-venv install-libs build run clean fclean