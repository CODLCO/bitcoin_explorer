defmodule BitcoinExplorer.TransactionTest do
  use ExUnit.Case, async: true

  import Mox

  alias BitcoinLib.Transaction

  # doctest BitcoinExplorer.Transaction

  @expecting_2_calls 2

  setup_all do
    defmock(BitcoinCoreClientMock, for: BitcoinCoreClient)

    %{}
  end

  test "validate testnet 838935b6bf2a16966fe261f23f28a88482f3b3d24c9847b68a56abe90d41ca97" do
    expect_bitcoin_core_client_get_transaction()

    txid = "838935b6bf2a16966fe261f23f28a88482f3b3d24c9847b68a56abe90d41ca97"

    is_valid = Transaction.Validator.verify(txid, &get_transaction/1)

    assert true == is_valid
  end

  defp get_transaction(txid), do: BitcoinExplorer.Transaction.get(txid, BitcoinCoreClientMock)

  defp expect_bitcoin_core_client_get_transaction() do
    expect(BitcoinCoreClientMock, :get_transaction, @expecting_2_calls, &raw_transaction(&1))
  end

  ## transaction to verify
  defp raw_transaction("838935b6bf2a16966fe261f23f28a88482f3b3d24c9847b68a56abe90d41ca97") do
    <<0x0100000001B62BA991789FB1739E6A17B3891FD94CFEBF09A61FEDB203D619932A4326C2E4000000006A4730440220032A1544F599BF29981851E826E8A6F7C036958BA3543CF9778A0756DFC425F6022067EEC131C0D73825633C0FDDCE1ABFB14BB26BC9E0D6E9D644A77361F74CB55C012103F0E5A53DB9F85E5B2EECF677925FFE21DD1409BCFE9A0730404053599B0901E5FFFFFFFF0110270000000000001976A914AFC3E518577316386188AF748A816CD14CE333F288AC00000000::1528>>
  end

  ## prevout
  defp raw_transaction("e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6") do
    <<0x02000000000101D77AB44D1E46782BA65AEC1CB2C0AD3F1E0573075C66ECD0F90B106D36CD66FD0000000000FEFFFFFF02B8911700000000001976A914AFC3E518577316386188AF748A816CD14CE333F288AC59E3C392010000001976A914E615D0C8ACB53105CF3F079B235EC7E890F06E8688AC02473044022036CFE28073798B93A34E3F823D4F0A35E034CFE1C1500FBD0BF8A48723C3FAD60220654C37F09BDCB95961EFA7E158C712658362D622392B62807CC5CC0DB239B6290121026827184211EF923576FBDB66912FA8E73DEF7287AED7F1BF6DA1C71341F4A47AC9C72300::1824>>
  end

  ######################################
  # Delete everything below this comment
  ######################################

  # def old_stuff(transaction_to_be_verified) do
  #   {:ok, transaction_to_be_verified} =
  #     "f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16"
  #     |> BitcoinExplorer.Transaction.get(BitcoinCoreClientMock)

  #   ### For each input, the following process has to be applied
  #   ### as they all have their own locking scripts and signatures
  #   ### to be verified

  #   prevouts = get_prevout_scripts(transaction_to_be_verified)

  #   Validator.verify(transaction_to_be_verified, prevout)

  #   preimage =
  #     transaction_to_be_verified
  #     #   |> Transaction.strip_signatures()
  #     |> Transaction.encode()
  #     |> append_sighash_type(sighash_type)
  #     |> print_hex("before SHA256")
  #     |> Crypto.double_sha256()

  #   IO.inspect(preimage, label: "PREIMAGE")

  #   executed_prevout_script = Script.execute(prevout, [signature])

  #   IO.inspect(executed_prevout_script)

  #   # encoded =
  #   #   transaction_to_be_verified
  #   #   |> Transaction.strip_signatures()
  #   #   #   |> IO.inspect(label: "STRIPPED TRANSACTION")
  #   #   |> Transaction.encode()

  #   # message =
  #   #   encoded
  #   #   |> IO.inspect(label: "before dsha", limit: :infinity)
  #   #   |> Crypto.double_sha256()
  #   #   |> IO.inspect(label: "the mssage")
  #   #   |> append_sighash_type(sighash_type)

  #   assert true
  # end

  # # SHOUD BE THIS: Script.execute(script_sig)
  # defp get_signature(%Input{script_sig: script_sig}) do
  #   {:ok, [signature]} = Script.execute(script_sig, [])

  #   der_signature_size = bit_size(signature) - @byte

  #   <<der_signature::bitstring-size(der_signature_size), sighash_type::@byte>> = signature

  #   %{der_signature: der_signature, sighash_type: sighash_type}
  # end

  # defp get_prevout_script(%Input{txid: txid, vout: vout}) do
  #   IO.inspect(txid, label: "previous TX")

  #   %Output{script_pub_key: prevout_script} =
  #     with {:ok, transaction} <- BitcoinExplorer.Transaction.get(txid, BitcoinCoreClientMock) do
  #       transaction.outputs
  #     end
  #     |> Enum.at(vout)

  #   prevout_script
  # end

  # defp append_sighash_type(data, sighash_type), do: <<data::bitstring, sighash_type::little-32>>

  # defp print_hex(bitstring, message) do
  #   bitstring
  #   |> Binary.to_hex()
  #   |> IO.inspect(label: message)

  #   bitstring
  # end
end
