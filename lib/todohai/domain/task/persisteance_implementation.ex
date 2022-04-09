defmodule Todohai.Domain.Task.PersistanceImplementation do
  @moduledoc false

  alias Todohai.Schema.Task, as: TaskSchema

  @type task_schema :: %TaskSchema{}
  @type list_of_task_schema :: list(task_schema)
  @type list_by_return_type ::
          list_of_task_schema | {:error, {:get_task_by_attrs_not_found, String.t()}}
  @type delete_by_id_return_type :: :ok | {:error, {:cannot_delete_task_by_id, String.t()}}
  @type find_by_id_return_type ::
          {:ok, task_schema} | {:error, {:cannot_find_task_by_id, String.t()}}

  @doc """
  List all the tasks.
  """
  @callback list_tasks() :: list_of_task_schema
  @doc """
  List all the tasks that have the given fields of the input attributes.
  """
  @callback list_by(map()) :: list_by_return_type

  @doc """
  Create a new task with the given attributes.
  """
  @callback new(map()) :: {:ok, task_schema}

  @doc """
  deletes the task with the given id.
  """
  @callback delete_by_id(non_neg_integer()) :: delete_by_id_return_type

  @doc """
  Find a task for the given id.
  """
  @callback find_by_id(non_neg_integer()) :: find_by_id_return_type
end
