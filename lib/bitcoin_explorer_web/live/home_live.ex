defmodule BitcoinExplorerWeb.HomeLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Block

  @impl true
  def mount(_params, _session, socket) do
    send(self(), {:get_first_transaction})

    {:ok,
     socket
     |> assign(:id, "is loading...")}
  end

  @impl true
  def handle_info({:get_first_transaction}, socket) do
    transaction = Block.get_first_transaction()

    {:noreply,
     socket
     |> assign(:id, transaction.id)}
  end
end
