defmodule BubbleClickerWeb.BubbleGridLive.Index do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    grid_size = 100

    bubbles = generate_bubbles(grid_size)
    bubbles_grid = generate_grid_from_bubbles_v2(bubbles)

    socket =
      assign(socket, :bubbles, bubbles)
      |> assign(:grid_size, grid_size)
      |> stream(:bubbles_grid, bubbles_grid)

    {:ok, socket}
  end

  def handle_event("pop", %{"column" => column, "row" => row}, socket) do
    row_number = String.to_integer(row)
    column_number = String.to_integer(column)

    updated_bubbles = pop_bubble(socket.assigns.bubbles, row_number, column_number)
    bubbles_grid = generate_grid_from_bubbles_v2(updated_bubbles)

    edited_cell =
      bubbles_grid
      |> Enum.find(fn %{column_index: column_index, row_index: row_index} = _item ->
        column_index === column_number && row_index === row_number
      end)

    socket =
      assign(socket, :bubbles, updated_bubbles)
      |> stream_insert(:bubbles_grid, edited_cell, at: edited_cell.id)

    {:noreply, socket}
  end

  defp generate_bubbles(size) do
    List.duplicate(false, size) |> Enum.map(fn _x -> List.duplicate(false, size) end)
  end

  defp pop_bubble(bubbles, row, column) do
    bubbles |> List.update_at(row, &List.update_at(&1, column, fn _ -> true end))
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
