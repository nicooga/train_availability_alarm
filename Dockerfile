FROM elixir:1.5.2-alpine

RUN mix local.hex --force && mix local.rebar --force

# Set workdir
ARG APP_PATH=/opt/app
WORKDIR $APP_PATH

# Install elixir deps
COPY mix.exs mix.lock ./
RUN mix deps.get

# Compile all used environments to
# prevent compilation when running the image
COPY config ./config
RUN mix deps.compile

COPY . .
RUN mix compile.app

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["mix run --no-halt"]
