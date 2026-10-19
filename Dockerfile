FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PATH="/opt/venv/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-tk chromium chromium-driver \
    xvfb xauth ca-certificates fonts-liberation \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m venv --system-site-packages /opt/venv \
    && useradd --create-home --uid 1000 robot

# Debian Chromium reads these flags for every launch, including QWeb/QForce.
RUN printf '%s\n' 'export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --no-sandbox --disable-dev-shm-usage --window-size=1920,1080"' \
    > /etc/chromium.d/robot \
    && printf '#!/bin/sh\nexec /usr/bin/chromium "$@"\n' > /usr/local/bin/google-chrome \
    && chmod +x /usr/local/bin/google-chrome

WORKDIR /app
COPY requirements.txt /app/requirements.txt
# QWeb pulls in evdev on Linux, which requires a compiler and kernel headers.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential python3-dev linux-libc-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir -r requirements.txt

# Supply the organization's approved Linux-compatible QForce distribution here.
COPY docker/wheels/ /opt/wheels/
RUN if find /opt/wheels -name '*.whl' -print -quit | grep -q .; then \
      pip install --no-cache-dir /opt/wheels/*.whl; \
    fi

COPY tests/ /app/tests/
COPY docker/entrypoint.sh /usr/local/bin/run-tests
RUN chmod +x /usr/local/bin/run-tests && mkdir /app/results \
    && chown -R robot:robot /app /opt/venv
USER robot
ENTRYPOINT ["/usr/local/bin/run-tests"]
CMD ["tests/"]
