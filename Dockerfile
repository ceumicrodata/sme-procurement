# Start with the official Julia 1.10 image
FROM julia:1.10

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install Python 3.11, DuckDB, and other dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    curl \
    duckdb \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as the default python and python3 version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python /usr/bin/python3.11 \
    && update-alternatives --set python3 /usr/bin/python3.11

# Verify Python and DuckDB installations
RUN python --version && python3 --version && duckdb --version

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH
ENV PATH="/root/.local/bin:$PATH"

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