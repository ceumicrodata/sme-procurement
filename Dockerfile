# Start with the official Julia 1.10 image
FROM julia:1.10

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install Python 3.11 and other dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as the default python and python3 version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python /usr/bin/python3.11 \
    && update-alternatives --set python3 /usr/bin/python3.11

# Verify Python installation
RUN python --version && python3 --version

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH
ENV PATH="/root/.local/bin:$PATH"

# Install DuckDB 1.1.0
RUN curl -L https://github.com/duckdb/duckdb/releases/download/v1.1.0/duckdb_cli-linux-amd64.zip -o duckdb.zip \
    && unzip duckdb.zip \
    && mv duckdb /usr/local/bin/duckdb \
    && chmod +x /usr/local/bin/duckdb \
    && rm duckdb.zip

# Set up working directory
WORKDIR /app

# Copy Julia and Python dependency files
COPY Project.toml pyproject.toml ./

# Set Julia to always use the project in the current directory
ENV JULIA_PROJECT=@.

# Install Julia dependencies
RUN julia --project -e 'using Pkg; Pkg.instantiate()'

# Install Python dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

# Set the default command to run when starting the container
CMD ["/bin/bash"]