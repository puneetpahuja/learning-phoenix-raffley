defmodule Raffley.Raffles do
  @moduledoc """
     Boundary/layer to decouple web concers - controllers and live_views from 
     data access and business logic concerns.
     Phoenix calls it a context module.
     Naming convention: All the schema modules related to this context will remain in `raffles/` directory.
  """
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo

  def list_raffles do
    Repo.all(Raffle)
  end

  # ! at the end of the function name indicates that it can raise an error
  # don't need the guards as the Repo.get!() can take ids as string
  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def featured_raffles(raffle) do
    list_raffles() |> List.delete(raffle)
  end

  # Repo functions
  # Repo.all(Raffle) -> get all raffles
  # Repo.get(Raffle, 5) -> get raffle by id or primary key. returns nil if the id does not exist
  # Repo.get!(Raffle, 5) -> get raffle by id or primary key. raises exception if the id does not exist
  # Repo.get_by(Raffle, prize: "Cooking Class", image_path: "/images/abc.jpg") -> get raffle by any column or columns
  # Repo.delete(raffle) -> deletes a raffle
  # Repo.delete_all(Raffle) -> deletes all raffles
  # Repo.aggregate(Raffle, :count) -> counts all raffles
  # Repo.aggregate(Raffle, :sum, :ticket_price) -> gives the total sum of ticket_price column
  # Repo.aggregate(Raffle, :min, :ticket_price) -> gives the min of ticket_price column
  # Repo.aggregate(Raffle, :max, :ticket_price) -> gives the max of ticket_price column
  # Repo.aggregate(Raffle, :avg, :ticket_price) -> gives the average of ticket_price column
end
