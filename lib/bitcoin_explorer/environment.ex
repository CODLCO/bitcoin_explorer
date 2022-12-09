defmodule BitcoinExplorer.Environment do
  alias BitcoinLib.Key.HD.DerivationPath

  def seed_phrase do
    Application.get_env(:bitcoin_explorer, :bitcoin)
    |> Keyword.get(:seed_phrase)
  end

  def derivation_path do
    {:ok, derivation_path} =
      Application.get_env(:bitcoin_explorer, :bitcoin)
      |> Keyword.get(:derivation_path)
      |> DerivationPath.parse()

    derivation_path
  end

  def xpub do
    Application.get_env(:bitcoin_explorer, :bitcoin)
    |> Keyword.get(:xpub)
  end
end
