defmodule LynxList.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :password_hash, :string
      add :github_id, :integer

      timestamps()
    end

    create unique_index(:credentials, [:user_id])
    create unique_index(:credentials, [:github_id])
  end
end
