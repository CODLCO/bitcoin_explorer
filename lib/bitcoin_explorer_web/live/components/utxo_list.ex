defmodule BitcoinExplorerWeb.Components.UtxoList do
  use BitcoinExplorerWeb, :component

  import BitcoinExplorerWeb.Components.Utxo

  alias BitcoinExplorer.{Encoder, Formatter}

  def utxo_list(assigns) do
    ~H"""
    <div class="overflow-x-auto relative shadow-md sm:rounded-lg">
      <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
        <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
          <tr>
            <th scope="col" class="p-4">
              <div class="flex items-center">
                <input
                  id="checkbox-all-search"
                  type="checkbox"
                  class="w-4 h-4 text-blue-600 bg-gray-100 rounded border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
                />
                <label for="checkbox-all-search" class="sr-only">checkbox</label>
              </div>
            </th>
            <th scope="col" class="py-3 px-6 text-right">
              Sats
            </th>
            <th scope="col" class="py-3 px-6"></th>
            <th scope="col" class="py-3 px-6">
              Output
            </th>
          </tr>
        </thead>
        <tbody>
          <%= for {utxo, index} <- Enum.with_index(@utxos) do %>
            <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
              <td class="p-4 w-4">
                <div class="flex items-center">
                  <input
                    id={"checkbox-table-search-#{index}"}
                    type="checkbox"
                    phx-click="utxo_selected"
                    phx-value-utxo={Encoder.encode(utxo)}
                    class="w-4 h-4 text-blue-600 bg-gray-100 rounded border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
                  />
                  <label for="checkbox-table-search-1" class="sr-only">checkbox</label>
                </div>
              </td>
              <td class="px-6 text-right dark:text-white">
                <%= Formatter.integer(utxo.value) %>
              </td>
              <td class="px-6">
                <%= format_time(utxo.time) %>
              </td>
              <th scope="row" class="px-6 font-medium whitespace-nowrap">
                <.link href={~p"/transactions/#{utxo.transaction_id}"}>
                  <%= utxo.transaction_id %>:<%= utxo.vxid %>
                </.link>
              </th>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  defp format_time(nil), do: "in mempool..."
  defp format_time(datetime), do: Formatter.datetime(datetime)

  defp is_selected_class(%{selected: true}), do: "text-yellow-600"
  defp is_selected_class(%{selected: false}), do: ""
end
