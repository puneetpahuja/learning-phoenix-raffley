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

    # establish the relationship with charities in the ecto realm
    # belongs_to() is always declared in the schema that has the foreign key
    # :charity is the association name
    belongs_to :charity, Raffley.Charities.Charity
    # fields defined under-the-hood by ecto because of belongs_to
    # the name of the fields are inferred from the association name given to belongs_to
    # field :charity_id  # it holds the foreign key
    # field :charity # it holds the charity struct the raffle belongs to
    #
    # added manually
    has_many :tickets, Raffley.Tickets.Ticket

    # creates two datetime fields: inserted_at and updated_at
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(raffle, attrs) do
    raffle
    |> cast(attrs, [:prize, :description, :ticket_price, :status, :image_path, :charity_id])
    |> validate_required([:prize, :description, :ticket_price, :status, :image_path, :charity_id])
    |> validate_length(:description, min: 10)
    |> validate_number(:ticket_price, greater_than_or_equal_to: 1)
    # converts the foreign key DB exception to a changeset error
    |> assoc_constraint(:charity)
  end
end
