# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.5
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Create directories and set permissions for Claude Code
RUN mkdir -p /commandhistory /workspaces /home/vscode/.claude /opt && \
  touch /commandhistory/.bash_history && \
  touch /commandhistory/.zsh_history && \
  chown -R vscode:vscode /commandhistory /workspaces /home/vscode/.claude /opt

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

WORKDIR /workspaces

USER vscode

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Ensure binding is always 0.0.0.0
# Binds the server to all IP addresses of the container, so it can be accessed from outside the container.
ENV BINDING="0.0.0.0"
