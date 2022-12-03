defmodule BitcoinExplorerWeb.WalletLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  @impl true
  def mount(%{}, _session, socket) do
    [tpub: tpub] = Application.get_env(:bitcoin_explorer, :bitcoin)

    {
      :ok,
      socket
      |> assign(:book_entries, BitcoinAccounting.get_book_entries(tpub))
      |> assign(:hero, "The wallet")
    }
  end
end
