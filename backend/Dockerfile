FROM python:3.14-slim

# latest or 0.5.24
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project

COPY . .
RUN uv sync --frozen

RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8003

CMD [".venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8003"]