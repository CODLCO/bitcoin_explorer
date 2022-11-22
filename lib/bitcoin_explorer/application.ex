defmodule BitcoinExplorer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias BitcoinCoreClient.Rpc

  @impl true
  def start(_type, _args) do
    bitcoin_core_rpc_settings = %Rpc.Settings{
      username: "electrum",
      password: "Rh_KUrE42MtGtUqhtjc",
      ip: "electrum",
      port: 8332
    }

    children = [
      # Start the Ecto repository
      BitcoinExplorer.Repo,
      # Start the Telemetry supervisor
      BitcoinExplorerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BitcoinExplorer.PubSub},
      # Start the Endpoint (http/https)
      BitcoinExplorerWeb.Endpoint,
      # Start a worker by calling: BitcoinExplorer.Worker.start_link(arg)
      # {BitcoinExplorer.Worker, arg}
      %{
        id: BitcoinCoreClient,
        start: {BitcoinCoreClient, :start_link, [bitcoin_core_rpc_settings]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BitcoinExplorer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BitcoinExplorerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
