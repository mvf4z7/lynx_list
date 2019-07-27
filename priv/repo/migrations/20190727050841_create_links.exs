defmodule LynxList.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :description, :text
      add :private, :boolean, null: false
      add :title, :text
      add :url, :text, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
