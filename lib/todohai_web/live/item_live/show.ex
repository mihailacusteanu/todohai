defmodule TodohaiWeb.ItemLive.Show do
  use TodohaiWeb, :live_view

  alias Todohai.Schema
  alias Todohai.Schema.Item

  @impl true
  def mount(_params, session, socket) do
    new_changeset = Schema.change_item(%Item{})

    socket =
      socket
      |> assign(:new_changeset, new_changeset)
      |> assign(:current_user, session["current_user"])

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Schema.get_item!(id)
    {:ok, _} = Schema.soft_delete_item(item)

    socket =
      socket
      |> assign(:children, Schema.list_children_for_parent(socket.assigns.item.id))
      |> assign(:item, Schema.get_item_with_parent!(socket.assigns.item.id))

    {:noreply, socket}
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
  def handle_params(%{"id" => id}, _, socket) do
    all_items =
      Schema.list_items(socket.assigns.current_user.id)
      |> Enum.reject(fn it -> "#{it.id}" == id end)
      |> Enum.map(fn item -> {item.name, item.id} end)

    all_items = [{"-", nil} | all_items]

    children = Schema.list_children_for_parent(id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:item, Schema.get_item_with_parent!(id))
      |> assign(:all_items, all_items)
      |> assign(:children, children)

    {:noreply, socket}
  end

  @impl true
  def handle_event("close", %{}, socket) do
    socket = push_patch(socket, to: Routes.item_show_path(socket, :show, socket.assigns.item))
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:edit), do: "Edit Item"
end
