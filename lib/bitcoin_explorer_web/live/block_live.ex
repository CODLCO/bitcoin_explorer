defmodule BitcoinExplorerWeb.BlockLive do
  use BitcoinExplorerWeb, :live_view

  alias BitcoinExplorer.Block

  @impl true
  def mount(%{"height" => height_string}, _session, socket) do
    {height, _remainder} = Integer.parse(height_string)

    case Block.get_by_height(height) do
      {:ok, block} ->
        {
          :ok,
          socket
          |> assign(:height, height)
          |> assign(:block, block)
        }

      {:error, message} ->
        {
          :ok,
          socket
          |> assign(:height, height)
          |> assign(:block, nil)
          |> assign(:message, message)
        }
    end
  end
end
