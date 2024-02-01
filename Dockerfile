# Use OpenJDK JDK image for intermiediate build
FROM eclipse-temurin:17-jdk-ubi9-minimal AS build

# Build from source and create artifact
WORKDIR /src
RUN set -eux; \
    microdnf install -y \
        git \
    ; \
    microdnf clean all


ADD https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar BuildTools.jar
RUN MAVEN_OPTS="-Xmx2G" java -Xmx2G -jar BuildTools.jar

# Use OpenJDK JRE image for runtime
FROM eclipse-temurin:17-jre-ubi9-minimal AS run


# Copy artifact from build image
COPY --from=build /src/spigot-*.jar /app/spigot.jar

# Create minecraft u
# Ports
EXPOSE 25565
EXPOSE 25575
EXPOSE 19132
RUN groupadd -r -g 1000 minecraft \
    && useradd -r -u 1000 -g minecraft -m -d /opt/minecraft -s /bin/bash minecraft

# User and group to run as
USER minecraft:minecraft

# Volumes
VOLUME /data /opt/minecraft

# Set runtime workdir
WORKDIR /data

# Run app
ENTRYPOINT ["java"]
CMD [ "-jar","-Xms2G", "-Xmx2G", "-XX:+UseG1GC", "/app/spigot.jar", "nogui" ]
