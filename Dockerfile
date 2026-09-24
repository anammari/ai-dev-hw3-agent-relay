FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# uv (matches the project's own tooling)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Install deps first so the lockfile layer caches across rebuilds
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# App code + the static dashboard page
COPY main.py database.py storage.py schemas.py worker.py dashboard.py errors.py ./
COPY dashboard.html ./

EXPOSE 8000

# --host 0.0.0.0 is required inside the container, otherwise the published
# port (-p) looks dead because uvicorn defaults to 127.0.0.1.
CMD [".venv/bin/uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
