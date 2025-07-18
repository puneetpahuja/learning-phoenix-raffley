defmodule RaffleyWeb.CustomComponents do
  # This will require you to explicitly alias or import this module in the caller module
  # use RaffleyWeb, :html 

  # This will make these components visible throughout the project without any import or alias required. Use these components unqualified as if you have imported this module.
  # Also need to add the import of this file in raffley_web.ex:line94 file for the above to be possible
  use Phoenix.Component

  # To use ~p, if the components defined here use verified routes
  use RaffleyWeb, :verified_routes

  attr :status, :atom, required: true, values: [:open, :upcoming, :closed]
  attr :class, :string, default: nil
  # to get all the global attributes like id etc. and phx- attributes like phx-click etc.
  # also any other attribute not defined in the attributes above
  # you can name this attr anything
  attr :rest, :global

  def badge(assigns) do
    ~H"""
    <div class={[
      "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      @status == :open && "text-lime-600 border-lime-600",
      @status == :upcoming && "text-amber-600 border-amber-600",
      @status == :closed && "text-gray-600 border-gray-600",
      @class
    ]}>
      {@status}
    </div>
    """
  end

  # slot: pass heex content to a function component
  # :inner_block is the default slot and cannot be named anything else. anything that is not inside a named slot in the caller goes in inner_block. it concatenates all the heex content fragments not inside a named slot.
  slot :inner_block, required: true

  # rest all are named slots and can be named anything. the caller has to add the heex content in the same named tags.
  slot :details

  def banner(assigns) do
    assigns = assign(assigns, :emoji, ~w(😎 🤩 🥳) |> Enum.random())

    ~H"""
    <div class="banner">
      <h1>
        {render_slot(@inner_block)}
      </h1>
      <%!-- can use `:if={details != []}` here for conditional rendering --%>
      <div :for={details <- @details} class="details">
        {render_slot(details, @emoji)}
      </div>
    </div>
    """
  end
end
