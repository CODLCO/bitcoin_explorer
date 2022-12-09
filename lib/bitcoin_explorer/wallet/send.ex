defmodule BitcoinExplorer.Wallet.Send do
  alias BitcoinLib.Transaction
  alias BitcoinLib.Script
  alias BitcoinLib.Address
  alias BitcoinLib.Key.{PrivateKey}

  ### design those structs: from (for input), to (for output)
  ### make sure tx and utxo amounts match
  def from_utxo(
        %{transaction_id: txid, vxid: vxid, change?: change?, index: index},
        %PrivateKey{} = xpub_private_key,
        destination_address
      ) do
    change_id = if change?, do: 1, else: 0

    private_key =
      xpub_private_key
      |> PrivateKey.derive_child!(change_id)
      |> PrivateKey.derive_child!(index)

    vout =
      txid
      |> BitcoinCoreClient.get_transaction()
      |> BitcoinLib.Transaction.decode()
      |> elem(1)
      |> Map.get(:outputs)
      |> Enum.at(vxid)
      |> IO.inspect(label: "original vout")

    script_pub_key =
      Script.encode(vout.script_pub_key)
      |> elem(1)
      |> Binary.to_hex()

    {:ok, destination_public_hash, _type, _network} = Address.destructure(destination_address)

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
end
