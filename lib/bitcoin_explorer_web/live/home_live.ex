defmodule BitcoinExplorerWeb.HomeLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorerWeb.SendLive.AddAddressModal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
