defmodule BitcoinExplorer.Block do
  alias BitcoinLib.Block

  def get_by_height(block_height) do
    BitcoinCoreClient.get_block_by_height(block_height)
    |> Block.decode()
  end
end
