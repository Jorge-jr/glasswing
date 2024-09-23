defmodule Glasswing.Mongo do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info("Connecting to MongoDB")
    {:ok, conn} = Mongo.start_link(url: "mongodb://localhost:27017/glasswing_dev")
    Logger.info("Connected to MongoDB")
    {:ok, conn}
  end

  def get_connection do
    GenServer.call(__MODULE__, :get_connection)
  end

  def find(collection, query) do
    Logger.info("Finding in collection #{collection} with query #{inspect(query)}")
    GenServer.call(__MODULE__, {:find, collection, query})
  end

  def insert_one(collection, document) do
    GenServer.call(__MODULE__, {:insert_one, collection, document})
  end

  def update_one(collection, filter, update, opts \\ []) do
    GenServer.call(__MODULE__, {:update_one, collection, filter, update, opts})
  end

  # GenServer callbacks

  def handle_call(:get_connection, _from, conn) do
    {:reply, conn, conn}
  end

  def handle_call({:find, collection, query}, _from, conn) do
    Logger.info("Executing find on MongoDB")
    result = Mongo.find(conn, collection, query) |> Enum.to_list()
    Logger.info("MongoDB find result: #{inspect(result)}")
    {:reply, result, conn}
  end

  def handle_call({:insert_one, collection, document}, _from, conn) do
    result = Mongo.insert_one(conn, collection, document)
    {:reply, result, conn}
  end

  def handle_call({:update_one, collection, filter, update, opts}, _from, conn) do
    result = Mongo.update_one(conn, collection, filter, update, opts)
    {:reply, result, conn}
  end
end
