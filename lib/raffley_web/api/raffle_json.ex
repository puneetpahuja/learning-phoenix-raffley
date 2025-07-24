defmodule RaffleyWeb.Api.RaffleJSON do
  def index(%{raffles: raffles}) do
    %{raffles: for(raffle <- raffles, do: data(raffle))}
  end

  def show(%{raffle: raffle}) do
    %{raffle: data(raffle)}
  end

  defp data(raffle) do
    %{
      id: raffle.id,
      prize: raffle.prize,
      description: raffle.description,
      status: raffle.status,
      ticket_price: raffle.ticket_price,
      charity_id: raffle.charity_id
    }
  end
end
