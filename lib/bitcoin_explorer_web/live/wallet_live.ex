defmodule BitcoinExplorerWeb.WalletLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Wallet

  @impl true
  def mount(%{}, _session, socket) do
    [mnemonic_phrase: _, tpub: tpub] = Application.get_env(:bitcoin_explorer, :bitcoin)

    {
      :ok,
      socket
      |> assign(:book_entries, Wallet.get_utxos(tpub))
      |> assign(:hero, "The wallet")
    }
  end
end
