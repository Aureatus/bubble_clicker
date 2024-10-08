defmodule BubbleClicker.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias BubbleClicker.Repo

  alias BubbleClicker.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(key), do: Repo.get_by!(User, key: key)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def generate_uuid do
    Ecto.UUID.generate()
  end

  def increase_score(user_key, amount \\ 1) do
    query =
      from(u in User, update: [inc: [score: ^amount]], where: u.key == ^user_key, select: u)

    {_, [user]} = Repo.update_all(query, [])
    user.score
  end

  def increment_user_perk(user_key, perk_name, increase \\ 1, score_cost \\ 1) do
    query =
      from(u in User,
        update: [inc: [{^perk_name, ^increase}, {:score, -(^score_cost)}]],
        where: u.key == ^user_key,
        select: u
      )

    {_, [user]} = Repo.update_all(query, [])
    {get_in(user, [Access.key(perk_name)]), user.score}
  end
end
