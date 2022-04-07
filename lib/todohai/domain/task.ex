defmodule Todohai.Domain.Task do
  @moduledoc """
  Bussiness logic for Task.
  """
  alias Todohai.Schema.Task, as: TaskSchema

  @persistance_implementation Application.compile_env(:todohai, :persistance_implementation)

  @type task_schema :: %TaskSchema{}
  @type invalid_parrent_error :: {:error, {:cannot_add_invalid_parent, String.t()}}
  @type invalid_text_for_child_error ::
          {:error, {:cannot_add_child_task_with_invalid_text, String.t()}}

  @spec add_child_task(task_schema, String.t()) :: {:ok, task_schema}
  def add_child_task(parent_task, text) do
    with :ok <- exits?(parent_task),
         :ok <- is_allowed_text?(text),
         :ok <- check_duplicate(parent_task, text) do
      child_task =
        %{
          text: text,
          done: false,
          parent: parent_task
        }
        |> new()

      {:ok, child_task}
    end
  end

  def check_duplicate(parent_task, text) do
    case list_by(%{parent: parent_task, text: text}) do
      [] ->
        :ok

      _child_tasks ->
        {:error, {:duplicate_child_task, "Already existing child task with text '#{text}'"}}
    end
  end

  @spec is_allowed_text?(String.t()) :: :ok | invalid_text_for_child_error
  defp is_allowed_text?(text) do
    case String.length(text) <= 50 do
      true -> :ok
      false -> {:error, {:cannot_add_child_task_with_invalid_text, "The text is too long"}}
    end
  end

  @spec exits?(task_schema) :: :ok | invalid_parrent_error
  def exits?(parent_task) do
    case list_by(%{id: parent_task.id}) do
      [] ->
        {:error,
         {:cannot_add_invalid_parent,
          "The parent task with id #{parent_task.id} doesn't exist anymore"}}

      [_parent_task] ->
        :ok
    end
  end

  @spec list_tasks() :: list(task_schema)
  def list_tasks() do
    @persistance_implementation.list_tasks()
  end

  @spec list_by(map()) :: list(task_schema)
  def list_by(attrs) do
    @persistance_implementation.list_by(attrs)
  end

  @spec new(map()) :: task_schema()
  def new(attrs) do
    @persistance_implementation.new(attrs)
  end
end
