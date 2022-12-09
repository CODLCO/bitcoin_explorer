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
      |> assign(:format_integer, &format_integer/1)
    }
  end

  defp get_utxos xpub do
    xpub
    |> BitcoinAccounting.get_utxos()
    |> Enum.map(& elem(&1, 1))
    |> Enum.concat()
    |> Enum.sort(fn %{value: value1}, %{value: value2} -> value1 > value2 end)
  end

  defp format_integer integer do
    integer
    |> Integer.to_char_list
    |> Enum.reverse
    |> Enum.chunk_every(3)
    |> Enum.join(" ")
    |> String.reverse
  end
end
