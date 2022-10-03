defmodule Todohai.ItemTest do
  use Todohai.DataCase

  alias Todohai.Schema
  import Todohai.SchemaFixtures

  describe "list all items for parent" do
    setup do
      %{parent_item: item_fixture()}
    end

    test "and get empty list", %{parent_item: parent_item} do
      assert Schema.list_children_for_parent(parent_item.id) == []
      assert Schema.list_children_for_parent(nil) == []
    end

    test "and get list with one item", %{parent_item: parent_item} do
      child_item1 = item_fixture(%{parent_id: parent_item.id})
      child_item2 = item_fixture(%{parent_id: parent_item.id})
      assert Schema.list_children_for_parent(parent_item.id) == [child_item1, child_item2]
      Schema.delete_item(child_item1)
      Schema.delete_item(child_item2)
    end
  end

  describe "list items for parent based on is_done field" do
    setup do
      parent_item = item_fixture()

      child_item_done =
        item_fixture(%{name: "item done", parent_id: parent_item.id, is_done: true})

      child_item_not_done =
        item_fixture(%{name: "item NOT done", parent_id: parent_item.id, is_done: false})

      %{
        parent_item: parent_item,
        child_item_done: child_item_done,
        child_item_not_done: child_item_not_done
      }
    end

    test "and get list with one item", %{
      parent_item: parent_item,
      child_item_done: child_item_done,
      child_item_not_done: child_item_not_done
    } do
      assert Schema.list_done_children_for_parent(parent_item.id) == [child_item_done]
      assert Schema.list_not_done_children_for_parent(parent_item.id) == [child_item_not_done]
      Schema.delete_item(child_item_done)
      Schema.delete_item(child_item_not_done)
    end
  end
end
