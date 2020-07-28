defmodule Stalker.Main do
  require Logger

  def run(ev) do
    # TODO gen server
    settings = Application.fetch_env!(:gitlab_webhook, :stalker)
    Enum.each(settings, fn s ->
      IO.inspect s
      if (
        ev.project_path == s[:project_path] and
        ev.target_branch == s[:victim_branch] and
        ev.source_branch != s[:stalker_branch] and
        !mr_exists?(s[:project_path], s[:victim_branch], s[:stalker_branch])
      ) do
        # create mr
        mr = External.RestAPIClient.create_mr(s[:project_path], s[:victim_branch], s[:stalker_branch])
        # send notice
        created = mr_info(s[:project_path], mr["iid"])
        trigger = mr_info(s[:project_path], ev.mr_iid)
        text = mr_message(s[:slack_notice][:mention], created, trigger)
        External.SlackClient.notice(s[:slack_notice][:icon], s[:slack_notice][:channel], text)
      end
    end)
  end

  # for gitlab 13
  # def mr_exists?(project, source, target) do
  #   res = External.GraphqlClient.query("find_mr_by_target", %{"project" => project, "target" => target})
  #   Logger.debug inspect(res)
  #   res["data"]["project"]["mergeRequests"]["nodes"] |> Enum.any?(fn n ->
  #     n["sourceBranch"] == source
  #   end)
  # end

  # for gitlab 12
  def mr_exists?(project, source, target) do
    res = External.RestAPIClient.find_mr_by(project, source)
    Logger.debug inspect(res)
    res |> Enum.any?(fn n ->
      n["target_branch"] == target
    end)
  end

  def mr_info(project, iid) do
    res = External.GraphqlClient.query("find_mr_by_iid", %{"project" => project, "iid" => to_string(iid)})
    Logger.debug inspect(res)
    res["data"]["project"]["mergeRequest"]
  end

  defp mr_message(mention, mr_info, trigger_mr_info) do
    trigger_mr_msg = trigger_mr_info_message(trigger_mr_info["title"], trigger_mr_info["webUrl"])

    if mr_info["mergeStatus"] == "cannot_be_merged" do
      """
      #{conflict_message(mention, mr_info["title"], mr_info["webUrl"])}
      #{trigger_mr_msg}
      """
    else
      """
      #{create_mr_message(mention, mr_info["title"], mr_info["webUrl"])}
      #{trigger_mr_msg}
      """
    end
  end

  defp create_mr_message(mention, title, url) do
    """
    #{mention}
    `#{title}` を作成しました, approve & mergeをお願いします
    #{url}
    """
  end

  defp conflict_message(mention, title, url) do
    """
    #{mention}
    `#{title}` を作成しました, *conflictが発生しています*
    confict 解消をお願いします :cry:
    #{url}
    """
  end

  defp trigger_mr_info_message(trigger_mr_title, url) do
    """
    ```
    trigger MR:
      title: #{trigger_mr_title}
      link: #{url}
    ```
    """
  end
end

defmodule Stalker.MainTest do
  def f() do
    ev = %Stalker.MREvent {
      project_path: "root/foo",
      mr_iid: "2",
      target_branch: "staging",
      source_branch: "hoge",
      state: "merged"
    }
    Stalker.Main.run(ev)
  end
end
