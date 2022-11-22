defmodule BitcoinExplorerWeb.HomeLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Block

  @start 30000
  @size 10000

  @impl true
  def mount(_params, _session, socket) do
    initial_height = @start

    send(self(), {:get_block, initial_height})

    {:ok,
     socket
     |> assign(:height, initial_height)
     |> assign(:previous_block_hash, "")}
  end

  def handle_info({:get_block, height}, socket) when height > @start + @size do
    {:noreply, socket}
  end

  def handle_info({:get_block, height}, socket) do
    block = Block.get_by_height(height)

    send(self(), {:get_block, height + 1})

    {:noreply,
     socket
     |> assign(:height, height)
     |> assign(:previous_block_hash, inspect(block.header.previous_block_hash))}
  end
end
