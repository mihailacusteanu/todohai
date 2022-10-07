defmodule ListItemTableComponent do
  @moduledoc """
  A live component that renders a table of items.
  """
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use TodohaiWeb, :live_component

  alias Todohai.Schema
  alias Todohai.Schema.Item

  def handle_event("validate", %{"item" => item_params}, socket) do
    new_changeset =
      %Item{}
      |> Schema.change_item(item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :new_changeset, new_changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    item_params = Map.merge(item_params, %{"parent_id" => socket.assigns.parent_id})
    save_item(socket, :new, item_params)
  end

  # defp save_item(socket, :edit, item_params) do
  #   case Schema.update_item(socket.assigns.item, item_params) do
  #     {:ok, _item} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Item updated successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

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

  def render(assigns) do
    ~H"""
    <div id="list_items">
      <%= for item <- @items do %>
        <li class="list-group-item" style="border-radius: 0px;" id={"item-#{item.id}"}>
          <div class="form-check content" >
          <.form
            let={f}
            for={Item.changeset(item, %{})}
            id="item-form-checkbox"
            phx-change="save">
            <%= hidden_input f, :input_id, value: item.id %>
            <%= checkbox f, :is_done, class: "form-check-input checkbox" %>
            </.form>

            <label class="form-check-label" for="formCheck-1">
              <a href={Routes.item_show_path(@socket, :show, item)} data-phx-link-state="push" data-phx-link="redirect">
                <span style="color: rgb(255, 255, 255);">
                  <%= if item.is_done do %>
                    <s><%= item.name %></s>
                  <% else %>
                    <%= item.name %>
                  <% end %>
                  <% x = if item.no_of_children != 0 do round(item.no_of_done_children / item.no_of_children * 100) else 0 end %>
                </span>
              </a>
            </label>
          </div>
          <div class="progress">
              <div class="progress-bar" role="progressbar" style={"width: #{x}%"} aria-valuemin="0" aria-valuemax="100"></div>
            </div>
        </li>
      <% end %>


      <.form
    let={f}
    for={@new_changeset}
    id="item-form"
    phx-target={@myself}
    phx-change="validate"
    phx-submit="save"
    class="d-flex d-sm-flex d-lg-flex flex-row justify-content-center align-items-center justify-content-sm-center justify-content-lg-center align-items-lg-center"
    >
    <div class="mb-3">
      <%= text_input f, :name, class: "form-control justify-content-around", id: "seach-input",  placeholder: "todo 1.." %>
    </div>
    <div class="mb-3">
      <%= submit "Save", phx_disable_with: "Saving...", disabled: !@new_changeset.valid?,  class: "btn btn-primary", id: "save-item" %>
    </div>
    </.form>
    </div>


    """
  end
end
