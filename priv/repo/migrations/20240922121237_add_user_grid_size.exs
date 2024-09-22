defmodule BubbleClicker.Repo.Migrations.AddUserClickSizePerk do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :grid_size, :integer
    end
  end
end
