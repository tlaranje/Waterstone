# --- Configurações ---
NAME     := HS_Overlay
SRC_DIR  := src
INC_DIR  := $(SRC_DIR)/includes

SGOINFRE := $(shell [ -d "$(HOME)/sgoinfre" ] \
            && echo "$(HOME)/sgoinfre/$(USER)/$(NAME)" \
            || echo "$(HOME)/.local/share/$(NAME)")
PREFIX   := $(SGOINFRE)/local_libs
VENV     := $(SGOINFRE)/.venv
MESON    := $(VENV)/bin/meson
NINJA    := $(VENV)/bin/ninja

# --- Ficheiros ---
SRCS     := $(shell find $(SRC_DIR) -maxdepth 1 -name "*.c")
OBJS     := $(SRCS:.c=.o)

# --- Compilação (lazy = para avaliar após install) ---
PKG_DEPS := gtk4 gtk4-layer-shell-0 wayland-client
CC       := gcc
CFLAGS    = -Wall -Wextra -I$(INC_DIR) \
             $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --cflags $(PKG_DEPS))
LDFLAGS   = $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --libs $(PKG_DEPS))

# --- Ambiente ---
export PATH            := $(VENV)/bin:$(PATH)
export LD_LIBRARY_PATH := $(PREFIX)/lib/x86_64-linux-gnu:$(PREFIX)/lib:$(LD_LIBRARY_PATH)
export PKG_CONFIG_PATH := $(PREFIX)/share/pkgconfig:$(PREFIX)/lib/x86_64-linux-gnu/pkgconfig:$(PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH)

# =============================================================================

all: install build

install: install-venv install-wayland-protocols install-gtk4-layer-shell

install-venv:
	@if [ ! -d "$(VENV)" ]; then \
		echo "🐍 Criando venv para meson/ninja..."; \
		python3 -m venv $(VENV); \
		$(VENV)/bin/pip install -q meson ninja; \
	fi

install-wayland-protocols: install-venv
	@mkdir -p "$(SGOINFRE)/build"
	@if ! PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --exists wayland-protocols 2>/dev/null; then \
		echo "🛠️  Compilando wayland-protocols..."; \
		cd $(SGOINFRE)/build && \
		rm -rf wayland-protocols && \
		git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git && \
		cd wayland-protocols && \
		$(MESON) setup build --prefix=$(PREFIX) -Dtests=false && \
		$(NINJA) -C build install; \
	else \
		echo "✅ wayland-protocols já disponível, a saltar..."; \
	fi

install-gtk4-layer-shell: install-venv
	@mkdir -p "$(SGOINFRE)/build"
	@if [ ! -f "$(PREFIX)/lib/libgtk4-layer-shell.so" ] && \
	   [ ! -f "$(PREFIX)/lib/x86_64-linux-gnu/libgtk4-layer-shell.so" ]; then \
		echo "🛠️  Compilando gtk4-layer-shell..."; \
		cd $(SGOINFRE)/build && \
		rm -rf gtk4-layer-shell && \
		git clone https://github.com/wmww/gtk4-layer-shell.git --recursive && \
		cd gtk4-layer-shell && \
		$(MESON) setup build --prefix=$(PREFIX) \
			-Dintrospection=false \
			-Dexamples=false \
			-Dtests=false \
			-Dvapi=false && \
		$(NINJA) -C build install; \
	else \
		echo "✅ gtk4-layer-shell já instalado, a saltar..."; \
	fi

# --- Compilação ---
build: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(OBJS) -o $(NAME) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run: build
	./$(NAME)

clean:
	@rm -f $(OBJS)

fclean: clean
	@rm -f $(NAME)
	@rm -rf $(SGOINFRE)

re: fclean all

.PHONY: all install install-venv install-wayland-protocols install-gtk4-layer-shell build run clean fclean re