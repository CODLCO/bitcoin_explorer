defmodule BitcoinExplorerWeb.TransactionLive.Show do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Transaction
  alias BitcoinExplorer.Environment

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    with {:ok, transaction} <- Transaction.get(id) do
      {
        :ok,
        socket
        |> assign(:transaction, transaction)
        |> assign(:inputs, get_prevouts(transaction))
        |> assign(:total_output_sats, total_output_sats(transaction))
        |> assign(:format_sats, &format_sats/1)
        |> assign(:mempool_space_url, get_mempool_space_url(transaction, Environment.network()))
        |> assign(:hero, "transaction #{id}")
      }
    else
      {:error, message} -> {:ok, socket |> assign(:error, message)}
    end
  end

  defp get_prevouts(%BitcoinLib.Transaction{coinbase?: true}), do: []

  defp get_prevouts(%BitcoinLib.Transaction{inputs: inputs, coinbase?: false}) do
    inputs
    |> Enum.map(fn input ->
      with {:ok, transaction} <- Transaction.get(input.txid) do
        prevout =
          transaction
          |> Map.get(:outputs)
          |> Enum.at(input.vout)

        %{input: input, prevout: prevout}
      end
    end)
  end

  defp total_output_sats(%BitcoinLib.Transaction{outputs: outputs}) do
    outputs
    |> Enum.map(& &1.value)
    |> Enum.sum()
  end

  defp format_sats(value) do
    formatted = :erlang.float_to_binary(value / 100_000_000, decimals: 8)
    "#{formatted} BTC"
  end

  defp get_mempool_space_url(%BitcoinLib.Transaction{id: id}, :mainnet) do
    "https://mempool.space/tx/#{id}"
  end

  defp get_mempool_space_url(%BitcoinLib.Transaction{id: id}, :testnet) do
    "https://mempool.space/testnet/tx/#{id}"
  end
end
