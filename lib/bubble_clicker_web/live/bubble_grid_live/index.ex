defmodule BubbleClickerWeb.BubbleGridLive.Index do
  use BubbleClickerWeb, :live_view

  def mount(_params, _session, socket) do
    grid_size = 20
    grid_dimension = 800
    cell_size = grid_dimension / grid_size
    bubbles_grid = generate_bubbles_grid(grid_size, cell_size)

    socket =
      assign(socket, :bubbles, bubbles_grid)
      |> assign(:grid_size, grid_size)
      |> assign(:grid_dimension, grid_dimension)
      |> assign(:cell_size, cell_size)

    {:ok,
     socket
     |> push_event("Canvas:init", %{
       data: bubbles_grid,
       cell_size: cell_size
     })}
  end

  def handle_event(
        "canvas_click",
        %{"offsetX" => offsetX, "offsetY" => offsetY},
        socket
      ) do
    cell_size = socket.assigns.cell_size
    column_index_target = Kernel.trunc(offsetX / cell_size) * cell_size
    row_index_target = Kernel.trunc(offsetY / cell_size) * cell_size

    generated_bubble = %{
      value: true,
      x: column_index_target,
      y: row_index_target
    }

    {:noreply,
     push_event(socket, "Canvas:update", %{
       data: generated_bubble,
       cell_size: cell_size
     })}
  end

  defp generate_bubbles_grid(grid_size, cell_size) do
    1..(grid_size * grid_size)
    |> Enum.chunk_every(grid_size)
    |> Enum.with_index()
    |> Enum.map(fn {column, column_index} ->
      Enum.map(column, fn val ->
        row_index = val - 1 - column_index * grid_size

        x = column_index * cell_size
        y = row_index * cell_size
        %{id: val, value: false, x: x, y: y}
      end)
    end)
    |> List.flatten()
  end
end
