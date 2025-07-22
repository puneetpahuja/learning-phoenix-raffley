defmodule Raffley.Raffles.Raffle do
  # by defining a schema, ecto automatically generates a struct named `Raffle` with the schema fields
  # you can delete any field if you don't need it in the Elixir realm but only the database realm
  use Ecto.Schema
  import Ecto.Changeset

  schema "raffles" do
    # this default value only exists in the Elixir realm, and not in the DB realm.
    # to make it visible in the DB realm, you have to add this default in the migration file.
    # field :status, Ecto.Enum, values: [:upcoming, :open, :closed] # auto-generated
    field :status, Ecto.Enum, values: [:upcoming, :open, :closed], default: :upcoming
    field :description, :string
    field :prize, :string
    # field :ticket_price, :integer # auto-generated
    field :ticket_price, :integer, default: 1
    # field :image_path, :string # auto-generated
    field :image_path, :string, default: "/images/placeholder.jpg"

    # creates two datetime fields: inserted_at and updated_at
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(raffle, attrs) do
    raffle
    |> cast(attrs, [:prize, :description, :ticket_price, :status, :image_path])
    |> validate_required([:prize, :description, :ticket_price, :status, :image_path])
  end
end
