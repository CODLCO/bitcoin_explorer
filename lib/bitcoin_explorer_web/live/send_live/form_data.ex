defmodule BitcoinExplorerWeb.SendLive.FormData do
  import Ecto.Changeset

  alias BitcoinLib.Address

  @types %{address: :string}

  def validate(params) do
    {%{}, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required([:address])
    |> validate_address(:address)
    |> Map.put(:action, :validate)
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
