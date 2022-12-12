defmodule BitcoinExplorerWeb.SendLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Wallet.Send
  alias BitcoinExplorer.{Encoder, Environment, Formatter}

  import BitcoinExplorerWeb.Components.Utxo

  @destination_address "myKgsxuFQQvYkVjqUfXJSzoqYcywsCA4VS"

  @impl true
  def mount(_params, _session, socket) do
    BitcoinCoreClient.Subscriptions.subscribe_blocks()

    {
      :ok,
      socket
      |> assign(:hero, "Send coins")
      |> refresh_utxos
    }
  end

  @impl true
  def handle_event("spend", %{"utxo" => encoded_utxo}, socket) do
    utxo = Encoder.decode(encoded_utxo)

    socket =
      case Send.from_utxo(utxo, @destination_address) do
        {:ok, txid} -> socket |> put_flash(:info, "Broadcasted #{txid}")
        {:error, message} -> socket |> put_flash(:error, message)
      end

    {
      :noreply,
      socket
      |> refresh_utxos()
    }
  end

  @impl true
  def handle_event(
        "toggle_utxo",
        %{"txid" => txid, "vout" => vout},
        socket
      ) do
    {vout, _} = Integer.parse(vout)

    {
      :noreply,
      socket
      |> toggle_utxo_selection(txid, vout)
    }
  end

  @impl true
  def handle_info(_message, socket) do
    {
      :noreply,
      socket
      |> assign(:utxos, get_utxos())
    }
  end

  defp refresh_utxos(socket) do
    utxos = get_utxos()
    balance = calculate_balance(utxos)

    socket
    |> assign(:utxos, utxos)
    |> assign(:balance, balance)
  end

  ## need to get change? and index for the address derivation path
  defp get_utxos() do
    Environment.xpub()
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
      |> Map.put(:selected, false)
    end)
  end

  defp calculate_balance(utxos) do
    utxos
    |> Enum.map(& &1.value)
    |> Enum.sum()
  end

  defp toggle_utxo_selection(socket, txid, vout) do
    utxos = socket.assigns.utxos

    utxos =
      utxos
      |> Enum.map(fn utxo ->
        if utxo.transaction_id == txid && utxo.vxid == vout,
          do: Map.put(utxo, :selected, !utxo.selected),
          else: utxo
      end)

    socket
    |> assign(utxos: utxos)
  end

  defp add_time(utxo_list) do
    utxo_list
    |> Enum.map(fn utxo ->
      transaction = ElectrumClient.get_transaction(utxo.transaction_id)

      Map.put(utxo, :time, transaction.time)
    end)
  end
end
