defmodule BubbleClicker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :key, :string
      add :score, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
