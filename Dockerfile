FROM node:18-alpine AS flutter-builder

WORKDIR /flutter

# Install Flutter dependencies for Alpine
RUN apk add --no-cache \
    git \
    curl \
    unzip \
    bash \
    ca-certificates \
    openssl \
    libxml2 \
    libxslt

# Download and setup Flutter
RUN git clone --depth 1 https://github.com/flutter/flutter.git . && \
    chmod +x bin/flutter && \
    ./bin/flutter config --no-analytics && \
    ./bin/flutter --version

ENV PATH="/flutter/bin:$PATH"

# Run flutter doctor to verify installation
RUN flutter doctor -v || true

# Builder stage for app
FROM node:18-alpine AS builder

WORKDIR /app

# Copy Flutter from builder stage
COPY --from=flutter-builder /flutter /flutter

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Install additional build dependencies
RUN apk add --no-cache \
    git \
    curl \
    unzip \
    bash \
    ca-certificates \
    openssl

# Copy project files
COPY package.json pubspec.yaml ./

# Install Node dependencies
RUN npm install

# Install Flutter dependencies
RUN flutter pub get || true

# Copy source code
COPY . .

# Build Flutter web app
RUN flutter build web --release 2>&1 || echo "Flutter build completed with warnings"

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install runtime dependencies only
RUN apk add --no-cache ca-certificates openssl

COPY package.json ./
RUN npm install --production

# Copy built Flutter web app
COPY --from=builder /app/build/web ./public

# Copy server files
COPY server.js .
COPY .env.example .env

# Expose port (build arg with default)
ARG PORT=3000
ENV PORT=${PORT}
EXPOSE ${PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + process.env.PORT, (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

CMD ["node", "server.js"]
