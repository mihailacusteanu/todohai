defmodule TodohaiWeb.ItemLiveTest do
  use TodohaiWeb.ConnCase

  import Phoenix.LiveViewTest
  import Todohai.SchemaFixtures

  alias Todohai.Schema

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_item(%{user: user}) do
    item = item_fixture(user_id: user.id)
    %{item: item}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, item: item, user: user} do
      {:ok, index_live, html} = live(conn, Routes.item_index_path(conn, :index))
      assert html =~ "Listing Items"
      assert html =~ item.name
    end

    test "saves new item on index page", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      {:ok, _, html} =
        index_live
        |> form("#item-form-add-item", item: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_index_path(conn, :index))

      assert html =~ "some name"
    end

    # test "updates item in listing", %{conn: conn, item: item} do
    #   {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

    #   assert index_live |> element("#item-#{item.id} a", "Edit") |> render_click() =~
    #            "Edit Item"

    #   assert_patch(index_live, Routes.item_index_path(conn, :edit, item))

    #   assert index_live
    #          |> form("#item-form", item: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   {:ok, _, html} =
    #     index_live
    #     |> form("#item-form", item: @update_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, Routes.item_index_path(conn, :index))

    #   assert html =~ "Item updated successfully"
    #   assert html =~ "some updated name"
    # end

    # test "deletes item in listing", %{conn: conn, item: item} do
    #   {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

    #   assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
    #   refute has_element?(index_live, "#item-#{item.id}")
    # end
  end

  describe "Show" do
    setup [:create_item]

    test "displays item", %{conn: conn, item: item} do
      {:ok, _show_live, html} = live(conn, Routes.item_show_path(conn, :show, item))

      assert html =~ "Show Item"
      assert html =~ item.name
    end

    test "saves new item on show page", %{conn: conn, item: parent_item} do
      {:ok, index_live, _html} = live(conn, Routes.item_show_path(conn, :show, parent_item))

      {:ok, _, html} =
        index_live
        |> form("#item-form-add-item", item: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_show_path(conn, :show, parent_item))

      assert html =~ "some name"
    end

    # test "updates item within modal", %{conn: conn, item: item} do
    #   {:ok, show_live, _html} = live(conn, Routes.item_show_path(conn, :show, item))

    #   assert show_live |> element("a", "Edit") |> render_click() =~
    #            "Edit Item"

    #   assert_patch(show_live, Routes.item_show_path(conn, :edit, item))

    #   assert show_live
    #          |> form("#item-form", item: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   {:ok, _, html} =
    #     show_live
    #     |> form("#item-form", item: @update_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, Routes.item_show_path(conn, :show, item))

    #   assert html =~ "Item updated successfully"
    #   assert html =~ "some updated name"
    # end
  end

  describe "update child name on show page" do
    test "and parent's children progress stay the same", %{conn: conn, user: user} do
      parent = item_fixture(%{user_id: user.id})
      child1 = item_fixture(%{parent_id: parent.id, is_done: true, user_id: user.id})
      child2 = item_fixture(%{parent_id: parent.id, is_done: false, user_id: user.id})
      assert Schema.get_item!(parent.id).no_of_children == 2
      assert Schema.get_item!(parent.id).no_of_done_children == 1

      {:ok, show_parent_live, html} = live(conn, Routes.item_show_path(conn, :show, parent.id))
      assert html =~ "Children Progress:</strong>\n50.0 %"

      assert show_parent_live |> element("a#edit-item-#{child1.id}") |> render_click() =~
               "Edit Item"

      {:ok, _, html} =
        show_parent_live
        |> form("#item-form", item: %{name: "new child1 item name"})
        |> render_submit()
        |> follow_redirect(conn, Routes.item_show_path(conn, :show, parent.id))

      assert html =~ "new child1 item name"
      assert html =~ "Children Progress:</strong>\n50.0 %"

      {:ok, show_parent_live, html} = live(conn, Routes.item_show_path(conn, :show, parent.id))

      assert show_parent_live |> element("a#edit-item-#{child2.id}") |> render_click() =~
               "Edit Item"

      {:ok, _, html} =
        show_parent_live
        |> form("#item-form", item: %{name: "new child2 item name"})
        |> render_submit()
        |> follow_redirect(conn, Routes.item_show_path(conn, :show, parent.id))

      assert html =~ "new child2 item name"
      assert html =~ "Children Progress:</strong>\n50.0 %"
      {:ok, show_parent_live, html} = live(conn, Routes.item_show_path(conn, :show, parent.id))
      assert html =~ "Children Progress:</strong>\n50.0 %"
    end
  end

  describe "delete child on parent's show page" do
    test "and parent's children progress stay the same", %{conn: conn, user: user} do
      parent = item_fixture(%{user_id: user.id})
      child1 = item_fixture(%{parent_id: parent.id, is_done: true, user_id: user.id})
      child2 = item_fixture(%{parent_id: parent.id, is_done: false, user_id: user.id})
      assert Schema.get_item!(parent.id).no_of_children == 2
      assert Schema.get_item!(parent.id).no_of_done_children == 1

      {:ok, show_parent_live, html} = live(conn, Routes.item_show_path(conn, :show, parent.id))
      assert html =~ "Children Progress:</strong>\n50.0 %"

      assert show_parent_live |> element("svg#delete-item-#{child1.id}") |> render_click()

      assert_raise Ecto.NoResultsError, fn ->
        Schema.get_item!(child1.id)
      end

      refute has_element?(show_parent_live, "svg#delete-item-#{child1.id}")

      assert html =~ "Children Progress:</strong>\n50.0 %"
    end
  end
end
