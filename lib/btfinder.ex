defmodule BTFinder do
  @moduledoc """
  Documentation for `BTFinder`.
  """

  alias BTFinder.Cache
  import Ex2ms

  @doc """
  """
  def log_time(id, type, meta, time) do
    Cache.put({:entry, id, type, meta}, time)
  end

  @doc """
  Log event for start time
  """
  def log(id, type, meta, start_ts) do
    log_time(id, type, meta, :erlang.system_time(:millisecond) - start_ts)
  end

  @entry_select (fun do
                   {{:entry, _, _, _}, _} = entry -> entry
                 end)

  @entry_select_delete (fun do
                          {{:entry, _, _, _}, _} -> true
                        end)
  @doc """
  Calculate run
  """
  def calculate() do
    result =
      for {key, values} <- Cache.fold_over_select(@entry_select, %{}, &calc_elem/2),
          into: %{} do
        {key, Enum.sum(values) / Enum.count(values)}
      end

    if map_size(result) > 0, do: Cache.put({:result, :erlang.universaltime()}, result)
    Cache.select_delete(@entry_select_delete)
  end

  defp calc_elem({{:entry, id, type, meta}, time}, acc) do
    acc
    |> update_in([{type, meta}], &[time | &1 || []])
    |> update_in([type], &[time | &1 || []])
    |> update_in([id], &[time | &1 || []])
  end

  @doc """
  Check for bottlenecks
  """
  def check(result1, result2) do
    {_key1, values1} = Cache.get(result1)
    {_key2, values2} = Cache.get(result2)
    compare(values1, values2)
  end

  defp compare(values1, values2) do
    values1
    |> Map.to_list()
    |> Enum.flat_map(fn {key, time1} ->
      case Map.get(values2, key) do
        nil ->
          []

        time2 ->
          diff_factor = if time1 > time2, do: time1 / safe(time2), else: time2 / safe(time1)
          [{key, diff_factor}]
      end
    end)
    |> Enum.sort_by(&elem(&1, 1), &>=/2)
  end

  defp safe(value) when value == 0, do: 1
  defp safe(value), do: value

  @result_select (fun do
                    {{:result, time}, _} = entry -> {:result, time}
                  end)
  def list() do
    Cache.select(@result_select)
  end
end
