defmodule BitcoinExplorerWeb.Components.Utxo do
  use BitcoinExplorerWeb, :component

  alias BitcoinExplorer.{Encoder, Formatter}

  def utxo_list(assigns) do
    ~H"""
    <div class="m-2 grid grid-cols-6 w-fit font-data text-sm">
      <div class="mb-2 text-gray-500 col-span-2">transaction_id:vout</div>
      <div></div>
      <div class="text-gray-500 justify-self-end">sats</div>
      <div class="text-gray-500 justify-self-end">selected</div>
      <div></div>

      <%= for utxo <- @utxos do %>
        <div class="col-span-2" title={utxo.transaction_id}>
          <.link href={~p"/transactions/#{utxo.transaction_id}"}>
            <%= Formatter.shorten_txid(utxo.transaction_id, 12) %>:<%= utxo.vxid %>
          </.link>
        </div>
        <div><%= format_time(utxo.time) %></div>
        <div
          class="justify-self-end"
          phx-click="toggle_utxo"
          phx-value-txid={utxo.transaction_id}
          phx-value-vout={utxo.vxid}
        >
          <%= Formatter.integer(utxo.value) %>
        </div>
        <div class="justify-self-end"><%= utxo.selected %></div>
        <div class="justify-self-end">
          <button phx-click="spend" phx-value-utxo={Encoder.encode(utxo)} phx-value-vout={utxo.vxid}>
            spend
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  defp format_time(nil), do: "in mempool..."

  defp format_time(datetime), do: Formatter.datetime(datetime)
end
