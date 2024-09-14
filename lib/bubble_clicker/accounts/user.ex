defmodule BubbleClicker.Accounts.User do
  @moduledoc """
  Schema for users in bubble clicker
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :key, :string
    field :score, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:key, :score])
    |> validate_required([:key, :score])
    |> validate_number(:score, greater_than_or_equal_to: 0)
  end
end
