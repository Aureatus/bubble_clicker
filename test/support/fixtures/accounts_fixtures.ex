defmodule BubbleClicker.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BubbleClicker.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        key: Ecto.UUID.generate(),
        score: 42
      })
      |> BubbleClicker.Accounts.create_user()

    user
  end
end
