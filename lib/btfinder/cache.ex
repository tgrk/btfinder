defmodule BTFinder.Cache do
  @moduledoc """
  Local cache implementation
  """

  use GenServer

  @table __MODULE__
  @batch_size 1000

  @doc false
  def child_spec(_opts) do
    Supervisor.child_spec(%{id: __MODULE__, start: {__MODULE__, :start_link, []}}, [])
  end

  @doc false
  def start_link(), do: GenServer.start_link(__MODULE__, [], [])

  @doc false
  def init(_) do
    opts = [
      {:read_concurrency, true},
      {:write_concurrency, true},
      :public,
      :duplicate_bag,
      :named_table
    ]

    table = :ets.new(@table, opts)
    {:ok, table}
  end

  @doc """
  Put
  """
  def put(key, value), do: :ets.insert(@table, {key, value})

  def get(key) do
    case :ets.lookup(@table, key) do
      [] -> nil
      list -> unwrap(list)
    end
  end

  defp unwrap([object]), do: object
  defp unwrap(list), do: list

  @doc """
  Delete
  """
  def delete(key), do: :ets.delete(@table, key)

  def fold_over_select(spec, acc, fun) do
    do_fold_over_select({:init, spec, @batch_size}, acc, fun)
  end

  defp do_fold_over_select(continuation, acc, fun) do
    case do_select(continuation) do
      {matches, new_continuation} ->
        new_acc = Enum.reduce(matches, acc, fun)
        do_fold_over_select(new_continuation, new_acc, fun)

      :"$end_of_table" ->
        acc
    end
  end

  defp do_select({:init, spec, limit}), do: select(spec, limit)
  defp do_select(continuation), do: select_continue(continuation)

  # ETS mappings
  def delete_all_objects(), do: :ets.delete_all_objects(@table)

  def fold(acc, fun), do: :ets.foldl(fun, acc, @table)

  def tab2list(), do: :ets.tab2list(@table)

  def select_delete(spec), do: :ets.select_delete(@table, spec)

  def select(spec), do: :ets.select(@table, spec)

  def select(spec, limit), do: :ets.select(@table, spec, limit)

  def select_continue(continuation), do: :ets.select(continuation)
end
