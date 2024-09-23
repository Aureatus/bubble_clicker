defmodule BubbleClickerWeb.BubbleGridLive.Index do
  alias BubbleClicker.Accounts
  alias BubbleClicker.Bubbles
  use BubbleClickerWeb, :live_view

  @perk_strings ["click_size", "grid_size"]

  def mount(_params, _session, socket) do
    Bubbles.init_decimal_context()

    grid_size = 10
    grid_dimension = 800
    cell_size = Bubbles.calculate_cell_size(grid_dimension, grid_size)

    bubbles_grid =
      Bubbles.generate_bubbles_grid(grid_size, cell_size)

    auth_id = Accounts.generate_uuid()

    socket =
      socket
      |> assign(:grid_dimension, grid_dimension)
      |> assign(:cell_size, cell_size)
      |> assign(:bubbles, bubbles_grid)
      |> assign(:auth_id, auth_id)
      |> assign(:user_key, nil)
      |> assign(:score, nil)
      |> assign(:click_size, 1)
      |> assign(:grid_size, 1)
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

    cell_size = Bubbles.calculate_cell_size(socket.assigns.grid_dimension, user.grid_size)

    bubbles_grid =
      Bubbles.generate_bubbles_grid(user.grid_size, cell_size)

    {:noreply,
     socket
     |> assign(
       auth_id: auth_id,
       user_key: user.key,
       score: user.score,
       click_size: user.click_size,
       grid_size: user.grid_size,
       bubbles: bubbles_grid,
       cell_size: cell_size
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
        socket.assigns.click_size
      )

    {new_bubbles, updated_bubbles} =
      Bubbles.update_bubbles(socket.assigns.bubbles, cells_to_update)

    if Enum.all?(updated_bubbles, fn bubble ->
         Bubbles.cell_already_popped?(socket.assigns.bubbles, bubble.column, bubble.row)
       end) do
      {:noreply, socket}
    else
      score_increase =
        Enum.count(updated_bubbles, fn bubble ->
          not Bubbles.cell_already_popped?(socket.assigns.bubbles, bubble.column, bubble.row)
        end)

      score = Accounts.increase_score(socket.assigns.user_key, score_increase)

      {:noreply,
       socket
       |> assign(bubbles: new_bubbles, score: score)
       |> push_event("Canvas:update", %{
         data: updated_bubbles,
         cell_size: cell_size
       })}
    end
  end

  def handle_event("change_grid_size", %{"amount" => amount}, socket) do
    amount_integer = String.to_integer(amount)

    if socket.assigns.score - amount_integer < 0 do
      {:noreply, put_flash(socket, :error, "Don't have enough score!")}
    else
      {grid_size, score} =
        Accounts.increment_user_perk(
          socket.assigns.user_key,
          :grid_size,
          amount_integer,
          amount_integer
        )

      cell_size = Bubbles.calculate_cell_size(socket.assigns.grid_dimension, grid_size)
      new_bubbles = Bubbles.generate_bubbles_grid(grid_size, cell_size)

      {:noreply,
       socket
       |> assign(:grid_size, grid_size)
       |> assign(:cell_size, cell_size)
       |> assign(:bubbles, new_bubbles)
       |> assign(:score, score)
       |> push_event("Canvas:init", %{
         data: new_bubbles,
         cell_size: cell_size
       })}
    end
  end

  def handle_event("upgrade_perk", %{"perk_name" => perk_name}, socket) do
    if socket.assigns.score - 1 < 0 do
      {:noreply, put_flash(socket, :error, "Don't have enough score!")}
    else
      if perk_name in @perk_strings do
        perk_atom = String.to_atom(perk_name)
        {perk_level, score} = Accounts.increment_user_perk(socket.assigns.user_key, perk_atom)

        {:noreply, socket |> assign([{perk_atom, perk_level}, score: score])}
      else
        {:noreply, socket}
      end
    end
  end
end
