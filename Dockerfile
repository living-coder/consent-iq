# Build stage - Flutter web build
FROM dart:latest AS flutter-builder

WORKDIR /flutter

# Install git and other dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter
RUN git clone --depth 1 https://github.com/flutter/flutter.git . && \
    ./bin/flutter config --no-analytics && \
    ./bin/flutter precache --web

ENV PATH="/flutter/bin:$PATH"

# Verify Flutter installation
RUN flutter doctor -v

# App builder stage
FROM dart:latest AS app-builder

WORKDIR /app

# Copy Flutter
COPY --from=flutter-builder /flutter /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Copy project files
COPY pubspec.yaml pubspec.lock* ./

# Get Flutter/Dart dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build Flutter web app
RUN flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true

# Production stage - Node.js with pre-built web app
FROM node:18-alpine

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache ca-certificates openssl

# Copy package files
COPY package.json package-lock.json* ./

# Install Node dependencies (production only)
RUN npm ci --production

# Copy built Flutter web app
COPY --from=app-builder /app/build/web ./public

# Copy server files
COPY server.js .
COPY .env.example .env

# Create uploads directory
RUN mkdir -p uploads

# Expose port (build arg with default)
ARG PORT=3000
ENV PORT=${PORT}
EXPOSE ${PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + process.env.PORT, (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

CMD ["node", "server.js"]
