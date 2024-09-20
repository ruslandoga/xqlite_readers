defmodule XQLite.ReadersTest do
  use ExUnit.Case, async: true

  describe "start_link" do
    test "accepts readonly databases" do
      assert {:ok, _pool} =
               XQLite.Readers.start_link(readers: [XQLite.open(":memory:", [:readonly])])
    end
  end

  describe "query" do
    setup do
      pool = start_supervised!({XQLite, readers: [XQLite.open(":memory:", [:readonly])]})
      {:ok, pool: pool}
    end

    test "reuses prepared statements", %{pool: pool} do
      assert [[1]] = XQLite.Readers.query(pool, "select ?", [1])
      assert [["a"]] = XQLite.Readers.query(pool, "select ?", ["a"])

      assert %{readers: [{_db, stmts}]} = :sys.get_state(pool)
      assert [{"select ?", _stmt}] = :ets.tab2list(stmts)
    end
  end
end
