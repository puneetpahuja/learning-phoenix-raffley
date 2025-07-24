defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    # to_form() expects the map to have string keys
    # don't need to pass values that will be initially empty
    # form = to_form(%{"q" => "", "status" => "", "sort_by" => ""})

    # attach_hook() is used for callback hooks at different stages of the liveview
    # socket =
    #   attach_hook(socket, :log_stream, :after_render, fn socket ->
    #     IO.inspect(socket.assigns.streams.raffles, label: "AFTER RENDER")
    #     socket
    #   end)

    {:ok, socket}
  end

  # handle_params() is called in two scenarios
  # 1. always after mount()
  # 2. whenever there's is a live navigation using patch - mount() is not called in this scenario. so all the data handling needs to be done in handle_params().
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(page_title: "Raffles", form: to_form(params))
      # reset is done to call filter_raffles() again
      |> stream(:raffles, Raffles.filter_raffles(params), reset: true)

    {:noreply, socket}
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
        <%!-- in case of no results. `hidden` keeps it hidden by default. `only:block` makes it visible if it's the only child of the parent container. --%>
        <div id="empty" class="no-results only:block hidden">
          No raffles found. Try changing your filters.
        </div>
        <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
      </div>
    </div>
    """
  end

  attr :form, :map, required: true

  def filter_form(assigns) do
    ~H"""
    <%!-- phx-change sends event on every form change, phx-submit sends in only on submit  --%>
    <.form for={@form} id="filter-form" phx-change="filter" phx-submit="filter">
      <%!-- can use form["q"] also --%>
      <%!-- turns off browser autocomplete - previous things searched for in the browser on other sites --%>
      <%!-- phx-debounce prevents db queries by firing a server request only after 500 milliseconds and not on every change --%>
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" phx-debounce="500" />

      <%!-- options can be strings also --%>
      <.input type="select" field={@form[:status]} prompt="Status" options={Raffles.status_values()} />

      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort By"
        options={[
          Prize: "prize",
          "Price: High to Low": "ticket_price_desc",
          "Price: Low to High": "ticket_price_asc"
        ]}
      />
      <.link patch={~p"/raffles"}> Reset </.link>
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
        <div class="charity">
          {@raffle.charity.name}
        </div>
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

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w(q status sort_by))
      |> Map.reject(fn {_, v} -> v == "" end)

    # add url params from filter_form
    # the conversion of #{params} map to url params is taken care of by ~p
    # push_navigate() will mount a new liveview. it does the same thing as calling <.link> in the browser.
    # socket = push_navigate(socket, to: ~p"/raffles?#{params}")
    # push_patch() will use the current liveview. 
    socket = push_patch(socket, to: ~p"/raffles?#{params}")

    {:noreply, socket}
  end
end
