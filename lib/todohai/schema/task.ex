defmodule Todohai.Schema.Task do
  @moduledoc """
  Temporary struct for Task.
  """
  defstruct text: "task", id: 0, done: false, parent: nil
end
