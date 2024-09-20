# XQLite.Readers

A pool for readonly SQLite3 connections.

### Usage

```elixir
readers =
  for _ <- 1..:erlang.system_info(:dirty_io_schedulers) do
    XQLite.open("test.db", [:create, :readonly, :nomutex, :wal])
  end

{:ok, pool} = GenServer.start_link(XQLite.Readers, readers)
[[1, "a"]] = XQLite.Readers.query(pool, "select ?, ?", [1, "a"])

GenServer.stop(pool)
```
