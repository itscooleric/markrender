FROM python:3.13-slim-bookworm

ARG PANDOC_VERSION=3.10.1
ARG WEASYPRINT_VERSION=70.0

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HOME=/tmp

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        fonts-dejavu-core \
        libffi8 \
        libharfbuzz-subset0 \
        libjpeg62-turbo \
        libopenjp2-7 \
        libpango-1.0-0 \
        libpangoft2-1.0-0 \
        shared-mime-info; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
        amd64|arm64) ;; \
        *) echo "unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL \
        "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${arch}.deb" \
        -o /tmp/pandoc.deb; \
    apt-get install -y --no-install-recommends /tmp/pandoc.deb; \
    pip install --no-cache-dir "weasyprint==${WEASYPRINT_VERSION}"; \
    pandoc --version | head -n 1; \
    weasyprint --version; \
    rm -f /tmp/pandoc.deb; \
    rm -rf /var/lib/apt/lists/*

COPY render.sh /app/render.sh
COPY theme-dark.css /app/theme-dark.css
RUN chmod +x /app/render.sh

WORKDIR /work
ENTRYPOINT ["/app/render.sh"]
