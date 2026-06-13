FROM node:18-alpine AS builder

WORKDIR /app

# Install Flutter dependencies
RUN apk add --no-cache git curl unzip bash

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /flutter && \
    /flutter/bin/flutter config --no-analytics && \
    /flutter/bin/flutter precache

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Copy project files
COPY package.json pubspec.yaml ./
RUN npm install && flutter pub get

# Copy source code
COPY . .

# Build Flutter web app
RUN flutter build web --release

# Production stage
FROM node:18-alpine

WORKDIR /app

COPY package.json ./
RUN npm install --production

# Copy built Flutter app
COPY --from=builder /app/build/web ./public

# Copy server files
COPY server.js .
COPY .env.example .env

# Expose port (build arg with default)
ARG PORT=3000
ENV PORT=${PORT}
EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + process.env.PORT, (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

CMD ["node", "server.js"]
