
# Step 1: Build stage with Maven and Java 17
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy Maven configuration and source code
COPY pom.xml .
COPY src ./src

# Download project dependencies
RUN mvn dependency:go-offline -B

# Compile application and test classes without running tests
RUN mvn test-compile

# Step 2: Test stage with Maven, Java 17, and Chromium
FROM maven:3.9-eclipse-temurin-17

WORKDIR /app

# Install Chromium and dependencies for headless Selenium
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    ca-certificates \
    wget \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libfontconfig1 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Copy the Maven project, compiled classes, and dependencies
COPY --from=build /app /app

# Configure Chrome/Chromium for Selenium
ENV CHROME_BIN=/usr/bin/chromium

# Run TestNG/Selenium tests
CMD ["mvn", "test"]
