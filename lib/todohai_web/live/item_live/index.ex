defmodule TodohaiWeb.ItemLive.Index do
  use TodohaiWeb, :live_view

  alias Todohai.Schema
  alias Todohai.Schema.Item

  @impl true
  def mount(_params, _session, socket) do
    new_changeset = Schema.change_item(%Item{})
    socket =
      socket
      |> assign(:items, list_items_with_no_parent())
      |> assign(:new_changeset, new_changeset)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    all_items =
      Schema.list_items()
      |> Enum.reject(fn it -> "#{it.id}" == id end)
      |> Enum.map(fn item -> {item.name, item.id} end)

    all_items = [{:none, nil} | all_items]

    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Schema.get_item!(id))
    |> assign(:all_items, all_items)
  end

  defp apply_action(socket, :new, _params) do
    all_items = Schema.list_items() |> Enum.map(fn item -> {item.name, item.id} end)
    all_items = [{:none, nil} | all_items]

    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{})
    |> assign(:all_items, all_items)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Schema.get_item!(id)
    {:ok, _} = Schema.delete_item(item)

    {:noreply, assign(socket, :items, list_items_with_no_parent())}
  end

  def handle_event("close", %{}, socket) do
    socket = push_patch(socket, to: Routes.item_index_path(socket, :index))
    {:noreply, socket}
  end

  defp list_items_with_no_parent do
    Schema.list_items_with_no_parent()
  end
end
