FROM python:3.9-alpine3.13
LABEL maintainer="kike907"

ENV PYTHONUNBUFFERED=1

# Set workdir
WORKDIR /app

# Copy requirements first (better caching)
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt


# Install Python dependencies
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps

# Copy project files
COPY ./app /app

# Add user and give permissions
RUN adduser --disabled-password --no-create-home duser && \
    chown -R duser:duser /app

# Update PATH
ENV PATH="/py/bin:$PATH"

# Switch to non-root user
USER duser

EXPOSE 8000
