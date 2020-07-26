defmodule External.GraphqlClient do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    queries_path = "./graphql"

    queries = File.ls!(queries_path)
    |> Enum.filter(fn file_name ->
      String.ends_with?(file_name, ".gql")
    end)
    |> Enum.map(fn file_name ->
      key = String.replace(file_name, ".gql", "")
      {key, File.read!("#{queries_path}/#{file_name}")}
    end)
    |> Enum.into(%{})

    endpoint = Application.fetch_env!(:gitlab_webhook, :external)[:graphql_api_endpoint]
    token = Application.fetch_env!(:gitlab_webhook, :external)[:access_token]

    state = %{
      queries: queries,
      endpoint: endpoint,
      token: token,
      queries_path: queries_path
    }
    {:ok, state}
  end

  def handle_call({:query, query_name, variables}, _from, state) do
    %HTTPoison.Response{status_code: 200, body: body}  = HTTPoison.post!(
      state.endpoint,
      Jason.encode!(%{"query" => state.queries[query_name], "variables" => variables}),
      [
        {"Content-Type", "application/json"},
        {"Private-Token", state.token}
      ]
    )
    {:reply, Jason.decode!(body), state}
  end

  def query(query_name, variables), do: GenServer.call(__MODULE__, {:query, query_name, variables})
end
