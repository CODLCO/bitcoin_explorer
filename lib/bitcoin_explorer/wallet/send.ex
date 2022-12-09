defmodule BitcoinExplorer.Wallet.Send do
  def from_utxo(utxo) do
    IO.puts("SPEND from Wallet.Send")
    IO.inspect(utxo)
  end
end
