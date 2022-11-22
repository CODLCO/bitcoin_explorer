defmodule BitcoinExplorer.Repo do
  use Ecto.Repo,
    otp_app: :bitcoin_explorer,
    adapter: Ecto.Adapters.SQLite3
end
