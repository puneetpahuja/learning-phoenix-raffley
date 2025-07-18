defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    socket = assign(socket, :raffles, Raffles.list_raffles())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <.banner>
        <.icon name="hero-sparkles-solid" /> Mystery Raffle Coming Soon!
        <:details :let={vibe}>
          To Be Revealed Tomorrow {vibe}
        </:details>
        <:details>
          Any guesses?
        </:details>
      </.banner>
      <div class="raffles">
        <.raffle_card :for={raffle <- @raffles} raffle={raffle} />
      </div>
    </div>
    """
  end

  # to get compile time errors if the correct attributes are not sent 
  # while calling the function component raffle_card() 
  attr :raffle, Raffley.Raffle, required: true

  def raffle_card(assigns) do
    ~H"""
    <div class="card">
      <img src={@raffle.image_path} />
      <h2>{@raffle.prize}</h2>
      <div class="details">
        <div class="price">
          ${@raffle.ticket_price} / ticket
        </div>
        <.badge status={@raffle.status} />
      </div>
    </div>
    """
  end
end
