defmodule BubbleClickerWeb.BubbleGridLive.Index do
  alias BubbleClicker.Accounts
  alias BubbleClicker.Bubbles
  use BubbleClickerWeb, :live_view

  @perk_strings ["click_size"]

  def mount(_params, _session, socket) do
    Bubbles.init_decimal_context()

    grid_size = 30
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
      |> assign(:user_click_size, 1)
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

    {:noreply,
     socket
     |> assign(
       auth_id: auth_id,
       user_key: user.key,
       user_score: user.score,
       user_click_size: user.click_size
     )}
  end

  def handle_event(
        "canvas_click",
        %{"offsetX" => offsetX, "offsetY" => offsetY},
        socket
      ) do
    Bubbles.init_decimal_context()

    cell_size = socket.assigns.cell_size
    column_index_target = Bubbles.get_index_from_coordinate(offsetX, cell_size)
    row_index_target = Bubbles.get_index_from_coordinate(offsetY, cell_size)

    clicked_bubble =
      Bubbles.get_single_bubble(socket.assigns.bubbles, column_index_target, row_index_target)

    cells_to_update =
      Bubbles.get_bubbles_to_click(
        clicked_bubble.column,
        clicked_bubble.row,
        socket.assigns.grid_size,
        socket.assigns.user_click_size
      )

    {new_bubbles, updated_bubbles} =
      Bubbles.update_bubbles(socket.assigns.bubbles, cells_to_update)

    if Bubbles.cell_already_popped?(socket.assigns.bubbles, column_index_target, row_index_target) do
      {:noreply, socket}
    else
      score = Accounts.increase_user_score(socket.assigns.user_key)

      {:noreply,
       socket
       |> assign(bubbles: new_bubbles, user_score: score)
       |> push_event("Canvas:update", %{
         data: updated_bubbles,
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

  def handle_event("upgrade_perk", %{"perk_name" => perk_name}, socket) do
    if perk_name in @perk_strings do
      perk_atom = String.to_atom(perk_name)
      perk_level = Accounts.increment_user_perk(socket.assigns.user_key, perk_atom)
      {:noreply, socket |> assign(perk_atom, perk_level)}
    else
      {:noreply, socket}
    end
  end
end
