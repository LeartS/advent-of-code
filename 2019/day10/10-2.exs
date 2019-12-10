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

  def vaporize(t) do
    t.vm
    |> Enum.flat_map(fn {θ, asteroids} ->
      for {{r, a}, i} <- Enum.with_index(asteroids), do: {{2*i*:math.pi + θ, r}, a}
    end)
    |> Enum.sort()
  end

end

defmodule Day10Part1 do

  def get_polar_coordinates({refx, refy}, {px, py}) do
    {δx, δy} = {px-refx, refy-py}
    θ = :math.atan2(δy, δx)
    # make reference angle point up (north = 0 = 2pi, east = pi/4 south = pi/2, west = 3/2 pi)
    θ = -(θ - :math.pi/2)
    θ = if θ < 0, do: θ + :math.pi*2, else: θ
    {:math.sqrt(δx*δx + δy*δy), θ}
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
      {r, θ} = get_polar_coordinates(reference, asteroid)
      {θ, {r, asteroid}}
    end
  end

  def main(target_index) do
    asteroids = read_asteroids_coordinates()
    {_, coords} = _final_vaporized = asteroids
    |> Enum.map(&(build_asteroid_visibility_map(asteroids, &1)))
    |> Enum.max_by(fn avm -> AsteroidVisibilityMap.count_visible(avm) end)
    |> AsteroidVisibilityMap.vaporize()
    |> Enum.at(target_index-1)
    IO.puts("The #{target_index}th asteroid to be vaporized has coordinates #{inspect(coords)}")
  end
end

Day10Part1.main(200)
