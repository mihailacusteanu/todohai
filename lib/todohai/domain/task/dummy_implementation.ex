defmodule Todohai.Domain.Task.DummyImplementation do
  @moduledoc """
  Dummy implementation for persistance for testing.
  """
  @behaviour Todohai.Domain.Task.PersistanceImplementation

  alias Todohai.Schema.Task, as: TaskSchema

  @impl true
  def list_tasks() do
    task1 = %TaskSchema{text: "John", id: 1, done: false, parent: nil}
    task2 = %TaskSchema{text: "Jane", id: 2, done: false, parent: nil}
    task3 = %TaskSchema{text: "Joe", id: 3, done: false, parent: nil}
    task4 = %TaskSchema{text: "Jack", id: 4, done: false, parent: task1}
    task5 = %TaskSchema{text: "Jill", id: 5, done: false, parent: task2}

    [
      task1,
      task2,
      task3,
      task4,
      task5
    ]
  end

  @impl true
  def new(attrs) do
    struct(%TaskSchema{}, Map.merge(attrs, %{id: Enum.random(1..10_000_000)}))
  end

  @impl true
  def list_by(attrs) do
    list_tasks()
    |> Enum.filter(fn task ->
      attrs
      |> Enum.all?(fn {k, v} ->
        Map.from_struct(task)[k] == v
      end)
    end)
  end
end
