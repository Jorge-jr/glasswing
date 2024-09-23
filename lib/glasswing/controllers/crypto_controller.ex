defmodule GlasswingWeb.CryptoController do
  use GlasswingWeb, :controller

  def prices(conn, %{"ids" => ids}) do
    case Glasswing.CoinGecko.get_prices(String.split(ids, ",")) do
      {:ok, prices} -> json(conn, prices)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def coin_details(conn, %{"id" => id}) do
    case Glasswing.CoinGecko.get_coin_details(id) do
      {:ok, details} -> json(conn, details)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def market_chart(conn, %{"id" => id, "vs_currency" => vs_currency, "days" => days}) do
    case Glasswing.CoinGecko.get_market_chart(id, vs_currency, days) do
      {:ok, chart} -> json(conn, chart)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def trending_coins(conn, _params) do
    case Glasswing.CoinGecko.get_trending_coins() do
      {:ok, coins} -> json(conn, coins)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def global_data(conn, _params) do
    case Glasswing.CoinGecko.get_global_data() do
      {:ok, data} -> json(conn, data)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def exchanges_list(conn, _params) do
    case Glasswing.CoinGecko.get_exchanges_list() do
      {:ok, exchanges} -> json(conn, exchanges)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def exchange_rates(conn, _params) do
    case Glasswing.CoinGecko.get_exchange_rates() do
      {:ok, rates} -> json(conn, rates)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def search_coins(conn, %{"query" => query}) do
    case Glasswing.CoinGecko.search_coins(query) do
      {:ok, results} -> json(conn, results)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end

  def coin_market_data(conn, %{"ids" => ids, "vs_currency" => vs_currency}) do
    case Glasswing.CoinGecko.get_coin_market_data(String.split(ids, ","), vs_currency) do
      {:ok, data} -> json(conn, data)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end
end
