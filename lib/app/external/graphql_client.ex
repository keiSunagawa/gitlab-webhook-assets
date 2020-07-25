defmodule External.GraphqlClient do
  use GenServer

  @endpoint Application.fetch_env!(:gitlab_webhook, :external)[:graphql_api_endpoint]
  @token Application.fetch_env!(:gitlab_webhook, :external)[:access_token]
  @queries_path "./graphql"

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    queries = File.ls!(@queries_path)
    |> Enum.filter(fn file_name ->
      String.ends_with?(file_name, ".gql")
    end)
    |> Enum.map(fn file_name ->
      key = String.replace(file_name, ".gql", "")
      {key, File.read!("#{@queries_path}/#{file_name}")}
    end)
    |> Enum.into(%{})
    {:ok, queries}
  end

  def handle_call({:query, query_name, variables}, _from, queries) do
    %HTTPoison.Response{status_code: 200, body: body}  = HTTPoison.post!(
      @endpoint,
      Jason.encode!(%{"query" => queries[query_name], "variables" => variables}),
      [
        {"Content-Type", "application/json"},
        {"Private-Token", @token}
      ]
    )
    {:reply, Jason.decode!(body), queries}
  end

  def query(query_name, variables), do: GenServer.call(__MODULE__, {:query, query_name, variables})
end
