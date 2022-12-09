defmodule BitcoinExplorer.Wallet do
  def get_utxos(xpub) do
    entries = BitcoinAccounting.get_book_entries(xpub)

    %{
      entries: (entries.receive ++ entries.change) |> add_sums
    }
  end

  defp add_sums(thing) do
    thing
    |> Enum.map(fn stuff ->
      credits =
        stuff.history
        |> Enum.map(fn yo ->
          yo.credits
          |> Enum.sum()
        end)
        |> Enum.sum()

      debits =
        stuff.history
        |> Enum.map(fn yo ->
          yo.debits
          |> Enum.sum()
        end)
        |> Enum.sum()

      stuff
      |> Map.put(:sum_credits, credits)
      |> Map.put(:sum_debits, debits)
    end)
  end
end
