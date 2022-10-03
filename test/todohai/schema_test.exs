defmodule Todohai.SchemaTest do
  use Todohai.DataCase

  alias Todohai.Schema

  describe "items" do
    alias Todohai.Schema.Item

    import Todohai.SchemaFixtures

    @invalid_attrs %{is_done: nil, name: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Schema.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Schema.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{is_done: true, name: "some name"}

      assert {:ok, %Item{} = item} = Schema.create_item(valid_attrs)
      assert item.is_done == true
      assert item.name == "some name"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schema.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{is_done: false, name: "some updated name"}

      assert {:ok, %Item{} = item} = Schema.update_item(item, update_attrs)
      assert item.is_done == false
      assert item.name == "some updated name"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Schema.update_item(item, @invalid_attrs)
      assert item == Schema.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Schema.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Schema.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Schema.change_item(item)
    end
  end
end
