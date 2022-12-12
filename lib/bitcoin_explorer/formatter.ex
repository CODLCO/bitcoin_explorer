defmodule BitcoinExplorer.Formatter do
  def integer(integer) do
    integer
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(" ")
    |> String.reverse()
  end

  def datetime(datetime) do
    datetime
    |> DateTime.to_string()
  end
end
