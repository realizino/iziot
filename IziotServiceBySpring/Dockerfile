# syntax=docker/dockerfile:1

########################################
# Stage 1: build the WAR with Maven
########################################
FROM maven:3.8.6-eclipse-temurin-17 AS build
WORKDIR /build

# Cache the local maven repo so dependency re-downloads only happen once
COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 mvn -B -q dependency:go-offline

COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B -q clean package -DskipTests

########################################
# Stage 2: runtime image
########################################
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Non-root runtime user (uid 1000 matches typical bind-mount ownership)
RUN useradd --uid 1000 --user-group --shell /bin/sh iziot \
    && mkdir -p /app/Files/Present /app/Files/Repository /app/Files/Snapshots

COPY --from=build /build/target/jowncms-0.0.1-SNAPSHOT.war /app/app.war

# Loaded at runtime via relative paths from the working directory
# (see IOTHubController watermark/font rendering)
COPY CenturyGothic.ttf watermark.png /app/

RUN chown -R iziot:iziot /app
USER iziot

ENV JAVA_OPTS=""
EXPOSE 8080

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.war"]
