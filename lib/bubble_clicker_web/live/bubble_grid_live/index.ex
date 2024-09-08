defmodule BubbleClickerWeb.BubbleGridLive.Index do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    grid_size = 200

    bubbles = generate_bubbles(grid_size)
    bubbles_grid = generate_grid_from_bubbles_v2(bubbles)

    socket =
      assign(socket, :bubbles, bubbles)
      |> assign(:grid_size, grid_size)
      |> stream(:bubbles_grid, bubbles_grid)

    {:ok, socket}
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

    {:noreply, socket}
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
