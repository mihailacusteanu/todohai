defmodule TodohaiWeb.ItemLive.FormComponent do
  use TodohaiWeb, :live_component

  alias Todohai.Schema

  @impl true
  def update(%{item: item} = assigns, socket) do
    changeset = Schema.change_item(item)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    socket = assign(socket, :item_to_update, socket.assigns.item)
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

  @impl true
  def handle_event("validate", params, socket) do
    changeset =
      socket.assigns.item
      |> Schema.change_item(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end
