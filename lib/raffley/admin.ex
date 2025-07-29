defmodule Raffley.Admin do
  alias Raffley.Raffles.Raffle
  alias Raffley.Raffles
  alias Raffley.Repo
  import Ecto.Query

  def list_raffles do
    Raffle
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_raffle(attrs \\ %{}) do
    %Raffle{}
    |> Raffle.changeset(attrs)
    |> Repo.insert()
  end

  # name can be confusing as it creates a changeset and is not a raffle changing function. but this is a convention.
  def change_raffle(%Raffle{} = raffle, attrs \\ %{}) do
    Raffle.changeset(raffle, attrs)
  end

  def update_raffle(%Raffle{} = raffle, attrs) do
    raffle
    |> Raffle.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, raffle} ->
        # do it here and not in the subscriber Show module so that only one DB query is fired
        # and not one per subscriber
        raffle = Repo.preload(raffle, [:charity, :winning_ticket])
        Raffles.broadcast(raffle.id, {:raffle_updated, raffle})
        {:ok, raffle}

      {:error, _} = error ->
        error
    end
  end

  def draw_winner(%Raffle{status: :closed} = raffle) do
    raffle = Repo.preload(raffle, :tickets)

    case raffle.tickets do
      [] ->
        {:error, "No tickets to draw!"}

      tickets ->
        winner = Enum.random(tickets)
        # this line will return {:ok, _raffle}
        {:ok, _raffle} = update_raffle(raffle, %{winning_ticket_id: winner.id})
    end
  end

  def draw_winner(%Raffle{} = raffle) do
    {:error, "Raffle must be closed to draw a winner!"}
  end

  def delete_raffle(%Raffle{} = raffle) do
    Repo.delete(raffle)
  end
end
