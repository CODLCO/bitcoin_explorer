defmodule BitcoinExplorer.Wallet.Send do
  alias BitcoinExplorer.Environment
  alias BitcoinLib.Transaction
  alias BitcoinLib.Script
  alias BitcoinLib.Address
  alias BitcoinLib.Key.{PrivateKey}

  ### design those structs: from (for input), to (for output)
  ### make sure tx and utxo amounts match
  def from_utxo_list(
        [%{transaction_id: txid, vxid: vxid, change?: change?, index: index} | _],
        destination_address,
        fee
      ) do
    with {:ok, private_key} <- get_private_key(change?, index) do
      vout = get_vout(txid, vxid)
      original_amount = vout.value

      destination_amount = original_amount - fee

      %Transaction.Spec{}
      |> add_input(txid, vxid, vout)
      |> add_output(destination_address, destination_amount)
      |> Transaction.Spec.sign_and_encode(private_key)
      |> ElectrumClient.broadcast_transaction()
    else
      {:error, message} -> {:error, message}
    end
  end

  def from_utxo(utxo, address, fee) do
    [utxo]
    |> from_utxo_list(address, fee)
  end

  defp add_input(spec, txid, vxid, vout) do
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
