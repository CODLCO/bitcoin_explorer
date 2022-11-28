defmodule BitcoinExplorer.Transaction do
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output}
  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes.Data

  @doc """
  Validate a transaction by id

  ## Examples
    iex> "0437cd7f8525ceed2324359c2d0ba26006d92d856a9c20fa0241106ee5a597c9"
    ...> |> BitcoinExplorer.Transaction.validate()
    true
  """
  @spec validate(binary()) :: {:ok, boolean()} | {:error, binary()}
  def validate(txid) when is_binary(txid) do
    with {:ok, transaction, <<>>} <- get_transaction(txid) do
      {
        :ok,
        transaction
        |> validate_inputs()
      }
    else
      {:error, message} ->
        {:error, message}
    end
  end

  def validate_inputs(%Transaction{inputs: inputs} = transaction) do
    inputs
    |> Enum.map(&validate_input(transaction, &1))
  end

  def validate_input(
        %Transaction{} = transaction,
        %Input{txid: txid, vout: vout, script_sig: script_sig = script}
      ) do
    {_, _CURVY_MESSAGE} =
      Script.encode(script) |> IO.inspect(base: :hex, label: "THE MESSAGE FOR CURVY")

    with {:ok, %Output{} = output} <- get_utxo(txid, vout) do
      # IO.puts("txid: #{txid}")
      # IO.puts("vout: #{vout}")
      # IO.inspect(output.script_pub_key, label: "script pub key")

      ## got to test this... doesn't seem that efficient, though
      # message =
      #   transaction_hex_without_script_sig
      #   |> append_sighash(1)
      #   |> Crypto.double_sha256()

      #      Script.execute(output.script_pub_key, [signature])
      Script.execute(output.script_pub_key, [script_sig]) |> IO.inspect()

      true
    else
      {:error, message} -> {:error, message}
    end
  end

  defp get_transaction(txid) do
    txid
    |> BitcoinCoreClient.get_transaction()
    |> BitcoinLib.Transaction.decode()
  end

  defp get_utxo(txid, vout) do
    with {:ok, transaction, <<>>} <- get_transaction(txid) do
      {
        :ok,
        transaction.outputs
        |> Enum.at(vout)
      }
    else
      {:error, message} -> {:error, message}
    end
  end
end
