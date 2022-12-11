defmodule BitcoinExplorer.Environment do
  alias BitcoinLib.Key.HD.DerivationPath
  alias BitcoinExplorer.Environment

  alias BitcoinLib.Key.{PrivateKey, PublicKey}

  def seed_phrase do
    Application.get_env(:bitcoin_explorer, :bitcoin)
    |> Keyword.get(:seed_phrase)
  end

  def xpub_derivation_path do
    {:ok, derivation_path} =
      Application.get_env(:bitcoin_explorer, :bitcoin)
      |> Keyword.get(:xpub_derivation_path)
      |> DerivationPath.parse()

    derivation_path
  end

  def xpub do
    seed_phrase = Environment.seed_phrase()
    derivation_path = Environment.xpub_derivation_path()

    seed_phrase
    |> PrivateKey.from_seed_phrase()
    |> PrivateKey.from_derivation_path!(derivation_path)
    |> PublicKey.from_private_key()
    |> PublicKey.serialize!(derivation_path.network)
  end
end
