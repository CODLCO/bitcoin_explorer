defmodule BitcoinExplorer.Encoder do
  def encode(value) do
    value
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end

  def decode(value) do
    value
    |> Base.decode64()
    |> elem(1)
    |> :erlang.binary_to_term()
  end
end
