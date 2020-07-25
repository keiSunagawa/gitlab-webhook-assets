defmodule Stalker.Main do
  @project_path Application.fetch_env!(:gitlab_webhook, :stalker)[:project_path]
  @stalker_branch Application.fetch_env!(:gitlab_webhook, :stalker)[:stalker_branch]
  @victim_branch Application.fetch_env!(:gitlab_webhook, :stalker)[:victim_branch]

  def run(ev) do
    if (
      ev.project_path == @project_path and
      ev.target_branch == @victim_branch and
      !mr_exists?(ev.project_path, @victim_branch, @stalker_branch)
    ) do
      # create mr
      External.RestAPIClient.create_mr(ev.project_path, @victim_branch, @stalker_branch)
      # send notice
    end
  end

  def mr_exists?(project, source, target) do
    q = """
    query {
      project(fullPath:"#{project}") {
        mergeRequests(
          targetBranches:["#{target}"],
          state: opened
        ) {
          nodes {
            iid,
            title,
            sourceBranch
          }
        }
      }
    }
    """
    res = External.GraphqlClient.query(q)
    IO.inspect res
    res["data"]["project"]["mergeRequests"]["nodes"] |> Enum.any?(fn n ->
      n["sourceBranch"] == source
    end)
  end
end

defmodule Stalker.MainTest do
  def f() do
    ev = %Stalker.MREvent {
      project_path: "root/foo",
      mr_iid: "1",
      target_branch: "staging",
      source_branch: "hoge",
      state: "merged"
    }
    Stalker.Main.run(ev)
  end
end
