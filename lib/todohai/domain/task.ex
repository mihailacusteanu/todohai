defmodule Todohai.Domain.Task do
  @moduledoc """
  Bussiness logic for Task.
  """
  alias Todohai.Schema.Task, as: TaskSchema

  @persistance_implementation Application.compile_env(:todohai, :persistance_implementation)

  @type task_schema :: %TaskSchema{}
  @type is_allowed_text_return_type ::
          :ok | {:error, {:cannot_add_child_task_with_invalid_text, String.t()}}
  @type check_duplicate_return_type :: :ok | {:error, {:duplicate_child_task, String.t()}}
  @type exits_return_type :: :ok | {:error, {:cannot_add_invalid_parent, String.t()}}
  @type mark_as_done_by_id_return_type ::
          {:ok, task_schema} | {:error, {:cannot_mark_as_done_by_id, String.t()}}

  defdelegate delete_by_id(id), to: @persistance_implementation
  defdelegate list_tasks(), to: @persistance_implementation
  defdelegate list_by(attrs), to: @persistance_implementation
  defdelegate new(attrs), to: @persistance_implementation
  defdelegate find_by_id(id), to: @persistance_implementation
  defdelegate update_by_id(id, attrs), to: @persistance_implementation

  @doc """
  adds a child task for the given text and parent.
  """
  @spec add_child_task(task_schema, String.t()) :: {:ok, task_schema}
  def add_child_task(parent_task, text) do
    with :ok <- exits?(parent_task),
         :ok <- is_allowed_text?(text),
         :ok <- check_duplicate(parent_task, text) do
      {:ok, _parent} = update_by_id(parent_task.id, %{is_parent: true})

      {:ok, child_task} =
        %{
          text: text,
          done: false,
          parent: parent_task
        }
        |> new()

      {:ok, child_task}
    end
  end

  @doc """
  Mark the task as done by id.
  """
  @spec mark_as_done_by_id(non_neg_integer()) :: mark_as_done_by_id_return_type
  def mark_as_done_by_id(id) do
    case update_by_id(id, %{done: true}) do
      {:ok, task} ->
        {:ok, task}

      {:error, {:cannot_update_task_by_id, _string_error}} ->
        {:error, {:cannot_mark_as_done_by_id, "The task with id=#{id} doesn't exist"}}
    end
  end

  @spec check_duplicate(task_schema, String.t()) :: check_duplicate_return_type
  defp check_duplicate(parent_task, text) do
    case list_by(%{parent: parent_task, text: text}) do
      [] ->
        :ok

      _child_tasks ->
        {:error, {:duplicate_child_task, "Already existing child task with text '#{text}'"}}
    end
  end

  @spec is_allowed_text?(String.t()) :: is_allowed_text_return_type
  defp is_allowed_text?(text) do
    case String.length(text) <= 50 do
      true -> :ok
      false -> {:error, {:cannot_add_child_task_with_invalid_text, "The text is too long"}}
    end
  end

  @spec exits?(task_schema) :: exits_return_type
  defp exits?(parent_task) do
    case list_by(%{id: parent_task.id}) do
      [] ->
        {:error,
         {:cannot_add_invalid_parent,
          "The parent task with id #{parent_task.id} doesn't exist anymore"}}

      [_parent_task] ->
        :ok
    end
  end
end
