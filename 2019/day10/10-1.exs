defmodule Day10Part1 do

  defp simplify({n, d}) do
    gcd = Integer.gcd(n, d)
    {div(n, gcd), div(d, gcd)}
  end

  defp line_slope({ax, _ay}, {bx, _by}) when ax == bx, do: :vertical
  defp line_slope({ax, ay}, {bx, by}), do: simplify({by-ay, bx-ax})

  @doc """
  Returns true if the point is the first or last in a set of collinear points
  """
  def is_extreme_point?(point, collinear) do
    sorted_points = [point | collinear] |> Enum.sort()
    cond do
      Enum.at(sorted_points, 0) == point -> true
      Enum.at(sorted_points, -1) == point -> true
      true -> false
    end
  end

  defp count_visible_in_line(_asteroid, []), do: 0
  defp count_visible_in_line(_asteroid, [_]), do: 1
  defp count_visible_in_line(asteroid, collinear) do
    if is_extreme_point?(asteroid, collinear), do: 1, else: 2
  end

  defp count_visible(asteroid, asteroid_visibility_map) do
    asteroid_visibility_map
    |> Enum.reduce(0, fn {_slope, collinear_asteroids}, total ->
      total + count_visible_in_line(asteroid, collinear_asteroids)
    end)
  end

  def main() do
    asteroids = for {line, i} <- Stream.with_index(IO.stream(:stdio, :line)) do
      chars = line
      |> String.trim()
      |> String.graphemes
      for {char, j} <- Stream.with_index(chars), char == "#" do
        {i, j}
      end
    end
    |> List.flatten()
    |> Enum.map(fn {r, c} -> {c, r} end)

    visibility_map = Map.new(asteroids, & {&1, %{}})
    asteroid_combinations = for a1 <- asteroids, a2 <- asteroids, do: {a1, a2}, into: []
    {best_asteroid, best_asteroid_vm} = asteroid_combinations
    |> Enum.reduce(visibility_map, fn
      {a, a}, vm -> vm
      {a, b}, vm -> update_in(vm, [a], fn m -> Map.update(m, line_slope(a, b), [b], &([b | &1])) end)
    end)
    |> Enum.max_by(fn {k, v} -> count_visible(k, v) end)

    IO.puts("Best asteroid: #{inspect(best_asteroid)} visible: #{count_visible(best_asteroid, best_asteroid_vm)}")
  end
end

Day10Part1.main()
