FROM python:3.12-alpine3.20 AS builder

ARG WORK_DIR=/app

WORKDIR "$WORK_DIR"

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY core core
COPY backend_redis backend_redis
COPY manage.py requirements.txt ./

RUN apk add --no-cache && \
  python3 -m venv "$VIRTUAL_ENV" && \
  pip3 install -r requirements.txt --no-cache-dir 



FROM python:3.12-alpine3.20 AS runner

ARG APP_USER=appuser
ARG APP_GROUP=appgroup
ARG WORK_DIR=/app

WORKDIR "$WORK_DIR"

ENV DEBUG=False

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder --chown="$APP_USER":"$APP_GROUP" "$WORK_DIR" "$WORK_DIR"
COPY docker-entrypoint.sh "$WORK_DIR"

RUN addgroup "$APP_GROUP" && \
  adduser --disabled-password --shell /usr/sbin/nologin -G "$APP_GROUP" "$APP_USER" && \
  chmod +x "$WORK_DIR/docker-entrypoint.sh" && \
  chown "$APP_USER":"$APP_GROUP" "$WORK_DIR/docker-entrypoint.sh"

USER "$APP_USER"

EXPOSE 9000

ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
