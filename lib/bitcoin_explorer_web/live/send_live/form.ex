defmodule BitcoinExplorerWeb.SendLive.Form do
  use BitcoinExplorerWeb, :live_component

  # Schemaless Changesets
  # https://www.youtube.com/watch?v=VzOyLlctkQM&t=935s

  # A Reusable Multi-Select Component for Phoenix LiveView
  # https://fly.io/phoenix-files/liveview-multi-select/

  alias BitcoinExplorerWeb.SendLive.FormData

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> validate(%{})
      |> assign(:form_data, %{address: ""})
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full">
      <.form :let={f} as={:address} for={@changeset} phx-change="validate" phx-target={@myself}>
        <%= label(f, :address) %>
        <%= text_input(f, :address, class: "w-[26rem]", autocomplete: "off") %>
        <%= error_tag(f, :address) %>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"address" => %{"address" => address} = form}, socket) do
    %{assigns: %{changeset: changeset}} = validate(socket, form)

    send(self(), {:address_updated, changeset.valid?, address})

    {
      :noreply,
      socket
    }
  end

  defp validate(socket, form) do
    changeset = FormData.validate(form)

    socket
    |> assign(changeset: changeset)
  end

  defp get_address(%{assigns: %{changeset: changeset}} = socket) do
    changeset.changes.address
  end
end
