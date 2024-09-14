defmodule BubbleClicker.Accounts.User do
  @moduledoc """
  Schema for users in bubble clicker
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :key, :string
    field :score, :integer, default: 0
    field :click_size, :integer, default: 1

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:key, :score, :click_size])
    |> validate_required([:key, :score, :click_size])
    |> validate_number(:score, greater_than_or_equal_to: 0)
    |> validate_number(:click_size, greater_than_or_equal_to: 1)
  end
end
