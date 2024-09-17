# Start with a base Ubuntu image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.0-linux-x86_64.tar.gz \
    && tar -xvzf julia-1.10.0-linux-x86_64.tar.gz \
    && mv julia-1.10.0 /opt/julia \
    && ln -s /opt/julia/bin/julia /usr/local/bin/julia \
    && rm julia-1.10.0-linux-x86_64.tar.gz

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3.11 -

# Install DuckDB
RUN wget https://github.com/duckdb/duckdb/releases/download/v0.9.2/duckdb_cli-linux-amd64.zip \
    && unzip duckdb_cli-linux-amd64.zip \
    && mv duckdb /usr/local/bin/ \
    && rm duckdb_cli-linux-amd64.zip

# Set up working directory
WORKDIR /app

# Copy Julia and Python dependency files
COPY Project.toml .
COPY pyproject.toml .

# Install Julia dependencies
RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'

# Install Python dependencies
RUN /root/.local/bin/poetry config virtualenvs.create false \
    && /root/.local/bin/poetry install --no-interaction --no-ansi

# Copy the rest of your application
COPY . .

# Set the default command to run when starting the container
CMD ["/bin/bash"]