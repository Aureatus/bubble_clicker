defmodule BubbleClicker.Bubbles do
  @moduledoc """
  Functions to help handle bubble grids, the base upon which this game runs.
  """

  def number_to_decimal(number) do
    if is_float(number) do
      Decimal.from_float(number)
    else
      Decimal.new(number)
    end
  end

  def calculate_cell_size(grid_dimension, grid_size) do
    Decimal.div(number_to_decimal(grid_dimension), number_to_decimal(grid_size))
  end

  def generate_bubbles_grid(grid_size, cell_size) do
    1..(grid_size * grid_size)
    |> Enum.chunk_every(grid_size)
    |> Enum.with_index()
    |> Enum.map(fn {column, column_index} ->
      Enum.map(column, fn val ->
        column_index_decimal = number_to_decimal(column_index)

        row_index =
          Decimal.sub(
            number_to_decimal(val - 1),
            Decimal.mult(column_index_decimal, number_to_decimal(grid_size))
          )

        x = Decimal.mult(column_index_decimal, cell_size)
        y = Decimal.mult(row_index, cell_size)

        %{id: val, value: false, x: x, y: y}
      end)
    end)
    |> List.flatten()
  end

  def get_index_from_coordinate(x_coordinate, cell_size) do
    decimal_coordinate = number_to_decimal(x_coordinate)
    whole_divisions = Decimal.div(decimal_coordinate, cell_size) |> Decimal.round(0, :floor)
    calculated_coordinate = Decimal.mult(whole_divisions, cell_size)

    calculated_coordinate
  end

  def update_bubbles_grid(bubbles, column_index, row_index) do
    updated_bubbles =
      Enum.map(bubbles, fn %{id: id, x: x, y: y, value: value} = bubble ->
        if x === column_index and y === row_index and value !== true do
          %{x: x, y: y, id: id, value: true}
        else
          bubble
        end
      end)

    updated_bubble =
      Enum.find(updated_bubbles, fn %{x: x, y: y} -> x === column_index and y === row_index end)

    {updated_bubbles, updated_bubble}
  end

  def cell_already_popped?(bubbles, column_index, row_index) do
    bubble =
      Enum.find(bubbles, fn bubble ->
        bubble.x === column_index and bubble.y === row_index
      end)

    bubble.value
  end
end
