defmodule GitlabWebhook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GitlabWebhookWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GitlabWebhook.PubSub},
      # Start the Endpoint (http/https)
      GitlabWebhookWeb.Endpoint,
      # Start a worker by calling: GitlabWebhook.Worker.start_link(arg)
      # {GitlabWebhook.Worker, arg}
      External.GraphqlClient,
      External.RestAPIClient,
      External.SlackClient
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GitlabWebhook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GitlabWebhookWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
