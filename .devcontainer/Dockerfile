# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.5
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

USER root

RUN apt-get update && apt-get install -y nodejs npm

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir -p /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R vscode:vscode /commandhistory

# Create workspace and config directories and set permissions
RUN mkdir -p /workspaces /home/vscode/.claude /home/vscode/.config/gh/ && \
  chown -R vscode:vscode /workspaces /home/vscode/.claude /home/vscode/.config/gh/

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

WORKDIR /workspaces

USER vscode

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Ensure binding is always 0.0.0.0
# Binds the server to all IP addresses of the container, so it can be accessed from outside the container.
ENV BINDING="0.0.0.0"
