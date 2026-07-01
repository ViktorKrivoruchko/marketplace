.PHONY: help install install-backend install-frontend \
        dev dev-backend dev-frontend \
        build test lint format clean fclean

# ═══════════════════════════════════════════════════
#  Переменные
# ═══════════════════════════════════════════════════

UV         = uv
PYTHON     = backend/.venv/bin/python
UVICORN    = backend/.venv/bin/uvicorn
PYTEST     = backend/.venv/bin/pytest
RUFF       = backend/.venv/bin/ruff

BACKEND_DIR  = backend/app
FRONTEND_DIR = frontend
APP_MODULE   = main:app

# ═══════════════════════════════════════════════════
#  help
# ═══════════════════════════════════════════════════

help:
	@echo ""
	@echo "  Доступные команды:"
	@echo ""
	@echo "  make install       — установить все зависимости"
	@echo "  make dev           — запустить бэкенд + фронтенд"
	@echo "  make build         — собрать фронтенд для продакшна"
	@echo "  make test          — запустить тесты"
	@echo "  make lint          — проверить стиль кода"
	@echo "  make format        — автоформатирование кода"
	@echo ""

# ═══════════════════════════════════════════════════
#  Установка зависимостей
# ═══════════════════════════════════════════════════

install: install-backend install-frontend

install-backend:
	@echo "→ Устанавливаем зависимости Python через uv..."
	cd $(BACKEND_DIR) && $(UV) sync

install-frontend:
	@echo "→ Устанавливаем зависимости Node..."
	cd $(FRONTEND_DIR) && npm install

# ═══════════════════════════════════════════════════
#  Разработка
# ═══════════════════════════════════════════════════

dev:
	@echo "→ Запускаем бэкенд и фронтенд..."
	$(MAKE) -j2 dev-backend dev-frontend

dev-backend:
	cd $(BACKEND_DIR) && $(UV) run uvicorn $(APP_MODULE) --reload --port 8003

dev-frontend:
	cd $(FRONTEND_DIR) && pnpm run dev

# ═══════════════════════════════════════════════════
#  Сборка для продакшна
# ═══════════════════════════════════════════════════

build:
	@echo "→ Собираем фронтенд..."
	cd $(FRONTEND_DIR) && npm run build
	@echo "✓ Готово: $(FRONTEND_DIR)/dist"

# ═══════════════════════════════════════════════════
#  Тесты
# ═══════════════════════════════════════════════════

test: test-backend test-frontend

test-backend:
	@echo "→ Тесты бэкенда..."
	cd $(BACKEND_DIR) && $(UV) run pytest tests/ -v

test-frontend:
	@echo "→ Тесты фронтенда..."
	cd $(FRONTEND_DIR) && npm test -- --watchAll=false

# ═══════════════════════════════════════════════════
#  Линтинг и форматирование
# ═══════════════════════════════════════════════════

lint:
	@echo "→ Проверяем Python..."
	cd $(BACKEND_DIR) && $(UV) run ruff check app
	@echo "→ Проверяем JS/TS..."
	cd $(FRONTEND_DIR) && npm run lint

format:
	@echo "→ Форматируем Python..."
	cd $(BACKEND_DIR) && $(UV) run ruff format app
	@echo "→ Форматируем JS/TS..."
	cd $(FRONTEND_DIR) && npm run format

# ═══════════════════════════════════════════════════
#  Докер
# ═══════════════════════════════════════════════════

up-docker:
	@echo "→ Запускаем Docker Compose..."
	docker compose -f infra/docker-compose.yml up -d

rs-docker:
	@echo "→ Перезапускаем Docker Compose..."
	docker compose -f infra/docker-compose.yml down
	docker compose -f infra/docker-compose.yml build --no-cache
	docker compose -f infra/docker-compose.yml up -d