defmodule Stalker.MREvent do
  defstruct [
    :project_path,
    :mr_iid,
    :target_branch,
    :source_branch,
    :state
  ]
end
