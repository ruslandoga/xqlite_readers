defmodule XQLite.Readers do
  @moduledoc "A readonly pool for SQLite3 connections"
  use GenServer

  @type option :: {:readers, [XQLite.db()]} | GenServer.option()
  @typep state :: %{queue: :queue.queue(), readers: [{XQLite.db(), :ets.tab()}]}

  @spec query(GenServer.name(), binary, [XQLite.value()]) :: [row]
  def query(pool, sql, params \\ []) do
    {ref, reader, stmts} = GenServer.call(pool, :out, :infinity)

    try do
      stmt =
        case :ets.lookup(stmts, sql) do
          [{_sql, stmt}] ->
            stmt

          [] ->
            stmt = XQLite.prepare(reader, sql, [:persistent])
            :ets.insert(stmts, {sql, stmt})
            stmt
        end

      :ok = XQLite.unsafe_bind_all(reader, stmt, params)
      XQLite.fetch_all(reader, stmt)
    after
      GenServer.cast(pool, {:in, ref})
    end
  end

  @impl true
  @spec init([option]) :: {:ok, state}
  def init(pool_opts) do
    readers = Keyword.fetch!(pool_opts, :readers)

    readers =
      Enum.map(readers, fn reader ->
        {reader, _stmts = :ets.new(:xqlite_readers, [:public])}
      end)

    {:ok, %{queue: :queue.new(), readers: readers}}
  end

  @impl true
  def handle_call(:out, from, state) do
  end

  @impl true
  def handle_cast({:in, ref}, state) do
  end

  @impl true
  def handle_terminate(reason, state) do
    # TODO wait for current callers
    #      or interrupt

    Enum.each(state.readers, fn {reader, stmts} ->
      Enum.each(:ets.tab2list(stmts), fn {_sql, stmt} -> XQLite.finalize(stmt) end)
      :ets.delete(stmts)
      XQLite.close(reader)
    end)

    {:noreply, reason, state}
  end
end
