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
        <li class="list-group-item " style="border-radius: 0px;" id={"item-#{item.id}"}>
          <div class="form-check content d-flex flex-row justify-content-between" >
            <div>
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
            <div>
              <.link patch={ Routes.item_show_path(@socket, :edit, item)} class="text-white">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-pencil" viewBox="0 0 16 16">
                  <path d="M12.146.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1 0 .708l-10 10a.5.5 0 0 1-.168.11l-5 2a.5.5 0 0 1-.65-.65l2-5a.5.5 0 0 1 .11-.168l10-10zM11.207 2.5 13.5 4.793 14.793 3.5 12.5 1.207 11.207 2.5zm1.586 3L10.5 3.207 4 9.707V10h.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.5h.293l6.5-6.5zm-9.761 5.175-.106.106-1.528 3.821 3.821-1.528.106-.106A.5.5 0 0 1 5 12.5V12h-.5a.5.5 0 0 1-.5-.5V11h-.5a.5.5 0 0 1-.468-.325z"/>
                </svg>
              </.link>
              <svg phx-click="delete" data-confirm="Are you sure?" phx-value-id={item.id} xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-trash" viewBox="0 0 16 16" phx-click="">
                <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
                <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
              </svg>
            </div>
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
