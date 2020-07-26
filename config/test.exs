use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gitlab_webhook, GitlabWebhookWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :gitlab_webhook, :stalker,
  [[]]

config :gitlab_webhook, :external,
  graphql_api_endpoint: "",
  rest_api_endpoint: "",
  access_token: "",
  slack_notice_endpoint: ""
