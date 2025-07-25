defmodule RaffleyWeb.AdminRaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Admin
  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Raffles")
      |> stream(:raffles, Admin.list_raffles())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <%!-- elixir gives a bunch of JS commands to avoid writing custom JS code to do somethings on the client side without a server side round trip like show, hide, toggle some element on the webpage --%>
      <%!-- by default these commands target the calling element. to target a specific element, you have to use the to option with the dom selector --%>
      <%!-- in takes the css classes to apply while toggling in --%>
      <%!-- out takes the css classes to apply while toggling out --%>
      <.button phx-click={
        JS.toggle(
          to: "#joke",
          # in: "fade-in",
          in: {"ease-in-out duration-300", "opacity-0", "opacity-100"},
          # out: "fade-out"
          out: {"ease-in-out duration-300", "opacity-100", "opacity-0"},
          time: 300
        )
      }>
        Toggle Joke
      </.button>
      <div id="joke" class="joke hidden">What's a tree's favorite drink, {@current_user.username}?</div>

      <.header>
        {@page_title}
        <:actions>
          <.link navigate={~p"/admin/raffles/new"} class="button">New Raffle</.link>
        </:actions>
      </.header>
      <%!-- row_click makes the whole row clickable --%>
      <.table
        id="raffles"
        rows={@streams.raffles}
        row_click={fn {_id, raffle} -> JS.navigate(~p"/raffles/#{raffle.id}") end}
      >
        <:col :let={{_dom_id, raffle}} label="Prize">
          <.link navigate={~p"/raffles/#{raffle.id}"}>
            {raffle.prize}
          </.link>
        </:col>
        <:col :let={{_dom_id, raffle}} label="Status">
          <.badge status={raffle.status} />
        </:col>
        <:col :let={{_dom_id, raffle}} label="Ticket Price">
          {raffle.ticket_price}
        </:col>
        <%!-- to show user actions in the last column of the table --%>
        <:action :let={{_dom_id, raffle}}>
          <.link navigate={~p"/admin/raffles/#{raffle}/edit"}>Edit</.link>
        </:action>
        <:action :let={{dom_id, raffle}}>
          <%!-- data-confirm pops browser's native confirmation dialog --%>
          <%!-- we need JS commands to send an event to the server asynchronously and change the opacity on the client side without any server calls, at the same time --%>
          <%!-- <.link phx-click="delete" phx-value-id={raffle.id} data-confirm="Are you sure?"> --%>
          <.link phx-click={delete_and_hide(dom_id, raffle)} data-confirm="Are you sure?">
            Delete
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    raffle = Raffles.get_raffle!(id)
    {:ok, _} = Admin.delete_raffle(raffle)

    {:noreply, stream_delete(socket, :raffles, raffle)}
  end

  def delete_and_hide(dom_id, raffle) do
    JS.push("delete", value: %{id: raffle.id})
    # there is also remove_class() and toggle_class()
    # |> JS.add_class("opacity-50", to: "##{dom_id}")
    |> JS.hide(to: "##{dom_id}", transition: "fade-out")
  end
end
