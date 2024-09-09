defmodule BubbleClickerWeb.BubbleGridLive.Index do
  use BubbleClickerWeb, :live_view

  def mount(_params, _session, socket) do
    grid_size = 20
    grid_dimension = 800
    bubbles = generate_bubbles(grid_size)

    socket =
      assign(socket, :bubbles, bubbles)
      |> assign(:grid_size, grid_size)
      |> assign(:grid_dimension, grid_dimension)

    {:ok, socket}
  end

  def handle_event("Canvas:init", _params, socket) do
    data = generate_grid_from_bubbles_v2(socket.assigns.bubbles)

    {:reply,
     %{
       data: data,
       cell_size: socket.assigns.grid_dimension / socket.assigns.grid_size
     }, socket}
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

    {:noreply,
     push_event(socket, "Canvas:update", %{
       data: generated_bubble,
       cell_size: socket.assigns.grid_dimension / socket.assigns.grid_size
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
