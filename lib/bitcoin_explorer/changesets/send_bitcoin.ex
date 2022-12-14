defmodule BitcoinExplorer.Changesets.SendBitcoin do
  defstruct amount: 0

  alias BitcoinExplorer.Changesets.SendBitcoin

  # https://hexdocs.pm/ecto/Ecto.Schema.html#module-primitive-types
  @types %{amount: :integer}

  def validate(attrs) do
    {%SendBitcoin{}, @types}
    |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    |> Ecto.Changeset.validate_number(:amount, greater_than: 0)
    |> Ecto.Changeset.validate_required([:amount])
  end
end
