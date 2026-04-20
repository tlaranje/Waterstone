
# === COMMANDS ===
RM      := rm -rf
NPM     := npm

# === BUILD TARGETS ===

# Instala as dependências do package.json
install:
	@clear && $(NPM) install

# Inicia a aplicação Electron
run:
	@clear && $(NPM) start

# Limpa caches comuns de ferramentas de lint e build do Node
clean:
	@clear
	@echo "Cleaning project cache..."
	@$(RM) .eslintcache
	@$(RM) dist/
	@$(RM) out/

# Remove completamente as dependências (equivalente ao fclean da 42)
fclean: clean
	@echo "Removing node_modules..."
	@$(RM) node_modules
	@$(RM) package-lock.json

# Reinstala tudo do zero
re: fclean install

# Roda o Linter (Assumindo que você instalou ESLint)
lint:
	@clear && $(NPM) run lint

# Atalho para build (empacotar o app para executável)
build:
	@clear && $(NPM) run build

.PHONY: install run clean fclean re lint build