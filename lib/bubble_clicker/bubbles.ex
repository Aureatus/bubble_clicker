defmodule BubbleClicker.Bubbles do
  @moduledoc """
  Functions to help handle bubble grids, the base upon which this game runs.
  """

  def calculate_cell_size(grid_dimension, grid_size) do
    grid_dimension / grid_size
  end

  def generate_bubbles_grid(grid_size, cell_size) do
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

  def get_index_from_coordinate(x_coordinate, cell_size) do
    Kernel.trunc(x_coordinate / cell_size) * cell_size
  end

  def update_bubbles_grid(bubbles, column_index, row_index) do
    updated_bubbles =
      Enum.map(bubbles, fn %{id: id, x: x, y: y, value: value} = bubble ->
        if x == column_index and y == row_index and value !== true do
          %{x: x, y: y, id: id, value: true}
        else
          bubble
        end
      end)

    updated_bubble =
      Enum.find(updated_bubbles, fn %{x: x, y: y} -> x == column_index and y == row_index end)

    {updated_bubbles, updated_bubble}
  end
end
