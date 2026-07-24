# Build stage
FROM gradle:8.4-jdk21 AS builder

WORKDIR /build

COPY . .

RUN ./gradlew build -x test --no-daemon -Dorg.gradle.project.skipGitInfo=true

# Runtime stage
FROM eclipse-temurin:21-jre-jammy

WORKDIR /opt/Lavalink

RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 322 lavalink && \
    useradd -r -u 322 -g lavalink lavalink && \
    chown -R lavalink:lavalink /opt/Lavalink

USER lavalink

COPY --from=builder /build/LavalinkServer/build/libs/Lavalink.jar Lavalink.jar

EXPOSE 2333

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -sf http://localhost:${PORT:-2333}/v4/info || exit 1

ENTRYPOINT ["java", "-Xmx512m", "-Xms256m", "-jar", "Lavalink.jar"]
