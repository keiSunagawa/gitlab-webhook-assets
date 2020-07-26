defmodule External.SlackClient do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    endpoint = Application.fetch_env!(:gitlab_webhook, :external)[:slack_notice_endpoint]

    state = %{
      endpoint: endpoint
    }
    {:ok, state}
  end

  def handle_call({:notice, icon, channel, text}, _from, state) do
    %HTTPoison.Response{status_code: 200, body: body}  = HTTPoison.post!(
      state.endpoint,
      Jason.encode!(%{
            "icon_emoji" => icon,
            "text" => text,
            "username" => "gitlab web hook bot",
            "channel" => channel
                    }),
      [
        {"Content-Type", "application/json"},
      ]
    )
    {:reply, body, state}
  end

  def notice(icon, channel, text), do: GenServer.call(__MODULE__, {:notice, icon, channel, text})
end
