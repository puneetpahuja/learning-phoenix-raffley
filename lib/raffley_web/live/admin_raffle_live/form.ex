defmodule RaffleyWeb.AdminRaffleLive.Form do
  use RaffleyWeb, :live_view
  alias Raffley.Raffles
  alias Raffley.Raffles.Raffle
  alias Raffley.Admin

  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    raffle = %Raffle{}
    changeset = Admin.change_raffle(raffle)

    socket
    # to_form() can't take a schema struct but can take a changeset
    # the `as:` is not required because it will use the lowercase schema name
    # sending the changeset will prefill the form with the schema default values
    |> assign(
      page_title: "New Raffle",
      form: to_form(changeset),
      raffle: raffle
    )
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    raffle = Raffles.get_raffle!(id)
    changeset = Admin.change_raffle(raffle)

    socket
    |> assign(
      page_title: "Edit Raffle",
      form: to_form(changeset),
      raffle: raffle
    )
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>
    <.simple_form for={@form} id="raffle-form" phx-submit="save" phx-change="validate">
      <%!-- required saves a server call and gives error on the client-side if the form is submitted with this field as blank --%>
      <.input field={@form[:prize]} label="Prize" required />

      <%!-- phx-debounce="blur" makes the validations run once we move out of this input field and not on every change i.e. every char typed --%>
      <.input
        field={@form[:description]}
        type="textarea"
        required
        label="Description"
        phx-debounce="blur"
      />

      <.input field={@form[:ticket_price]} type="number" required label="Ticket Price" />

      <.input
        required
        field={@form[:status]}
        type="select"
        label="Status"
        prompt="Choose a status"
        options={Raffles.status_values()}
      />

      <.input field={@form[:image_path]} label="Image Path" required />

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

  def handle_event("validate", %{"raffle" => raffle_params}, socket) do
    changeset = Admin.change_raffle(socket.assigns.raffle, raffle_params)
    # it will re-render the form and show the errors in the changeset
    # action is sent to make the form's action non-nil, so that it displays the errors
    socket = assign(socket, :form, to_form(changeset, action: :validate))
    {:noreply, socket}
  end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    save_raffle(socket, socket.assigns.live_action, raffle_params)
  end

  defp save_raffle(socket, :new, raffle_params) do
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

  defp save_raffle(socket, :edit, raffle_params) do
    case Admin.update_raffle(socket.assigns.raffle, raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle updated successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))

        {:noreply, socket}
    end
  end
end
