defmodule BitcoinExplorer.Changesets.SendBitcoin do
  defstruct [:amount, :fee, :utxos]

  alias BitcoinExplorer.Changesets.SendBitcoin

  # https://hexdocs.pm/ecto/Ecto.Schema.html#module-primitive-types
  @types %{fee: :integer, amount: :integer}

  def validate(attrs) do
    {%SendBitcoin{}, @types}
    |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    |> Ecto.Changeset.validate_number(:amount, greater_than: 0)
    |> Ecto.Changeset.validate_number(:fee, greater_than: 0)
    |> Ecto.Changeset.validate_required([:amount, :fee])
  end
end
