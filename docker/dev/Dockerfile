ARG PORT=$PORT

FROM elixir:latest

RUN apt-get update
RUN apt-get install --yes build-essential inotify-tools postgresql-client fish vim

# Install Phoenix packages
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez

WORKDIR /app
EXPOSE ${PORT}

COPY ./config.fish /root/.config/fish/config.fish

ENTRYPOINT fish