defmodule External.RestAPIClient do
  use GenServer

  @endpoint Application.fetch_env!(:gitlab_webhook, :external)[:rest_api_endpoint]
  @token Application.fetch_env!(:gitlab_webhook, :external)[:access_token]

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:create_mr, project, source, target}, _from, state) do
    repo_id = URI.encode_www_form(project)
    %HTTPoison.Response{status_code: 201, body: body}  = HTTPoison.post!(
      "#{@endpoint}/#{repo_id}/merge_requests",
      Jason.encode!(%{
            "source_branch" => source,
            "target_branch" => target,
            "title" => "#{source} to #{target}"
                    }),
      [
        {"Content-Type", "application/json"},
        {"Private-Token", @token}
      ]
    )
    {:reply, Jason.decode!(body), state}
  end

  def create_mr(project, source, target), do: GenServer.call(__MODULE__, {:create_mr, project, source, target})
end
