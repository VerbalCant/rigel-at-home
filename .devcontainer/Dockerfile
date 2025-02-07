FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install basic dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    build-essential \
    curl \
    git \
    libpq-dev \
    postgresql-client \
    python3 \
    python3-pip \
    libffi-dev \
    libreadline-dev \
    libyaml-dev \
    libssl-dev \
    zlib1g-dev \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn

# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
    && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc \
    && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
    && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby
ENV PATH /root/.rbenv/bin:$PATH
RUN eval "$(rbenv init -)" \
    && rbenv install 3.2.2 \
    && rbenv global 3.2.2 \
    && gem install bundler

# Install Python packages
RUN pip3 install --no-cache-dir \
    openai \
    requests \
    python-dotenv

WORKDIR /workspace 