defmodule TodohaiWeb.ItemLive.Show do
  use TodohaiWeb, :live_view

  alias Todohai.Schema

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    all_items =
      Schema.list_items()
      |> Enum.reject(fn it -> "#{it.id}" == id end)
      |> Enum.map(fn item -> {item.name, item.id} end)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:item, Schema.get_item!(id))
      |> assign(:all_items, all_items)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:edit), do: "Edit Item"
end
