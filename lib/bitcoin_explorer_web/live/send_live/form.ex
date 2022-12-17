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
      |> add_address("mgJ6YsnKxbDvR2aiwFreu2hEgyR7bxcwrr")
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

  @impl true
  def handle_event("remove_address", %{"index" => index}, socket) do
    IO.inspect(index, label: "remove address from form")

    {
      :noreply,
      socket
      #      |> remove_address_at(index)
    }
  end

  defp validate(socket, form) do
    changeset = FormData.validate(form)

    socket
    |> assign(changeset: changeset)
  end

  defp get_addresses(socket) do
    socket.assigns.changeset.changes.addresses
  end

  defp add_address(socket, address) do
    addresses = get_addresses(socket) ++ [address]

    socket
    |> validate(%{addresses: addresses})
    |> assign(addresses: addresses)
  end
end
