defmodule Glasswing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GlasswingWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:glasswing, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Glasswing.PubSub},
      {Finch, name: Glasswing.Finch},
      Glasswing.Mongo,
      GlasswingWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Glasswing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GlasswingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
