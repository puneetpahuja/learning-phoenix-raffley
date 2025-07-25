defmodule Raffley.Repo.Migrations.AddUsernameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
    end

    # this will raise an exception in case of trying to insert duplicate username
    create unique_index(:users, [:username])
  end
end
