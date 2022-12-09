defmodule BitcoinExplorerWeb.SendLive do
  use BitcoinExplorerWeb, :live_view

  alias BitcoinExplorer.Wallet

  @impl true
  def mount(_params, _session, socket) do
    [mnemonic_phrase: _, tpub: tpub] = Application.get_env(:bitcoin_explorer, :bitcoin)

    {
      :ok,
      socket
      |> assign(:hero, "Send coins")
      |> assign(:utxos, get_utxos(tpub))
    }
  end

  @impl true
  def handle_event("spend", %{"utxo" => utxo}, socket) do
    utxo
    |> decode()
    |> Wallet.send()

    {:noreply, socket}
  end

  defp encode(value) do
    value
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end

  defp decode(value) do
    value
    |> Base.decode64()
    |> elem(1)
    |> :erlang.binary_to_term()
  end

  defp get_utxos(xpub) do
    xpub
    |> BitcoinAccounting.get_utxos()
    |> Enum.map(&elem(&1, 1))
    |> Enum.concat()
    |> Enum.sort(fn %{value: value1}, %{value: value2} -> value1 > value2 end)
    |> add_time
  end

  defp format_integer(integer) do
    integer
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(" ")
    |> String.reverse()
  end

  defp format_time(time) do
    time
    |> DateTime.to_string()
  end

  defp add_time(utxo_list) do
    utxo_list
    |> Enum.map(fn utxo ->
      transaction = ElectrumClient.get_transaction(utxo.transaction_id)

      Map.put(utxo, :time, transaction.time)
    end)
  end

  defp shorten_txid(txid, nb_chars) do
    "#{String.slice(txid, 0, nb_chars)}...#{String.slice(txid, -nb_chars, nb_chars)}"
  end
end
