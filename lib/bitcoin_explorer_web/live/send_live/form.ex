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
      |> validate(%{addresses: []})
      |> add_address("")
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full">
      <button phx-click="add" phx-target={@myself}>Add an address</button>
      <.form :let={f} as={:address_list} for={@changeset} phx-change="validate" phx-target={@myself}>
        <%= label(f, :addresses) %>
        <%= address_list(f, :addresses) %>
        <%= error_tag(f, :addresses) %>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"address_list" => %{"addresses" => addresses} = form}, socket) do
    %{assigns: %{changeset: changeset}} = validate(socket, form)

    send(self(), {:address_updated, changeset.valid?, addresses})

    {
      :noreply,
      socket
    }
  end

  @impl true
  def handle_event("add", _, socket) do
    addresses = socket.assigns.changeset.changes.addresses ++ [""]

    {
      :noreply,
      socket
      |> validate(%{addresses: addresses})
    }
  end

  defp validate(socket, form) do
    changeset = FormData.validate(form)

    socket
    |> assign(changeset: changeset)
  end

  defp add_address(socket, address) do
    addresses = socket.assigns.changeset.changes.addresses ++ [address]

    socket
    |> validate(%{addresses: addresses})
  end
end
