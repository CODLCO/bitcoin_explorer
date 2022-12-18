defmodule BitcoinExplorerWeb.SendLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorerWeb.SendLive.Form
  alias BitcoinExplorer.Wallet.Send
  alias BitcoinExplorer.{Encoder, Environment, Formatter, Utxo}
  alias BitcoinExplorer.Changesets

  import BitcoinExplorerWeb.Components.UtxoList

  @default_fee 340
  @default_addresses ["mgJ6YsnKxbDvR2aiwFreu2hEgyR7bxcwrr"]
  @destination_address "myKgsxuFQQvYkVjqUfXJSzoqYcywsCA4VS"

  @impl true
  def mount(_params, _session, socket) do
    BitcoinCoreClient.Subscriptions.subscribe_blocks()

    {
      :ok,
      socket
      |> assign(:hero, "Send coins")
      |> assign(:fee, @default_fee)
      |> assign(:addresses, @default_addresses)
      |> refresh_utxos()
      |> create_changeset()
    }
  end

  @impl true
  def handle_event("spend", %{"utxo" => encoded_utxo}, socket) do
    utxo = Encoder.decode(encoded_utxo)

    socket =
      case Send.from_utxo(utxo, @destination_address, @default_fee) do
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
      |> calculate_amount()
    }
  end

  # @impl true
  # def handle_event("validate", %{"send_bitcoin" => send_bitcoin}, socket) do
  #   changeset =
  #     Changesets.SendBitcoin.validate(send_bitcoin)
  #     |> IO.inspect(label: "changeset validatin")

  #   {
  #     :noreply,
  #     socket
  #     |> assign(:changeset, changeset)
  #   }
  # end

  @impl true
  def handle_event("send", _data, socket) do
    socket =
      with {:ok, _} <- validate_addresses(socket),
           {:ok, _} <- validate_utxos(socket) do
        socket
        |> send_bitcoin(socket.assigns.amount)
      else
        {:error, message} -> socket |> put_flash(:error, message)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("utxo_selected", data, socket) do
    utxo =
      data
      |> Map.get("utxo")
      |> Encoder.decode()

    {
      :noreply,
      socket
      |> toggle_utxo_selection(utxo.transaction_id, utxo.vxid)
      |> calculate_balance()
      |> calculate_selected()
      |> calculate_amount()
    }
  end

  # @impl true
  # def handle_event("send", %{"send_bitcoin" => send_bitcoin}, socket) do
  #   socket =
  #     case Changesets.SendBitcoin.validate(send_bitcoin) do
  #       %Ecto.Changeset{valid?: true, changes: %{amount: amount}} ->
  #         send_bitcoin(socket, amount, @destination_address)

  #       %Ecto.Changeset{valid?: false, errors: errors} ->
  #         socket |> put_flash(:error, "changeset: #{inspect(errors)}")
  #     end

  #   {:noreply, socket}
  # end

  @impl true
  def handle_info({:address_updated, valid?, addresses}, socket) do
    {
      :noreply,
      socket
      |> assign(:addresses, {valid?, addresses})
    }
  end

  @impl true
  def handle_info(_message, socket) do
    {
      :noreply,
      socket
      |> get_utxos()
    }
  end

  defp validate_addresses(%{assigns: %{addresses: addresses}}), do: {:ok, addresses}

  defp validate_utxos(%{assigns: %{changeset: changeset, utxos: utxos}}) do
    case changeset.valid?() do
      true -> {:ok, utxos}
      false -> {:error, "utxos are missing"}
    end
  end

  defp send_bitcoin(%{assigns: %{addresses: addresses}} = socket, amount) do
    utxos = socket |> get_selected_utxos

    case utxos do
      [] ->
        socket |> put_flash(:error, "no utxo selected")

      _ ->
        case Send.from_utxo_list(utxos, addresses, amount) do
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
    |> calculate_amount()
  end

  defp create_changeset(socket) do
    changeset = Changesets.SendBitcoin.validate(%{})

    socket
    |> assign(:changeset, changeset)
  end

  # defp change_amount(socket, amount) do
  #   new_changeset =
  #     socket.assigns.changeset
  #     |> Ecto.Changeset.put_change(:amount, amount)

  #   socket
  #   |> assign(new_changeset)
  # end

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

  defp calculate_amount(socket) do
    amount = socket.assigns.selected - socket.assigns.fee

    socket
    |> assign(:amount, amount)
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
