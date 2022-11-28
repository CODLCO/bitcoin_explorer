defmodule BitcoinExplorer.Block do
  alias BitcoinLib.Block

  def get_by_height(block_height) do
    BitcoinCoreClient.get_block_by_height(block_height)
    |> Block.decode()
  end

  def get_first_transaction do
    get_first_transaction(0)
  end

  defp get_first_transaction(block_height) do
    {:ok, block} =
      block_height
      |> BitcoinCoreClient.get_block_by_height()
      |> Block.decode()

    case Enum.count(block.transactions) do
      1 ->
        get_first_transaction(block_height + 1)

      _ ->
        [_coinbase, first_transaction] ++ _ = block.transactions
        first_transaction
    end
  end
end
