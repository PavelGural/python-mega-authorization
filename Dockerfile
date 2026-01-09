# Use Ubuntu 25.10 for ARM64 support
FROM ubuntu:25.10

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    wget \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the script
COPY mega_login.sh .

# Make the script executable
RUN chmod +x mega_login.sh

# Install MEGAcmd for ARM64
RUN wget https://mega.nz/linux/repo/xUbuntu_25.10/arm64/megacmd-xUbuntu_25.10_arm64.deb && \
    apt-get update && \
    apt-get install -y ./megacmd-xUbuntu_25.10_arm64.deb && \
    rm megacmd-xUbuntu_25.10_arm64.deb && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/app/mega_login.sh"]
