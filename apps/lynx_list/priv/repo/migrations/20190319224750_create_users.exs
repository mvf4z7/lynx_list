defmodule LynxList.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string
      add :username, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
