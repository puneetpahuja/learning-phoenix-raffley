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
end
