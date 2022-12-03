defmodule BitcoinExplorerWeb.TransactionLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Transaction

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    with {:ok, transaction} <- Transaction.get(id) do
      {:ok, socket |> assign(:transaction, transaction)}
    else
      {:error, message} -> {:ok, socket |> assign(:error, message)}
    end
  end
end
