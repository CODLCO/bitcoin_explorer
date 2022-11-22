defmodule BitcoinExplorerWeb.HomeLive do
  use BitcoinExplorerWeb, :live_view

  alias BitcoinExplorer.Block

  @impl true
  def mount(_params, _session, socket) do
    height = 0
    block = Block.get_by_height(height)

    {
      :ok,
      socket
      |> assign(:height, height)
      |> assign(:block, block)
    }
  end
end
