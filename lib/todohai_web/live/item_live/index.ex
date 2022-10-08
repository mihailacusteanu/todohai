defmodule TodohaiWeb.ItemLive.Index do
  use TodohaiWeb, :live_view

  alias Todohai.Schema
  alias Todohai.Schema.Item

  @impl true
  def mount(_params, session, socket) do
    new_changeset = Schema.change_item(%Item{})

    socket =
      socket
      |> assign(:items, list_items_with_no_parent(session["current_user"].id))
      |> assign(:new_changeset, new_changeset)
      |> assign(:current_user, session["current_user"])

    {:ok, socket}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    id = item_params["input_id"]
    item = Schema.get_item!(id)
    socket = assign(socket, :item_to_update, item)
    save_item(socket, :edit, item_params)
  end

  defp save_item(socket, :edit, item_params) do
    case Schema.update_item(socket.assigns.item_to_update, item_params) do
      {:ok, _item} ->
        redirect_route =
          case socket.assigns.item_to_update.parent_id do
            nil -> Routes.item_index_path(socket, :index)
            _ -> Routes.item_show_path(socket, :show, socket.assigns.item_to_update.parent_id)
          end

        {:noreply,
         socket
         |> push_redirect(to: redirect_route)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_item(socket, :new, item_params) do
    case Schema.create_item(item_params) do
      {:ok, _item} ->
        redirect_route =
          case item_params["parent_id"] do
            nil -> Routes.item_index_path(socket, :index)
            _ -> Routes.item_show_path(socket, :show, item_params["parent_id"])
          end

        {:noreply,
         socket
         #  |> put_flash(:info, "Item created successfully")
         |> push_redirect(to: redirect_route)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    all_items =
      Schema.list_items(socket.assigns.current_user.id)
      |> Enum.reject(fn it -> "#{it.id}" == id end)
      |> Enum.map(fn item -> {item.name, item.id} end)

    all_items = [{"-", nil} | all_items]

    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Schema.get_item!(id))
    |> assign(:all_items, all_items)
  end

  defp apply_action(socket, :new, _params) do
    all_items = Schema.list_items(socket.assigns.current_user.id) |> Enum.map(fn item -> {item.name, item.id} end)
    all_items = [{"-", nil} | all_items]

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

    {:noreply, assign(socket, :items, list_items_with_no_parent(socket.assigns.current_user.id))}
  end

  def handle_event("close", %{}, socket) do
    socket = push_patch(socket, to: Routes.item_index_path(socket, :index))
    {:noreply, socket}
  end

  defp list_items_with_no_parent(user_id) do
    Schema.list_items_with_no_parent(user_id)
  end
end
