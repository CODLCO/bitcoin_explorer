defmodule BitcoinExplorerWeb.SendLive.FormData do
  import Ecto.Changeset

  alias BitcoinLib.Address

  @types %{addresses: {:array, :string}}

  def validate(params) do
    {%{}, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required([:addresses])
    |> validate_addresses(:addresses)
    |> Map.put(:action, :validate)
  end

  defp validate_addresses(changeset, field) do
    IO.puts("YOUOY")

    validate_change(changeset, field, fn _, addresses ->
      IO.inspect(addresses)

      addresses
      |> Enum.with_index()
      |> IO.inspect()
      |> Enum.reduce([], fn {address, index}, acc ->
        case Address.destructure(address) do
          {:ok, _data, _script_type, _network} ->
            acc

          {:error, message} ->
            IO.inspect(message)
            [{field, message} | acc]
        end
      end)
    end)
  end

  defp validate_address(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      case Address.destructure(value) do
        {:ok, _data, _script_type, _network} ->
          []

        {:error, message} ->
          IO.inspect(message)
          [{field, message}]
      end
    end)
  end
end
