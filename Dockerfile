# ── Stage 1: Build Flutter web ────────────────────────────────────────────────
# Pre-built image: Flutter SDK already installed, no clone needed.
FROM ghcr.io/cirruslabs/flutter:stable AS app-builder

WORKDIR /app

# Resolve dependencies first so this layer is cached when pubspec is unchanged.
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy source and compile.
COPY . .
RUN flutter build web --release --no-tree-shake-icons

# ── Stage 2: Lightweight Node.js runtime ──────────────────────────────────────
FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache ca-certificates openssl

COPY package.json package-lock.json* ./
RUN npm install --production

COPY --from=app-builder /app/build/web ./public
COPY server.js .
COPY .env.example .env

RUN mkdir -p uploads

ARG PORT=3000
ENV PORT=${PORT}
EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + process.env.PORT, (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

CMD ["node", "server.js"]
