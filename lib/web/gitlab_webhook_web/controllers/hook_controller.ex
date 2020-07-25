defmodule GitlabWebhookWeb.HookController do
  use GitlabWebhookWeb, :controller

  def create(conn, params) do
    Hook.Dispatcher.dispatch(params)
    # 200が返せればいいので空jsonを返す
    json(conn, %{})
  end
end
