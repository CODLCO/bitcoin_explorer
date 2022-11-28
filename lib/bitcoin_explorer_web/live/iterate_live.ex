defmodule BitcoinExplorerWeb.IterateLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Block

  @start 764_800
  @size 200

  @impl true
  def mount(_params, _session, socket) do
    initial_height = @start

    send(self(), {:get_block, initial_height})

    {:ok,
     socket
     |> assign(:height, initial_height)
     |> assign(:time, "")}
  end

  @impl true
  def handle_info({:get_block, height}, socket) when height > @start + @size do
    {:noreply, socket}
  end

  def handle_info({:get_block, height}, socket) do
    case Block.get_by_height(height) do
      {:ok, block} ->
        send(self(), {:get_block, height + 1})

        {:noreply,
         socket
         |> assign(:height, height)
         |> assign(:time, DateTime.to_string(block.header.time))}

      {:error, message} ->
        IO.puts(message)
        {:noreply, socket}
    end
  end
end
