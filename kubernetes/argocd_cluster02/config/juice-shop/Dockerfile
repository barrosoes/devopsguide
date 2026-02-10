## Lightweight runtime image:
## - Build happens in a throwaway stage
## - Final image contains only runtime requirements (no .git, tests, sources, etc.)
## - Still runs as non-root in distroless

FROM node:22 AS builder
WORKDIR /juice-shop

# Copy full source (filtered by .dockerignore)
COPY . .

# Root "postinstall" builds server+frontend and needs TypeScript.
# We keep it in the builder stage only (not copied into the runtime image).
RUN npm i -g typescript@5.3.3

RUN npm install --omit=dev --unsafe-perm --no-audit --no-fund \
 && npm dedupe --omit=dev \
 && npm cache clean --force

# Optional: remove large build-time artifacts (not required for runtime)
RUN rm -rf frontend/node_modules frontend/.angular || true

FROM node:22-bookworm-slim AS runtime-prep
WORKDIR /juice-shop

# Runtime dependencies + compiled output
COPY --from=builder /juice-shop/package.json ./package.json
COPY --from=builder /juice-shop/node_modules ./node_modules
COPY --from=builder /juice-shop/build ./build

# Static assets + runtime data/config
COPY --from=builder /juice-shop/frontend/dist/frontend ./frontend/dist/frontend
COPY --from=builder /juice-shop/i18n ./i18n
COPY --from=builder /juice-shop/config ./config
COPY --from=builder /juice-shop/data ./data
COPY --from=builder /juice-shop/ftp ./ftp
COPY --from=builder /juice-shop/.well-known ./.well-known
COPY --from=builder /juice-shop/views ./views
COPY --from=builder /juice-shop/swagger.yml ./swagger.yml
COPY --from=builder /juice-shop/uploads ./uploads

# Prune build outputs not needed at runtime (saves image space)
RUN rm -rf build/test build/rsn \
 && find build -type f -name "*.map" -delete

# Ensure writable dirs exist and are owned/grouped for non-root execution
RUN mkdir -p logs uploads/complaints frontend/dist/frontend/assets/public/images/uploads \
 && chown -R 65532:0 logs \
 && chgrp -R 0 ftp frontend/dist logs data i18n .well-known uploads \
 && chmod -R g=u ftp frontend/dist logs data i18n .well-known uploads

FROM gcr.io/distroless/nodejs22-debian12
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.title="OWASP Juice Shop" \
    org.opencontainers.image.description="Probably the most modern and sophisticated insecure web application" \
    org.opencontainers.image.authors="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.vendor="Open Worldwide Application Security Project" \
    org.opencontainers.image.documentation="https://help.owasp-juice.shop" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.version="19.1.1" \
    org.opencontainers.image.url="https://owasp-juice.shop" \
    org.opencontainers.image.source="https://github.com/juice-shop/juice-shop" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE

WORKDIR /juice-shop
COPY --from=runtime-prep --chown=65532:0 /juice-shop /juice-shop
USER 65532
EXPOSE 3000
CMD ["/juice-shop/build/app.js"]
