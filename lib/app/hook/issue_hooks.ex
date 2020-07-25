defmodule Hook.IssueHooks do
  require Logger

  def noop(_e) do
    Logger.debug "noop on issue hook"
  end
end
