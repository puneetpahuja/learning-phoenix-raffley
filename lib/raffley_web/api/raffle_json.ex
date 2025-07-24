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

  def error(%{changeset: changeset}) do
    errors = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    %{errors: errors}
  end

  defp translate_error({msg, opts}) do
    # msg example: "should be at least %{count} character(s)"
    # opts example: [count: 10, validation: :length, kind: :min, type: :string]
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
