defmodule BitcoinExplorerWeb.TransactionLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Transaction

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    with {:ok, transaction} <- Transaction.get(id) do
      {
        :ok,
        socket
        |> assign(:transaction, transaction)
        |> assign(:total_output_sats, total_output_sats(transaction))
        |> assign(:format_sats, &format_sats/1)
      }
    else
      {:error, message} -> {:ok, socket |> assign(:error, message)}
    end
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
end
