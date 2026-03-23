FROM openjdk:17-ea-17-jdk-slim

# Create a non-root user and group
RUN groupadd --system appgroup \
    && useradd --system --create-home --gid appgroup appuser

WORKDIR /app

# Copy the JAR built by Jenkins
COPY target/*.jar app.jar

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
