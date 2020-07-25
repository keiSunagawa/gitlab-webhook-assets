defmodule GitlabWebhookWeb.PageController do
  use GitlabWebhookWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
