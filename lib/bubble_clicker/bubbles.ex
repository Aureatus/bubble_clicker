defmodule BubbleClicker.Bubbles do
  @moduledoc """
  Functions to help handle bubble grids, the base upon which this game runs.
  """
  def init_decimal_context do
    Decimal.Context.update(fn update -> %Decimal.Context{update | precision: 10} end)
  end

  def number_to_decimal(number) do
    if is_float(number) do
      Float.to_string(number) |> Decimal.new()
    else
      Decimal.new(number)
    end
  end

  def calculate_cell_size(grid_dimension, grid_size) do
    Decimal.div(number_to_decimal(grid_dimension), number_to_decimal(grid_size))
  end

  def generate_bubbles_grid(grid_size, cell_size) do
    for column <- 0..(grid_size - 1), row <- 0..(grid_size - 1) do
      %{
        id: column + grid_size * row,
        x: Decimal.mult(number_to_decimal(column), cell_size),
        y: Decimal.mult(number_to_decimal(row), cell_size),
        column: column,
        row: row,
        value: false
      }
    end
  end

  def get_index_from_coordinate(x_coordinate, cell_size) do
    decimal_coordinate = number_to_decimal(x_coordinate)
    whole_divisions = Decimal.div(decimal_coordinate, cell_size) |> Decimal.round(0, :floor)
    calculated_coordinate = Decimal.mult(whole_divisions, cell_size)

    calculated_coordinate
  end

  def get_bubbles_to_click(column, row, grid_size, click_size) do
    column_indexes = (column - click_size + 1)..(column + click_size - 1)
    row_indexes = (row - click_size + 1)..(row + click_size - 1)

    cells_to_click =
      for column <- column_indexes,
          column >= 0 and column < grid_size,
          row <- row_indexes,
          row >= 0 and row < grid_size do
        {column, row}
      end

    cells_to_click
  end

  def cells_contain_bubble(bubble, cells) do
    Enum.any?(cells, fn {cell_column, cell_row} ->
      cell_column === bubble.column and cell_row === bubble.row
    end)
  end

  def update_bubbles(bubbles, cells) do
    updated_bubbles =
      Enum.map(bubbles, fn bubble ->
        if cells_contain_bubble(bubble, cells) do
          %{bubble | value: true}
        else
          bubble
        end
      end)

    bubbles_to_update =
      Enum.map(cells, fn {cell_column, cell_row} ->
        Enum.find(updated_bubbles, fn bubble ->
          bubble.column === cell_column and bubble.row === cell_row
        end)
      end)

    {updated_bubbles, bubbles_to_update}
  end

  def get_single_bubble(bubbles, column_index, row_index) do
    Enum.find(bubbles, fn %{x: x, y: y} ->
      Decimal.eq?(x, column_index) and Decimal.eq?(y, row_index)
    end)
  end

  def cell_already_popped?(bubbles, column, row) do
    bubble =
      Enum.find(bubbles, fn bubble ->
        bubble.column === column and bubble.row === row
      end)

    bubble.value
  end
end
