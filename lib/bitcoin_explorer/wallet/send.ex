defmodule BitcoinExplorer.Wallet.Send do
  alias BitcoinExplorer.Environment
  alias BitcoinLib.Transaction
  alias BitcoinLib.Script
  alias BitcoinLib.Address
  alias BitcoinLib.Key.{PrivateKey}

  def from_utxo_list(utxos, [destination_address], destination_amount) do
    spec =
      %Transaction.Spec{}
      |> add_inputs(utxos)

    with {:ok, private_keys} <- get_private_keys(utxos),
         {:ok, signed_transaction} <-
           spec
           |> add_output(destination_address, destination_amount)
           |> Transaction.Spec.sign_and_encode(private_keys) do
      signed_transaction
      |> ElectrumClient.broadcast_transaction()
    else
      {:error, message} -> {:error, message}
    end
  end

  def from_utxo(utxo, address, fee) do
    [utxo]
    |> from_utxo_list(address, fee)
  end

  defp add_inputs(spec, utxos) do
    utxos
    |> Enum.reduce(spec, fn utxo, spec ->
      add_input(spec, utxo)
    end)
  end

  defp add_input(spec, %{transaction_id: txid, vxid: vxid} = _utxo) do
    vout = get_vout(txid, vxid)

    script_pub_key = get_script_pub_key(vout)

    spec
    |> Transaction.Spec.add_input!(
      txid: txid,
      vout: vxid,
      redeem_script: script_pub_key
    )
  end

  defp add_output(spec, address, amount) do
    public_key_hash = get_destination_public_hash(address)

    spec
    |> Transaction.Spec.add_output(
      public_key_hash
      |> Script.Types.P2pkh.create(),
      amount
    )
  end

  defp get_private_keys(utxos) do
    utxos
    |> Enum.map(fn %{change?: change?, index: index} ->
      get_private_key(change?, index)
    end)
    |> validate_private_keys()
  end

  defp validate_private_keys(private_key_results) do
    error_messages =
      private_key_results
      |> Enum.reduce([], fn result, error_messages ->
        case result do
          {:error, message} -> [message | error_messages]
          _ -> error_messages
        end
      end)

    case Enum.any?(error_messages) do
      true -> {:error, Enum.join(error_messages)}
      false -> {:ok, private_key_results |> Enum.map(fn {:ok, private_key} -> private_key end)}
    end
  end

  defp get_private_key(change?, index) do
    seed_phrase = Environment.seed_phrase()
    xpub_derivation_path = Environment.xpub_derivation_path()

    change_id = if change?, do: 1, else: 0

    private_key = PrivateKey.from_seed_phrase(seed_phrase)

    with {:ok, private_key} <- PrivateKey.from_derivation_path(private_key, xpub_derivation_path),
         {:ok, private_key} <- PrivateKey.derive_child(private_key, change_id),
         {:ok, private_key} <- PrivateKey.derive_child(private_key, index) do
      {:ok, private_key}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp get_vout(txid, vxid) do
    txid
    |> BitcoinCoreClient.get_transaction()
    |> BitcoinLib.Transaction.decode()
    |> elem(1)
    |> Map.get(:outputs)
    |> Enum.at(vxid)
  end

  defp get_script_pub_key(vout) do
    Script.encode(vout.script_pub_key)
    |> elem(1)
    |> Binary.to_hex()
  end

  defp get_destination_public_hash(destination_address) do
    {:ok, destination_public_hash, _type, _network} = Address.destructure(destination_address)

    destination_public_hash
  end
end
