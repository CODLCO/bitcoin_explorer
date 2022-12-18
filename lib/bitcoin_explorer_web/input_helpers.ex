defmodule BitcoinExplorerWeb.InputHelpers do
  @moduledoc """
  Based on the learnings from:
    Form inputs for lists as array ecto types in Phoenix https://www.youtube.com/watch?v=kg7q7O4RmQQ

  Next thing to learn:
    Very customized form helpers https://www.youtube.com/watch?v=2Zr9bvphA2o&t=4s
  """
  use Phoenix.HTML

  alias Phoenix.HTML.Form

  import Form

  def address_list(form, field) do
    id = input_id(form, field) <> "_list"
    values = input_value(form, field) || [""]

    content_tag :ol, id: id, class: "" do
      for {value, index} <- Enum.with_index(values) do
        input_opts = [value: value, id: nil]
        address_input(form, field, input_opts, index: index)
      end
    end
  end

  def address_input(form, field, input_opts \\ [], data \\ []) do
    type = input_type(form, field)
    name = input_name(form, field) <> "[]"

    opts =
      input_opts
      |> Keyword.put_new(:name, name)
      |> Keyword.put_new(:autocomplete, "off")
      |> Keyword.put_new(:class, "w-[26rem] mr-2")

    content_tag :li do
      [
        apply(Form, type, [form, field, opts])
        #     link("remove", to: "#", data: data, title: "remove", class: "")
      ]
    end
  end
end
