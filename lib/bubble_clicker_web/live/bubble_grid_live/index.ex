defmodule BubbleClickerWeb.BubbleGridLive.Index do
  alias BubbleClicker.Accounts
  alias BubbleClicker.Bubbles
  use BubbleClickerWeb, :live_view

  def mount(_params, _session, socket) do
    grid_size = 20
    grid_dimension = 800
    cell_size = Bubbles.calculate_cell_size(grid_dimension, grid_size)

    bubbles_grid =
      Bubbles.generate_bubbles_grid(grid_size, cell_size)

    auth_id = Accounts.generate_uuid()

    socket =
      socket
      |> assign(:grid_size, grid_size)
      |> assign(:grid_dimension, grid_dimension)
      |> assign(:cell_size, cell_size)
      |> assign(:bubbles, bubbles_grid)
      |> assign(:auth_id, auth_id)
      |> assign(:user_key, nil)
      |> assign(:user_score, nil)
      |> push_event("Canvas:init", %{
        data: bubbles_grid,
        cell_size: cell_size
      })

    {:ok, socket}
  end

  def handle_event("Auth:receive", %{"auth_id" => auth_id}, socket) do
    user =
      if auth_id === socket.assigns.auth_id do
        {:ok, user} = Accounts.create_user(%{key: socket.assigns.auth_id, score: 0})
        user
      else
        Accounts.get_user!(auth_id)
      end

    {:noreply, socket |> assign(auth_id: auth_id, user_key: user.key, user_score: user.score)}
  end

  def handle_event(
        "canvas_click",
        %{"offsetX" => offsetX, "offsetY" => offsetY},
        socket
      ) do
    cell_size = socket.assigns.cell_size
    column_index_target = Bubbles.get_index_from_coordinate(offsetX, cell_size)
    row_index_target = Bubbles.get_index_from_coordinate(offsetY, cell_size)

    already_popped? =
      Enum.find(socket.assigns.bubbles, fn bubble ->
        bubble.x == column_index_target and bubble.y == row_index_target
      end).value

    {updated_bubbles, updated_bubble} =
      Bubbles.update_bubbles_grid(
        socket.assigns.bubbles,
        column_index_target,
        row_index_target
      )

    if already_popped? do
      {:noreply, socket}
    else
      {_, [user]} = Accounts.increase_user_score(socket.assigns.user_key)

      {:noreply,
       socket
       |> assign(bubbles: updated_bubbles, user_score: user.score)
       |> push_event("Canvas:update", %{
         data: updated_bubble,
         cell_size: cell_size
       })}
    end
  end

  def handle_event("change_grid_size", %{"amount" => amount}, socket) do
    amount_integer = String.to_integer(amount)

    new_grid_size = socket.assigns.grid_size + amount_integer
    new_cell_size = Bubbles.calculate_cell_size(socket.assigns.grid_dimension, new_grid_size)
    new_bubbles = Bubbles.generate_bubbles_grid(new_grid_size, new_cell_size)

    {:noreply,
     socket
     |> assign(:grid_size, new_grid_size)
     |> assign(:cell_size, new_cell_size)
     |> assign(:bubbles, new_bubbles)
     |> push_event("Canvas:init", %{
       data: new_bubbles,
       cell_size: new_cell_size
     })}
  end
end
