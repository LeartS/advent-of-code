defmodule AsteroidVisibilityMap do
  defstruct vm: %{}, asteroid: nil

  def new(asteroid), do: %AsteroidVisibilityMap{asteroid: asteroid}

  defimpl Collectable do
    def into(original) do
      collector = fn
        vm, {:cont, {φ, asteroid}} -> %{vm | vm: Map.update(vm.vm, φ, [asteroid], &([asteroid | &1]))}
        vm, :done -> vm
      end
      {original, collector}
    end
  end

  def count_visible(self), do: map_size(self.vm)
end

defmodule Day10Part1 do

  defp get_polar_coordinates({refx, refy}, {px, py}) do
    {δx, δy} = {px-refx, py-refy}
    {:math.atan2(δy, δx), :math.sqrt(δx*δx + δy*δy)}
  end

  def read_asteroids_coordinates() do
    for {line, i} <- Stream.with_index(IO.stream(:stdio, :line)) do
      chars = line
      |> String.trim()
      |> String.graphemes
      for {char, j} <- Stream.with_index(chars), char == "#" do
        {i, j}
      end
    end
    |> List.flatten()
    |> Enum.map(fn {r, c} -> {c, r} end)
  end

  defp build_asteroid_visibility_map(asteroids, reference) do
    for asteroid <- asteroids, asteroid != reference, into: AsteroidVisibilityMap.new(reference) do
      {φ, _r} = get_polar_coordinates(reference, asteroid)
      {φ, asteroid}
    end
  end

  def main() do
    asteroids = read_asteroids_coordinates()
    best = asteroids
    |> Enum.map(&(build_asteroid_visibility_map(asteroids, &1)))
    |> Enum.max_by(fn avm -> AsteroidVisibilityMap.count_visible(avm) end)
    IO.puts("Best asteroid: #{inspect(best.asteroid)} visible: #{AsteroidVisibilityMap.count_visible(best)}")
  end
end

Day10Part1.main()
