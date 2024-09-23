defmodule Glasswing.PriceUpdater do
  use GenServer
  require Logger
  alias Glasswing.CoinGecko

  @update_interval :timer.minutes(15)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_update()
    {:ok, state}
  end

  def handle_info(:update, state) do
    Logger.info("Updating cryptocurrency prices")
    update_prices()
    schedule_update()
    {:noreply, state}
  end

  defp schedule_update do
    Process.send_after(self(), :update, @update_interval)
  end

  defp update_prices do
    coins = ["bitcoin", "ethereum", "dogecoin"]
    case CoinGecko.get_prices(coins) do
      {:ok, _prices} ->
        Logger.info("Prices updated successfully")
      {:error, reason} ->
        Logger.error("Failed to update prices: #{inspect(reason)}")
    end
  end
end
