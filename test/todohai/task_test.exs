defmodule Todohai.Test.TaskTest do
  @moduledoc false
  use ExUnit.Case
  alias Todohai.Domain.Task
  alias Todohai.Schema.Task, as: TaskSchema

  describe "add child task" do
    test "and succeed" do
      parent_task = %TaskSchema{text: "Joe", id: 3, done: false, parent: nil}
      {:ok, child_task} = Task.add_child_task(parent_task, "Child Task 2")
      assert child_task.parent == parent_task
    end

    test "and fail because of invalid parent" do
      parent_task = %TaskSchema{text: "John", id: -1, done: false, parent: nil}

      assert {:error,
              {:cannot_add_invalid_parent, "The parent task with id -1 doesn't exist anymore"}} =
               Task.add_child_task(parent_task, "Child Task 2")
    end

    test "and fail because of text too long" do
      child_text =
        "TextIsTooLongTextIsTooLongTextIsTooLongTextIsTooLongTextIsTooLongTextIsTooLong"

      parent_task = %TaskSchema{text: "Joe", id: 3, done: false, parent: nil}

      assert {
               :error,
               {
                 :cannot_add_child_task_with_invalid_text,
                 "The text is too long"
               }
             } = Task.add_child_task(parent_task, child_text)
    end

    test "and fail because of duplicate text" do
      existing_child_task =
        Todohai.Domain.Task.DummyImplementation.list_tasks()
        |> Enum.find(fn t -> not is_nil(t.parent) end)

      parent_task = existing_child_task.parent

      string_error = "Already existing child task with text '#{existing_child_task.text}'"

      assert {:error, {:duplicate_child_task, string_error}} ==
               Task.add_child_task(parent_task, existing_child_task.text)
    end
  end
end
