defmodule BubbleClicker.Repo.Migrations.AddUserGridSizePerk do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :grid_size, :integer
    end
  end
end
