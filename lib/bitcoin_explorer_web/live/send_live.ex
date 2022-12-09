defmodule BitcoinExplorerWeb.SendLive do
  use BitcoinExplorerWeb, :live_view

  alias BitcoinExplorer.Wallet.Send
  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Key.HD.DerivationPath

  @destination_address "myKgsxuFQQvYkVjqUfXJSzoqYcywsCA4VS"

  @impl true
  def mount(_params, _session, socket) do
    [mnemonic_phrase: seed_phrase, derivation_path: derivation_path_string, tpub: tpub] =
      Application.get_env(:bitcoin_explorer, :bitcoin)

    {:ok, derivation_path} = DerivationPath.parse(derivation_path_string)

    master_private_key = PrivateKey.from_seed_phrase(seed_phrase)

    private_key =
      master_private_key
      |> PrivateKey.from_derivation_path!(derivation_path)

    {
      :ok,
      socket
      |> assign(:hero, "Send coins")
      |> assign(:utxos, get_utxos(tpub))
      |> assign(:private_key, private_key)
    }
  end

  @impl true
  def handle_event(
        "spend",
        %{"utxo" => utxo},
        %{assigns: %{private_key: xpub_private_key}} = socket
      ) do
    utxo
    |> decode()
    |> IO.inspect(label: "THE UTXO")
    |> Send.from_utxo(xpub_private_key, @destination_address)

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

  ## need to get change? and index for the address derivation path
  defp get_utxos(xpub) do
    xpub
    |> BitcoinAccounting.get_utxos()
    |> Enum.map(&extract_utxo/1)
    |> Enum.concat()
    |> Enum.sort(fn %{value: value1}, %{value: value2} -> value1 > value2 end)
    |> add_time
  end

  defp extract_utxo(
         {%BitcoinAccounting.XpubManager.AddressInfo{
            address: address,
            change?: change?,
            index: index
          }, utxo_list}
       ) do
    utxo_list
    |> Enum.map(fn utxo ->
      utxo
      |> Map.put(:address, address)
      |> Map.put(:change?, change?)
      |> Map.put(:index, index)
    end)
  end

  defp format_integer(integer) do
    integer
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(" ")
    |> String.reverse()
  end

  defp format_time(nil), do: "in mempool..."

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
