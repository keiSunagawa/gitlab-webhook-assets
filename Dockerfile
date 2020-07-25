FROM elixir:latest

ENV MIX_ENV=prod \
    SECRET_KEY_BASE=aaa

RUN mkdir /src

COPY ./ /src/gitlab_webhook

RUN rm -rf /src/gitlab_webhook/_build && rm -rf /src/gitlab_webhook/deps

RUN cd /src/gitlab_webhook && mix local.rebar --force && mix local.hex --force && mix deps.get --only prod --force && mix compile

ENTRYPOINT cd /src/gitlab_webhook && mix phx.server
