defmodule BitcoinExplorerWeb.SendLive do
  use BitcoinExplorerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    [mnemonic_phrase: _, tpub: tpub] = Application.get_env(:bitcoin_explorer, :bitcoin)

    {
      :ok,
      socket
      |> assign(:hero, "Send coins")
      |> assign(:utxos, get_utxos(tpub))
    }
  end

  defp get_utxos xpub do
    xpub
    |> BitcoinAccounting.get_utxos()
    |> Enum.map(& elem(&1, 1))
    |> Enum.concat()
    |> Enum.sort(fn %{value: value1}, %{value: value2} -> value1 > value2 end)
  end

end
