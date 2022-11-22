defmodule BitcoinExplorerWeb.BlockLive do
  use BitcoinExplorerWeb, :live_view

  alias BitcoinExplorer.Block

  @impl true
  def mount(%{"height" => height_string}, _session, socket) do
    {height, _remainder} = Integer.parse(height_string)
    {:ok, block} = Block.get_by_height(height)

    {
      :ok,
      socket
      |> assign(:height, height)
      |> assign(:block, block)
    }
  end
end
