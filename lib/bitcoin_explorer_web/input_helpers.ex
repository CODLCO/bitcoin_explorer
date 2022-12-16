defmodule BitcoinExplorerWeb.InputHelpers do
  use Phoenix.HTML

  alias Phoenix.HTML.Form

  import Form

  def address_input(form, field, input_opts \\ [], data \\ []) do
    type = input_type(form, field)
    name = input_name(form, field)

    opts =
      input_opts
      |> Keyword.put_new(:name, name)
      |> Keyword.put_new(:autocomplete, "off")
      |> Keyword.put_new(:class, "w-[26rem] mr-2")

    content_tag :span do
      [
        apply(Form, type, [form, field, opts]),
        link("remove", to: "#", data: data, title: "remove", class: "")
      ]
    end
  end
end
