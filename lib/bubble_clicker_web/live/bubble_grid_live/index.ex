defmodule BubbleClickerWeb.BubbleGridLive.Index do
  use BubbleClickerWeb, :live_view

  def mount(_params, _session, socket) do
    grid_size = 20

    bubbles = generate_bubbles(grid_size)
    bubbles_grid = generate_grid_from_bubbles_v2(bubbles)

    socket =
      assign(socket, :bubbles, bubbles)
      |> assign(:grid_size, grid_size)
      |> stream(:bubbles_grid, bubbles_grid)

    {:ok, socket}
  end

  def handle_event("Canvas:init", _params, socket) do
    data = generate_grid_from_bubbles_v2(socket.assigns.bubbles)
    {:reply, %{data: data, grid_size: socket.assigns.grid_size}, socket}
  end

  def handle_event("pop", %{"id" => id, "column" => column, "row" => row}, socket) do
    row_number = String.to_integer(row)
    column_number = String.to_integer(column)

    generated_bubble = %{
      id: id,
      value: true,
      column_index: column_number,
      row_index: row_number
    }

    socket =
      stream_insert(socket, :bubbles_grid, generated_bubble, at: generated_bubble.id)

    {:noreply,
     push_event(socket, "Canvas:update", %{
       data: generated_bubble,
       grid_size: socket.assigns.grid_size
     })}
  end

  def handle_event(
        "canvas_click",
        %{"offsetX" => offsetX, "offsetY" => offsetY, "width" => width},
        socket
      ) do
    cell_size = width / socket.assigns.grid_size

    column_index_target = Kernel.trunc(offsetX / cell_size)
    row_index_target = Kernel.trunc(offsetY / cell_size)

    generated_bubble = %{
      id: column_index_target + row_index_target * socket.assigns.grid_size,
      value: true,
      column_index: column_index_target,
      row_index: row_index_target
    }

    socket =
      stream_insert(socket, :bubbles_grid, generated_bubble, at: generated_bubble.id)

    {:noreply,
     push_event(socket, "Canvas:update", %{
       data: generated_bubble,
       grid_size: socket.assigns.grid_size
     })}
  end

  defp generate_bubbles(size) do
    List.duplicate(false, size) |> Enum.map(fn _x -> List.duplicate(false, size) end)
  end

  defp generate_grid_from_bubbles_v2(bubbles) do
    bubbles
    |> Enum.with_index()
    |> Enum.map(fn {value, index} ->
      Enum.map(Enum.with_index(value), fn {val2, index2} ->
        {val2, {index2, index}}
      end)
    end)
    |> List.flatten()
    |> Enum.map(fn {val, {col_index, row_index}} ->
      %{
        value: val,
        column_index: col_index,
        row_index: row_index
      }
    end)
    |> Enum.with_index()
    |> Enum.map(fn {val, index} -> Map.put(val, :id, index) end)
  end
end
