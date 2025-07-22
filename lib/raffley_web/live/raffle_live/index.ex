defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    # to_form() expects the map to have string keys
    # don't need to pass values that will be initially empty
    # form = to_form(%{"q" => "", "status" => "", "sort_by" => ""})
    form = to_form(%{})

    socket =
      socket
      |> assign(page_title: "Raffles", form: form)
      |> stream(:raffles, Raffles.list_raffles())

    # attach_hook() is used for callback hooks at different stages of the liveview
    # socket =
    #   attach_hook(socket, :log_stream, :after_render, fn socket ->
    #     IO.inspect(socket.assigns.streams.raffles, label: "AFTER RENDER")
    #     socket
    #   end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <.banner :if={false}>
        <.icon name="hero-sparkles-solid" /> Mystery Raffle Coming Soon!
        <:details :let={vibe}>
          To Be Revealed Tomorrow {vibe}
        </:details>
        <:details>
          Any guesses?
        </:details>
      </.banner>

      <.filter_form form={@form} />

      <%!-- whenever you use a stream, the parent container also needs 
        1. a unique id (dom requirement).
        2. `phx-update="stream"`--%>
      <div class="raffles" id="raffles" phx-update="stream">
        <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
      </div>
    </div>
    """
  end

  attr :form, :map, required: true

  def filter_form(assigns) do
    ~H"""
    <.form for={@form}>
      <%!-- can use form["q"] also --%>
      <%!-- turns off browser autocomplete - previous things searched for in the browser on other sites --%>
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" />

      <%!-- options can be strings also --%>
      <.input type="select" field={@form[:status]} prompt="Status" options={Raffles.status_values()} />

      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort By"
        options={[:prize, :ticket_price]}
      />
    </.form>
    """
  end

  # to get compile time errors if the correct attributes are not sent 
  # while calling the function component raffle_card() 
  attr :raffle, Raffley.Raffles.Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <%!-- `navigate` is more performant than `href`. one less set of mount() and render(). uses existing websocket. works only between liveviews. --%>
    <%!-- <.link href={~p"/raffles/#{@raffle.id}"}> --%>
    <%!-- a unique id is required by dom --%>
    <.link navigate={~p"/raffles/#{@raffle.id}"} id={@id}>
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
    </.link>
    """
  end
end
