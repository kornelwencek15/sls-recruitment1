# Selects the JAR source: defaults to maven-build for local use.
# CI overrides this with --build-arg BUILD_SOURCE=ci-build.
ARG BUILD_SOURCE=maven-build


# used for local/standalone builds - produces the application JAR from source code
FROM maven:3.9-eclipse-temurin-17 AS maven-build

WORKDIR /build

# cache Maven dependencies separately from source code
# it is only rebuilt when pom.xml changes, not on every source change
COPY pom.xml .
RUN mvn dependency:go-offline -B -q

COPY src ./src
RUN mvn clean package -DskipTests -B -q && cp target/devops-test-*.jar /app.jar


# ci-build stage: used when the JAR is pre-built by CI and passed via build context.
# Avoids running Maven twice (once in the test job, once here).
FROM scratch AS ci-build
COPY target/devops-test-*.jar /app.jar


FROM ${BUILD_SOURCE} AS jar-source


# extract spring layers for cache utilization
FROM eclipse-temurin:17-jre AS extractor

WORKDIR /extract
COPY --from=jar-source /app.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract


# final stage
FROM eclipse-temurin:17-jre AS runtime

RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

COPY --from=extractor /extract/dependencies/ ./
COPY --from=extractor /extract/spring-boot-loader/ ./
COPY --from=extractor /extract/snapshot-dependencies/ ./
COPY --from=extractor /extract/application/ ./

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -sf http://localhost:8080/health || exit 1

ENTRYPOINT ["java", \
    "-XX:+UseContainerSupport", \
    "-XX:MaxRAMPercentage=75.0", \
    "org.springframework.boot.loader.launch.JarLauncher"]
