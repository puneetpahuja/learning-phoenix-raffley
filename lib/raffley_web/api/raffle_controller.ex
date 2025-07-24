defmodule RaffleyWeb.Api.RaffleController do
  use RaffleyWeb, :controller
  alias Raffley.Admin
  alias Raffley.Raffles

  def index(conn, _params) do
    raffles = Admin.list_raffles()

    render(conn, :index, raffles: raffles)
  end

  def show(conn, %{"id" => id}) do
    raffle = Raffles.get_raffle!(id)

    render(conn, :show, raffle: raffle)
  end
end
