defmodule BitcoinExplorer.Wallet.Send do
  alias BitcoinExplorer.Environment
  alias BitcoinLib.Transaction
  alias BitcoinLib.Script
  alias BitcoinLib.Address
  alias BitcoinLib.Key.{PrivateKey}

  ### design those structs: from (for input), to (for output)
  ### make sure tx and utxo amounts match
  def from_utxo(
        %{transaction_id: txid, vxid: vxid, change?: change?, index: index},
        destination_address
      ) do
    private_key = get_private_key(change?, index)
    vout = get_vout(txid, vxid)
    script_pub_key = get_script_pub_key(vout)
    destination_public_hash = get_destination_public_hash(destination_address)

    original_amount = vout.value
    fee = 500
    destination_amount = original_amount - fee

    %Transaction.Spec{}
    |> Transaction.Spec.add_input!(
      txid: txid,
      vout: vxid,
      redeem_script: script_pub_key
    )
    |> Transaction.Spec.add_output(
      destination_public_hash
      |> Script.Types.P2pkh.create(),
      destination_amount
    )
    |> Transaction.Spec.sign_and_encode(private_key)
    |> IO.inspect()
  end

  defp get_private_key(change?, index) do
    seed_phrase = Environment.seed_phrase()
    xpub_derivation_path = Environment.xpub_derivation_path()

    change_id = if change?, do: 1, else: 0

    PrivateKey.from_seed_phrase(seed_phrase)
    |> PrivateKey.from_derivation_path!(xpub_derivation_path)
    |> PrivateKey.derive_child!(change_id)
    |> PrivateKey.derive_child!(index)
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
