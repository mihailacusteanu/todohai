defmodule ListItemTableComponent do
  @moduledoc """
  A live component that renders a table of items.
  """
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use TodohaiWeb, :live_component

  def render(assigns) do
    ~H"""

    <table class="table">
    <thead>
    <tr scope="col">
      <th scope="col">Name</th>

      <th scope="col"></th>
    </tr>
    </thead>
    <tbody id="items">
    <%= for item <- @items do %>
      <tr id={"item-#{item.id}"} scope="row">
        <td>
        <%= if item.is_done do %>
          <s><%= item.name %></s>
        <% else %>
          <%= item.name %>
        <% end %>
        </td>
        <td>
          <span><%= live_redirect "Show", to: Routes.item_show_path(@socket, :show, item), class: "btn btn-primary" %></span>
          <span><%= live_patch "Edit", to: Routes.item_index_path(@socket, :edit, item), class: "btn btn-primary" %></span>
          <span><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: item.id, data: [confirm: "Are you sure?"], class: "btn btn-danger"  %></span>
        </td>
      </tr>
    <% end %>
    </tbody>
    </table>
    """
  end
end
