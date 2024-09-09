defmodule BubbleClickerWeb.BubbleGridLive.Index do
  use BubbleClickerWeb, :live_view

  def mount(_params, _session, socket) do
    grid_size = 20
    grid_dimension = 800
    cell_size = grid_dimension / grid_size
    bubbles = generate_bubbles(grid_size)

    socket =
      assign(socket, :bubbles, bubbles)
      |> assign(:grid_size, grid_size)
      |> assign(:grid_dimension, grid_dimension)
      |> assign(:cell_size, cell_size)

    {:ok, socket}
  end

  def handle_event("Canvas:init", _params, socket) do
    data = generate_grid_from_bubbles(socket.assigns.bubbles, socket.assigns.cell_size)

    {:reply,
     %{
       data: data,
       cell_size: socket.assigns.cell_size
     }, socket}
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

  defp generate_bubbles(size) do
    List.duplicate(false, size) |> Enum.map(fn _x -> List.duplicate(false, size) end)
  end

  defp generate_grid_from_bubbles(bubbles, cell_size) do
    bubbles
    |> Enum.with_index()
    |> Enum.map(fn {cells, column_index} ->
      Enum.map(cells, fn cell -> {cell, column_index} end)
    end)
    |> Enum.map(fn cell ->
      Enum.with_index(cell) |> Enum.map(fn {cell, row_index} -> Tuple.append(cell, row_index) end)
    end)
    |> List.flatten()
    |> Enum.map(fn {val, column_index, row_index} ->
      %{value: val, x: column_index * cell_size, y: row_index * cell_size}
    end)
  end
end
