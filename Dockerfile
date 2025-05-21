# Base image with Python and Rust
FROM python:3.10-slim

# Install Rust toolchain
RUN apt-get update && apt-get install -y curl build-essential && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env

# Add cargo to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /app

# Install pip dependencies first for better caching
COPY requirements.txt .

# Install packages step by step to debug any issues
RUN pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir openai && \
    pip install --no-cache-dir cmcp mcp-python mcp-proxy && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p output
