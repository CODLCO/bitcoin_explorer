defmodule BitcoinExplorerWeb.WalletLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinLib.PrivateKey

  @impl true
  def mount(%{}, _session, socket) do
    [mnemonic_phrase: _, tpub: tpub] = Application.get_env(:bitcoin_explorer, :bitcoin)

    {
      :ok,
      socket
      |> assign(:book_entries, get_entries(tpub))
      |> assign(:hero, "The wallet")
    }
  end

  defp get_entries(tpub) do
    entries = BitcoinAccounting.get_book_entries(tpub)

    %{
      receive: entries.receive |> add_sums,
      change: entries.change |> add_sums
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
