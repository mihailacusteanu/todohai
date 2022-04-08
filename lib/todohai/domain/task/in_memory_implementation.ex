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
    Agent.get(:in_memory_task_persistance, fn tasks ->
      tasks
      |> Enum.filter(fn task ->
        attrs
        |> Enum.all?(fn {k, v} ->
          Map.from_struct(task)[k] == v
        end)
      end)
    end)
  end
end
