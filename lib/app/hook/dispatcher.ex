defmodule Hook.Dispatcher do
  def dispatch(event) do
    case event["object_kind"] do
      "issue" ->
        # IssueHook関数の列を取得 eventを受け取る引数1の関数群を期待
        Hook.IssueHooks.__info__(:functions)
        |> Enum.each(fn finfo ->
          case finfo do
            {f, 1} -> apply(Hook.IssueHooks, f, [event])
            {f, n} -> IO.puts("invalid function. #{f}/#{n}")
          end
        end)
      "merge_request" ->
        Hook.MRHooks.__info__(:functions)
        |> Enum.each(fn finfo ->
          case finfo do
            {f, 1} -> apply(Hook.MRHooks, f, [event])
            {f, n} -> IO.puts("invalid function. #{f}/#{n}")
          end
        end)
      _otherwise ->
        {}
    end

  end
end
