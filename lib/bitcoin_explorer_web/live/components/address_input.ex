defmodule BitcoinExplorerWeb.Components.AddressInput do
  use BitcoinExplorerWeb, :component

  def address_input(assigns) do
    ~H"""
    <input
      autocomplete="off"
      class="w-[26rem] mr-2"
      name="address_list[addresses][]"
      type="text"
      value={@address}
    />
    """
  end
end
