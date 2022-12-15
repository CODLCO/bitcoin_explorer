defmodule BitcoinExplorer.Changesets.SendBitcoin do
  @default_destination_address "myKgsxuFQQvYkVjqUfXJSzoqYcywsCA4VS"

  defstruct address: @default_destination_address

  import Ecto.Changeset

  alias BitcoinExplorer.Changesets.SendBitcoin
  alias BitcoinLib.Address

  # https://hexdocs.pm/ecto/Ecto.Schema.html#module-primitive-types
  @types %{address: :binary}

  def validate(attrs) do
    {%SendBitcoin{}, @types}
    |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    |> validate_address(:address)
    |> Ecto.Changeset.validate_required([:address])
  end

  defp validate_address(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      # case Address.destructure(value) do
      #   {:ok, _data, _script_type, _network} ->
      #     []

      #   {:error, message} ->
      #     IO.inspect(message)
      #     [{field, message}]
      # end
      [yo: "une erreur est survenue"]
    end)
  end
end
