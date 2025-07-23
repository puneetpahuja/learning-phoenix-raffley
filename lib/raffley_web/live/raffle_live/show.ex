defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # a phoenix callback that is invoked after mount and before render
  # params can be used in either mount() or handle_params(). it is a personal preference
  # but uri is only accessible in handle_params()
  def handle_params(%{"id" => id}, _uri, socket) do
    raffle = Raffles.get_raffle!(id)

    socket =
      socket
      |> assign(:raffle, raffle)
      |> assign(:page_title, raffle.prize)
      # shape of async result: %Phoenix.LiveView.AsyncResult{ok?: false, loading: [:featured_raffles], failed: nil, result: nil}
      |> assign_async(:featured_raffles, fn ->
        {:ok, %{featured_raffles: Raffles.featured_raffles(raffle)}}
        # {:error, "abc"}
      end)

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
          <.featured_raffles raffles_async={@featured_raffles} />
        </div>
      </div>
    </div>
    """
  end

  attr :raffles_async, Phoenix.LiveView.AsyncResult, required: true

  def featured_raffles(assigns) do
    ~H"""
    <section>
      <h4>Featured Raffles</h4>
      <%!-- shape of async result: %Phoenix.LiveView.AsyncResult{ok?: false, loading: [:featured_raffles], failed: nil, result: nil} --%>
      <%!-- result is only accessible in the inner_block and not other named blocks --%>
      <.async_result :let={result} assign={@raffles_async}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div class="failed">
            Yikes: {reason}
          </div>
        </:failed>
        <%!-- inner_block is loaded only if @raffles_async.ok? is true --%>
        <ul class="raffles">
          <li :for={raffle <- result}>
            <.link navigate={~p"/raffles/#{raffle.id}"}>
              <img src={raffle.image_path} />
              {raffle.prize}
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end
end
