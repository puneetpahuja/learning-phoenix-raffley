defmodule Raffley.Repo.Migrations.CreateRaffles do
  use Ecto.Migration

  def change do
    create table(:raffles) do
      # primary key column named `id` is automatically added for us
      add :prize, :string
      add :description, :text
      add :ticket_price, :integer
      add :status, :string
      add :image_path, :string

      # shortcut that adds to datetime columns: inserted_at and updated_at
      # these two columns are automatically populated by ecto during creation and updation
      timestamps(type: :utc_datetime)
    end
  end
end
