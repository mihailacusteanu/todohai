defmodule Todohai.Schema.Task do
  @moduledoc """
  Temporary struct for Task.
  """
  defstruct text: "task", id: nil, done: false, parent: nil, is_parent: false
end
