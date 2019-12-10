defmodule Day3Part2 do

  def expand_segment({direction, distance}, {x, y}) do
    case direction do
      :R -> x+distance..x |> Enum.map(&({&1, y}))
      :L -> x-distance..x |> Enum.map(&({&1, y}))
      :U -> y+distance..y |> Enum.map(&({x, &1}))
      :D -> y-distance..y |> Enum.map(&({x, &1}))
    end
  end

  def to_coordinate_list(commands) do
    Enum.reduce(commands, [{0, 0}], fn
      command, [position | tail] -> expand_segment(command, position) ++ tail
    end)
  end

  def parse_command(command) do
    {direction, distance} = String.split_at(command, 1)
    {String.to_atom(direction), String.to_integer(distance)}
  end

  def path_from_description(wire_desc) do
    wire_desc
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&parse_command/1)
      |> to_coordinate_list()
  end

  def l1_distance({ax, ay}, {bx, by}) do
    abs(ax-bx) + abs(ay-by)
  end

  def delay_distance(intersection, wire1_path, wire2_path) do
    a = wire1_path
      |> Enum.reverse()
      |> Enum.find_index(&(&1 == intersection))
    b = wire2_path
      |> Enum.reverse()
      |> Enum.find_index(&(&1 == intersection))
    IO.inspect({a, b})
    a + b
  end

  def find_nearest_intersection(path1, path2, central_point) do
    set_path1 = MapSet.new(path1)
    set_path2 = MapSet.new(path2)
    MapSet.intersection(set_path1, set_path2)
      |> Enum.sort_by(&(delay_distance(&1, path1, path2)))
      |> IO.inspect()
      |> Enum.at(1)
  end

  def main() do
    wire1_coords = IO.gets(nil) |> path_from_description
    wire2_coords = IO.gets(nil) |> path_from_description
    central_point = {0, 0}
    find_nearest_intersection(wire1_coords, wire2_coords, central_point)
      |> delay_distance(wire1_coords, wire2_coords)
  end
end

Day3Part2.main() |> IO.puts()

