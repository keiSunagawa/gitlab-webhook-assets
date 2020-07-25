defmodule Hook.MRHooks do
  def stalker(e) do
    if e["object_attributes"]["action"] == "merge" do
      ev = stalker_conv(e)
      Stalker.Main.run(ev)
    end
  end

  defp stalker_conv(e) do
    %Stalker.MREvent {
      project_path: e["project"]["path_with_namespace"],
      mr_iid: e["object_attributes"]["iid"],
      target_branch: e["object_attributes"]["target_branch"],
      source_branch: e["object_attributes"]["source_branch"],
      state: e["object_attributes"]["state"]
    }
  end
end
