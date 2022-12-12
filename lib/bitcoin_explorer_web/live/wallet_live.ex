defmodule BitcoinExplorerWeb.WalletLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Wallet
  alias BitcoinExplorer.Environment

  @impl true
  def mount(%{}, _session, socket) do
    {
      :ok,
      socket
      |> assign(:book_entries, Wallet.get_utxos(Environment.xpub()))
      |> assign(:hero, "The wallet")
    }
  end
end
