defmodule ListItemTableComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use TodohaiWeb, :live_component

  def render(assigns) do
    ~H"""

    <table class="table">
    <thead>
    <tr scope="col">
      <th scope="col">Name</th>
      <th scope="col">Parent</th>

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
          <%= if not is_nil(item.parent_id) do %>
            <%= live_redirect item.parent.name, to: Routes.item_show_path(@socket, :show, item.parent.id) %>
          <% else  %>
            -
          <% end  %>
        </td>
        <td>
          <span><%= live_redirect "Show", to: Routes.item_show_path(@socket, :show, item) %></span>
          <span><%= live_patch "Edit", to: Routes.item_index_path(@socket, :edit, item) %></span>
          <span><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: item.id, data: [confirm: "Are you sure?"] %></span>
        </td>
      </tr>
    <% end %>
    </tbody>
    </table>
    """
  end
end
