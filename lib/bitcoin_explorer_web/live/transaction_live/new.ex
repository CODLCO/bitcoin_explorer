defmodule BitcoinExplorerWeb.TransactionLive.New do
  use BitcoinExplorerWeb, :live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:hero, "new transaction")
    }
  end
end
