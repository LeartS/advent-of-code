defmodule Coordinates do
end

defmodule Body do
  defstruct name: nil, position: nil, velocity: %{x: 0, y: 0, z: 0}

  def new(name, %{x: _, y: _, z: _} = position, %{x: _, y: _, z: _} = velocity) do
    %Body{name: name, position: position, velocity: velocity}
  end

  def apply_gravity(body, %Body{} = other_body) do
    new_velocity = Enum.map(body.velocity, fn {axis, speed} ->
      new_speed = case body.position[axis] - other_body.position[axis] do
        0 -> speed
        n when n > 0 -> speed - 1
        n when n < 0 -> speed + 1
      end
      {axis, new_speed}
    end)
    |> Map.new()
    %Body{body | velocity: new_velocity}
  end
  def apply_gravity(body, []), do: body
  def apply_gravity(body, [other_body | rest]) do
    Body.apply_gravity(body, other_body)
    |> Body.apply_gravity(rest)
  end

  def apply_speed(%Body{
    position: %{x: x, y: y, z: z},
    velocity: %{x: vx, y: vy, z: vz}
  } = body) do
    %Body{body |
      position: %{x: x+vx, y: y+vy, z: z+vz}
    }
  end

  def potential_energy(body) do
    Enum.reduce(body.position, 0, fn {_, v}, pot -> pot + abs(v) end)
  end

  def kinetic_energy(body) do
    Enum.reduce(body.velocity, 0, fn {_, v}, kin -> kin + abs(v) end)
  end

  def total_energy(body) do
    potential_energy(body) * kinetic_energy(body)
  end

end

defmodule Universe do
  defstruct moons: []

  def new(moons), do: %Universe{moons: moons}

  def new_from_map(map_string) do
    moons = for line <- String.split(map_string, "\n") do
      coord_values = Regex.run(~r/<x=(?<x>-?\d+), y=(?<y>-?\d+), z=(?<z>-?\d+)>/, line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)
      position = Enum.zip([:x, :y, :z], coord_values)
      |> Map.new()
      Body.new(line, position, %{x: 0, y: 0, z: 0})
    end
    %Universe{moons: moons}
  end

  def simulation_step(universe) do
    updated_moons = for moon <- universe.moons do
      moon
      |> Body.apply_gravity(universe.moons)
      |> Body.apply_speed()
    end
    %Universe{universe | moons: updated_moons}
  end

  def total_energy(universe) do
    universe.moons
    |> Stream.map(&Body.total_energy/1)
    |> Enum.sum()
  end

end

defmodule Day12Part1 do
  @simulation_steps 1000

  def main() do
    Universe.new_from_map(IO.read(:all))
    |> Stream.iterate(&Universe.simulation_step/1)
    |> Enum.at(@simulation_steps)
    |> Universe.total_energy()
  end
end

Day12Part1.main() |> IO.inspect()
