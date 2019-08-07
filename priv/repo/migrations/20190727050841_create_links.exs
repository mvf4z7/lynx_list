defmodule LynxList.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :title, :text, null: false
      add :url, :text, null: false
      add :last_updated_meta, :utc_datetime

      timestamps()
    end

    create unique_index(:links, [:url])
  end
end
