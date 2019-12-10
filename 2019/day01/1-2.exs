defmodule Day1 do

  def calculate_fuel(mass) when mass <= 0, do: 0
  def calculate_fuel(mass) do
    fuel = mass |> div(3) |> Kernel.-(2) |> max(0)
    fuel + calculate_fuel(fuel)
  end

  def exec() do
    fuels = for line <- IO.stream(:stdio, :line) do
      line
      |> String.trim()
      |> String.to_integer()
      |> calculate_fuel()
    end
    IO.puts(Enum.sum(fuels))
  end

end

Day1.exec()
