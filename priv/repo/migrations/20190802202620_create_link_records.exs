defmodule LynxList.Repo.Migrations.CreateLinkRecords do
  use Ecto.Migration

  def change do
    create table(:link_records) do
      add :description, :text, null: false
      add :private, :boolean, null: false
      add :title, :text, null: false

      add :link_id, references(:links, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:link_records, [:link_id, :user_id])
  end
end
