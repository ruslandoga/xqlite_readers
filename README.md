# SQLiteReaders

A pool for readonly SQLite3 connections.

### Usage

```elixir
readers =
  for _ <- 1..:erlang.system_info(:dirty_io_schedulers) do
    SQLiteNIFs.open("test.db", [:create, :readonly, :nomutex, :wal, :exrescode])
  end

{:ok, pool} = SQLiteReaders.start_link(readers)
[[1, "a"]] = SQLiteReaders.query!(pool, "select ?, ?", [1, "a"])
[[1, "a"]] = SQLiteReaders.query!(pool, "select :a, :b", %{":a" => 1, ":b" => "a"})
```
