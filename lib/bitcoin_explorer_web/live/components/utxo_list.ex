defmodule BitcoinExplorerWeb.Components.UtxoList do
  use BitcoinExplorerWeb, :component

  import BitcoinExplorerWeb.Components.Utxo

  def utxo_list(assigns) do
    ~H"""
    <div class="m-2 grid grid-cols-6 w-fit font-data text-sm">
      <div class="mb-2 text-gray-500 col-span-2">transaction_id:vout</div>
      <div></div>
      <div class="text-gray-500 justify-self-end">sats</div>
      <div class="text-gray-500 justify-self-end">selected</div>
      <div></div>

      <%= for utxo <- @utxos do %>
        <.utxo utxo={utxo} />
      <% end %>
    </div>
    """
  end
end
