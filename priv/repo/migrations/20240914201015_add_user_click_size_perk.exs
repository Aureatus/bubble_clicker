defmodule BubbleClicker.Repo.Migrations.AddUserClickSizePerk do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :click_size, :integer
    end
  end
end
