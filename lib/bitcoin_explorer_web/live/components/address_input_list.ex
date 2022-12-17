defmodule BitcoinExplorerWeb.Components.AddressInputList do
  use BitcoinExplorerWeb, :component

  import BitcoinExplorerWeb.Components.AddressInput

  def address_input_list(assigns) do
    ~H"""
    <ol>
      <%= for {address, index} <- Enum.with_index(@addresses) do %>
        <li>
          <.address_input address={address} />
          <button phx-click="remove_address" phx-value-address={address} phx-value-index={index}>
            remove
          </button>
        </li>
      <% end %>
    </ol>
    """
  end
end
