defmodule BitcoinExplorerWeb.SendLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Wallet.Send
  alias BitcoinExplorer.{Encoder, Environment, Formatter, Utxo}
  alias BitcoinExplorer.Changesets

  import BitcoinExplorerWeb.Components.{Textbox, UtxoList}

  @destination_address "myKgsxuFQQvYkVjqUfXJSzoqYcywsCA4VS"

  @impl true
  def mount(_params, _session, socket) do
    BitcoinCoreClient.Subscriptions.subscribe_blocks()

    {
      :ok,
      socket
      |> assign(:hero, "Send coins")
      |> refresh_utxos()
      |> create_changeset()
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
      |> calculate_selected()
    }
  end

  @impl true
  def handle_event("validate", %{"send_bitcoin" => send_bitcoin}, socket) do
    changeset = Changesets.SendBitcoin.validate(send_bitcoin)

    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("send", %{"send_bitcoin" => send_bitcoin}, socket) do
    socket =
      case Changesets.SendBitcoin.validate(send_bitcoin) do
        %Ecto.Changeset{valid?: true, changes: %{amount: amount, fee: fee}} ->
          send_bitcoin(socket, amount, fee, @destination_address)

        %Ecto.Changeset{valid?: false, errors: errors} ->
          socket |> put_flash(:error, "changeset: #{inspect(errors)}")
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(_message, socket) do
    {
      :noreply,
      socket
      |> get_utxos()
    }
  end

  defp send_bitcoin(socket, amount, fee, address) do
    utxos = socket |> get_selected_utxos

    case utxos do
      [] ->
        socket |> put_flash(:error, "no utxo selected")

      _ ->
        case Send.from_utxo_list(utxos, address) do
          {:ok, txid} ->
            socket
            |> put_flash(:info, "Broadcasted #{txid}")
            |> refresh_utxos()

          {:error, message} ->
            socket |> put_flash(:error, message)
        end
    end
  end

  defp refresh_utxos(socket) do
    socket
    |> get_utxos()
    |> calculate_balance()
    |> calculate_selected()
  end

  defp create_changeset(socket) do
    changeset = Changesets.SendBitcoin.validate(%{})

    socket
    |> assign(:changeset, changeset)
  end

  defp get_utxos(socket) do
    utxos =
      Environment.xpub()
      |> Utxo.from_xpub()

    socket
    |> assign(:utxos, utxos)
  end

  defp calculate_balance(%{assigns: %{utxos: utxos}} = socket) do
    balance =
      utxos
      |> Enum.map(& &1.value)
      |> Enum.sum()

    socket
    |> assign(:balance, balance)
  end

  defp calculate_selected(socket) do
    selected =
      get_selected_utxos(socket)
      |> Enum.map(& &1.value)
      |> Enum.sum()

    socket
    |> assign(:selected, selected)
  end

  defp get_selected_utxos(socket) do
    socket.assigns.utxos
    |> Enum.filter(&(&1.selected == true))
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
end
