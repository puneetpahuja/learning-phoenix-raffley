defmodule Raffley.Raffles do
  @moduledoc """
     Boundary/layer to decouple web concers - controllers and live_views from 
     data access and business logic concerns.
     Phoenix calls it a context module.
     Naming convention: All the schema modules related to this context will remain in `raffles/` directory.
  """
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  import Ecto.Query

  def list_raffles do
    Repo.all(Raffle)

    # list all raffles with their associated charities
    # Repo.all(Raffle) |> Repo.preload(:charity)
  end

  def filter_raffles(filter) do
    Raffle
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> with_charity(filter["charity"])
    |> sort(filter["sort_by"])
    |> preload(:charity)
    |> Repo.all()
  end

  defp with_charity(query, slug) do
    cond do
      slug in ["", nil] ->
        query

      # join() is inner join, for left join use left_join()
      true ->
        # alternate ways for the same query
        #
        # query
        # |> join(:inner, [r], c in Charity, on: r.charity_id == c.id)
        # |> where([r, c], c.slug == ^slug)
        #
        # from r in query,
        #   join: c in Charity,
        #   on: r.charity_id == c.id,
        #   where: c.slug == ^slug
        #
        # query
        # |> join(:inner, [r], c in assoc(r, :charity))
        # |> where([r, c], c.slug == ^slug)
        from r in query,
          # assoc() works only if you have ecto associations set up in the raffle schema
          join: c in assoc(r, :charity),
          where: c.slug == ^slug
    end
  end

  defp sort(query, "prize") do
    order_by(query, :prize)
  end

  defp sort(query, "ticket_price_desc") do
    order_by(query, desc: :ticket_price)
  end

  defp sort(query, "ticket_price_asc") do
    order_by(query, :ticket_price)
  end

  defp sort(query, "charity") do
    # macro syntax
    #
    # query
    # |> join(:inner, [r], c in assoc(r, :charity))
    # |> order_by([r, c], asc: c.name)
    from r in query,
      join: c in assoc(r, :charity),
      # for decreasing order
      # order_by: {:desc, c.name}
      order_by: c.name
  end

  defp sort(query, _) do
    order_by(query, :id)
  end

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q) do
    where(query, [r], ilike(r.prize, ^"%#{q}%"))
  end

  defp with_status(query, status) do
    if is_binary(status) and String.to_existing_atom(status) in status_values() do
      where(query, status: ^status)
    else
      query
    end
  end

  # ! at the end of the function name indicates that it can raise an error
  # don't need the guards as the Repo.get!() can take ids as string
  def get_raffle!(id) do
    Repo.get!(Raffle, id)
    |> Repo.preload(:charity)

    # get a raffle with it's associated charity
    # Repo.get!(Raffle, id) |> Repo.preload(:charity)
  end

  def featured_raffles(raffle) do
    Process.sleep(2000)

    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end

  def status_values() do
    Ecto.Enum.values(Raffle, :status)
  end

  # Repo functions
  # Repo.all(Raffle) -> get all raffles
  # Repo.get(Raffle, 5) -> get raffle by id or primary key. returns nil if the id does not exist
  # Repo.get!(Raffle, 5) -> get raffle by id or primary key. raises exception if the id does not exist
  # Repo.get_by(Raffle, prize: "Cooking Class", image_path: "/images/abc.jpg") -> get raffle by any column or columns
  # Repo.delete(raffle) -> deletes a raffle
  # Repo.delete_all(Raffle) -> deletes all raffles
  # Repo.aggregate(Raffle, :count) -> counts all raffles
  # Repo.aggregate(Raffle, :sum, :ticket_price) -> gives the total sum of ticket_price column
  # Repo.aggregate(Raffle, :min, :ticket_price) -> gives the min of ticket_price column
  # Repo.aggregate(Raffle, :max, :ticket_price) -> gives the max of ticket_price column
  # Repo.aggregate(Raffle, :avg, :ticket_price) -> gives the average of ticket_price column

  # Query functions 
  # import Ecto.Query
  # query = from(Raffle)
  # Repo.all(query)
  # query = from Raffle, where: [status: :open]
  # Repo.all(query)
  # query = from Raffle, where: [status: :open], order_by: :prize  # ascending order
  # Repo.all(query)
  # query = from Raffle, where: [status: :open], order_by: [desc: :prize]
  # Repo.all(query)
  # other keywords: select, join, group_by
  # status = "closed"
  # status can't be used as this, need to be pinned using ^
  # when ecto converts this query to sql statement, it will be sanitized and sql injection attacks will be prevented
  # also the type will be taken from the schema and casted accordingly during interpolation. so we can pass a string for an atom type.
  # query = from Raffle, where: [status: status], order_by: [desc: :prize] # wrong
  # query = from Raffle, where: [status: ^status], order_by: [desc: :prize]

  # query = from r in Raffle, where: r.ticket_price > 2
  # query = from r in Raffle, where: r.ticket_price == 2
  # query = from r in Raffle, where: ilike(r.prize, "%ride%")

  # extend query - compose queries
  # query = from Raffle
  # query = from query, where: [status: :open]
  # query = from query, order_by: :prize
  # query = from query, limit: 2

  # previous queries use keyword syntax
  # let's look at macro or pipe syntax
  # query = from Raffle
  # query = where(query, status: :closed)
  # query = order_by(query, :prize)
  # Repo.all(query)
  # query = from Raffle |> where(status: :closed) |> order_by(:prize)
  # Repo.all(query)
end
