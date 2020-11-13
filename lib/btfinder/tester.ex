defmodule BTFinder.Tester do
  def run(n) do
    1..n
    |> Enum.map(&Task.async(__MODULE__, :task, [&1, n]))
    |> Task.await_many()
  end

  def task(i, n) do
    task_value(i, :task_1, 1, 600, 700)
    task_value(i, :task_1, 2, 200, 400)
    task_value(i, :task_1, 3, 0, 20 * n)
    task_value(i, :task_2, 1, 200, 500)
    task_value(i, :task_2, 2, 100, 400)
  end

  defp task_value(id, type, meta, from, to) do
    start_ts = :erlang.system_time(:millisecond)
    sleep_time = :crypto.rand_uniform(from, to)
    :timer.sleep(sleep_time)
    BTFinder.log(id, type, meta, start_ts)
  end
end
