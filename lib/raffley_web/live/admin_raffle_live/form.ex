defmodule RaffleyWeb.AdminRaffleLive.Form do
  use RaffleyWeb, :live_view
  alias Raffley.Raffles
  alias Raffley.Raffles.Raffle
  alias Raffley.Admin

  def mount(_params, _session, socket) do
    changeset = Raffle.changeset(%Raffle{}, %{})

    socket =
      socket
      # to_form() can't take a schema struct but can take a changeset
      # the `as:` is not required because it will use the lowercase schema name
      # sending the changeset will prefill the form with the schema default values
      |> assign(page_title: "New Raffle", form: to_form(changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>
    <.simple_form for={@form} id="raffle-form" phx-submit="save">
      <.input field={@form[:prize]} label="Prize" />

      <.input field={@form[:description]} type="textarea" label="Description" />

      <.input field={@form[:ticket_price]} type="number" label="Ticket Price" />

      <.input
        field={@form[:status]}
        type="select"
        label="Status"
        prompt="Choose a status"
        options={Raffles.status_values()}
      />

      <.input field={@form[:image_path]} label="Image Path" />

      <:actions>
        <%!-- phx-disable-with comes into action when you press this button --%>
        <.button phx-disable-with="Saving...">Save Raffle</.button>
      </:actions>
    </.simple_form>

    <.back navigate={~p"/admin/raffles"}>
      Back
    </.back>
    """
  end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    case Admin.create_raffle(raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          # assigns a flash message to socket
          # by default handles :info, :error
          |> put_flash(:info, "Raffle created successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        # will re-render the form with errors in the changeset
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end
end
