# XQLite.Readers

A pool for readonly SQLite3 connections.

### Usage

```elixur
readers =
  for _ <- 1..:erlang.system_info(:dirty_io_schedulers) do
    reader = XQLite.open("test.db", [:create, :readonly, :nomutex, :wal])
    :ok = XQLite.execute(reader, "pragma foreign_keys=on")
    reader
  end

{:ok, pool} = GenServer.start_link(XQLite.Readers, readers: readers)

[[1, "a"]] = XQLite.Readers.query(pool, "select ?, ?", [1, "a"])

GenServer.stop(pool)
```
