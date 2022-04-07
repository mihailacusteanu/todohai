defmodule Todohai.Domain.Task.PersistanceImplementation do
  @moduledoc false

  alias Todohai.Schema.Task, as: TaskSchema

  @type task_schema :: %TaskSchema{}
  @type list_of_task_schema :: list(task_schema)

  @callback list_tasks() :: list_of_task_schema
  @callback new(map()) :: task_schema
  @callback list_by(map()) ::
              list(task_schema) | {:error, {:get_task_by_attrs_not_found, String.t()}}
end
