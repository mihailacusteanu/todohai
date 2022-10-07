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

  # handle_event("validate", %{"item" => %{"name" => "d"}},

  @impl true
  def handle_event("validate", params, socket) do
    IO.inspect("=== validate ===")
    IO.inspect(params)
    item_params = params
    changeset =
      socket.assigns.item
      |> Schema.change_item(item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end
