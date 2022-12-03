defmodule BitcoinExplorerWeb.TransactionLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, socket |> assign(:id, id)}
  end
end
