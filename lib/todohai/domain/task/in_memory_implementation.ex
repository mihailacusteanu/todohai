defmodule Todohai.Domain.Task.InMemoryImplementation do
  @moduledoc """
  Dummy implementation for persistance for testing.
  """
  @behaviour Todohai.Domain.Task.PersistanceImplementation

  alias Todohai.Schema.Task, as: TaskSchema

  @impl true
  def list_tasks() do
    Agent.get(:in_memory_task_persistance, & &1)
  end

  @impl true
  def new(attrs) do
    new_task = struct(%TaskSchema{}, Map.merge(attrs, %{id: Enum.random(1..10_000_000)}))

    Agent.update(:in_memory_task_persistance, &(&1 ++ [new_task]))
    {:ok, new_task}
  end

  @impl true
  def list_by(attrs) do
    list_of_tasks =
      Agent.get(:in_memory_task_persistance, fn tasks ->
        tasks
      end)

    list_of_tasks
    |> Enum.filter(fn task ->
      attrs
      |> Enum.all?(fn {k, v} ->
        Map.from_struct(task)[k] == v
      end)
    end)
  end

  @impl true
  def delete_by_id(id) do
    list_of_tasks = list_tasks()

    list_of_task_after_deletion =
      list_of_tasks
      |> Enum.filter(fn task ->
        task.id != id
      end)

    case Enum.find(list_of_tasks, fn t -> t.id == id end) do
      nil ->
        {:error, {:cannot_delete_task_by_id, "The task with id=#{id} doesn't exist"}}

      _ ->
        Agent.update(:in_memory_task_persistance, fn _tasks -> list_of_task_after_deletion end)
    end
  end

  @impl true
  def find_by_id(id) do
    list_of_tasks = list_tasks()

    case Enum.find(list_of_tasks, fn t -> t.id == id end) do
      nil -> {:error, {:cannot_find_task_by_id, "The task with id=#{id} doesn't exist"}}
      task -> {:ok, task}
    end
  end

  @impl true
  def update_by_id(id, attrs) do
    list_of_tasks = list_tasks()

    list_of_tasks_after_update =
      list_of_tasks
      |> Enum.map(fn task ->
        if task.id == id do
          Map.merge(task, attrs)
        else
          task
        end
      end)

    Agent.update(:in_memory_task_persistance, fn _tasks -> list_of_tasks_after_update end)

    case Enum.find(list_of_tasks_after_update, fn t -> t.id == id end) do
      nil -> {:error, {:cannot_update_task_by_id, "The task with id=#{id} doesn't exist"}}
      task -> {:ok, task}
    end
  end
end
