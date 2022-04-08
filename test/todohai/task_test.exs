defmodule Todohai.Test.TaskTest do
  @moduledoc false
  use ExUnit.Case
  alias Todohai.Domain.Task
  alias Todohai.Schema.Task, as: TaskSchema

  setup do
    task1 = %TaskSchema{text: "task1", id: 1, done: false, parent: nil}
    task2 = %TaskSchema{text: "task2", id: 2, done: false, parent: nil}
    task3 = %TaskSchema{text: "task3", id: 3, done: false, parent: nil}
    task4 = %TaskSchema{text: "task4", id: 4, done: false, parent: task1}
    task5 = %TaskSchema{text: "task5", id: 5, done: false, parent: task2}

    list_of_tasks = [
      task1,
      task2,
      task3,
      task4,
      task5
    ]

    Agent.start_link(
      fn ->
        list_of_tasks
      end,
      name: :in_memory_task_persistance
    )

    {:ok, %{list_of_tasks: list_of_tasks}}
  end

  describe "list tasks" do
    test "all", %{list_of_tasks: list_of_tasks} do
      assert list_of_tasks == Task.list_tasks()
    end

    test "all by id", %{list_of_tasks: list_of_tasks} do
      task = List.first(list_of_tasks)
      assert [task] == Task.list_by(%{id: task.id})
    end
  end

  describe "create new task" do
    test "and succeeed" do
      text = "new task"
      {:ok, new_task} = Task.new(%{text: text})
      assert new_task in Task.list_tasks()
    end
  end

  describe "add child task" do
    test "and succeed" do
      parent_task = %TaskSchema{text: "task3", id: 3, done: false, parent: nil}
      {:ok, child_task} = Task.add_child_task(parent_task, "Child Task 2")
      assert child_task.parent == parent_task
    end

    test "and fail because of invalid parent" do
      parent_task = %TaskSchema{text: "task1", id: -1, done: false, parent: nil}

      assert {:error,
              {:cannot_add_invalid_parent, "The parent task with id -1 doesn't exist anymore"}} =
               Task.add_child_task(parent_task, "Child Task 2")
    end

    test "and fail because of text too long" do
      child_text =
        "TextIsTooLongTextIsTooLongTextIsTooLongTextIsTooLongTextIsTooLongTextIsTooLong"

      parent_task = %TaskSchema{text: "task3", id: 3, done: false, parent: nil}

      assert {
               :error,
               {
                 :cannot_add_child_task_with_invalid_text,
                 "The text is too long"
               }
             } = Task.add_child_task(parent_task, child_text)
    end

    test "and fail because of duplicate text", %{list_of_tasks: list_of_tasks} do
      existing_child_task =
        list_of_tasks
        |> Enum.find(fn t -> not is_nil(t.parent) end)

      parent_task = existing_child_task.parent

      string_error = "Already existing child task with text '#{existing_child_task.text}'"

      assert {:error, {:duplicate_child_task, string_error}} ==
               Task.add_child_task(parent_task, existing_child_task.text)
    end
  end

  describe "delete a task" do
    test "and succeeed" do
      {:ok, to_be_deleted_task} = Task.new(%{text: "new task 1"})
      :ok = Task.delete_by_id(to_be_deleted_task.id)
      assert to_be_deleted_task not in Task.list_tasks()
    end

    test "and fail because of missing task" do
      {:error, {:cannot_delete_task_by_id, "The task with id=0 doesn't exist"}} =
        Task.delete_by_id(0)
    end
  end
end
