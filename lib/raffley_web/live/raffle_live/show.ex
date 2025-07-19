defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # a phoenix callback that is invoked after mount and before render
  # params can be used in either mount() or handle_params(). it is a personal preference
  # but uri is only accessible in handle_params()
  def handle_params(%{"id" => id}, uri, socket) do
    raffle = Raffles.get_raffle(id)

    socket =
      socket
      |> assign(:raffle, raffle)
      |> assign(:page_title, raffle.prize)
      |> assign(:featured_raffles, Raffles.featured_raffles(raffle))

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-show">
      <div class="raffle">
        <img src={@raffle.image_path} />
        <section>
          <.badge status={@raffle.status} />
          <header>
            <h2>{@raffle.prize}</h2>
            <div class="price">${@raffle.ticket_price} / ticket</div>
          </header>
          <div class="description">
            {@raffle.description}
          </div>
        </section>
      </div>
      <div class="activity">
        <div class="left"></div>
        <div class="right">
          <.featured_raffles raffles={@featured_raffles} />
        </div>
      </div>
    </div>
    """
  end

  def featured_raffles(assigns) do
    ~H"""
    <section>
      <h4>Featured Raffles</h4>
      <ul class="raffles">
        <li :for={raffle <- @raffles}>
          <img src={raffle.image_path} />
          {raffle.prize}
        </li>
      </ul>
    </section>
    """
  end
end
