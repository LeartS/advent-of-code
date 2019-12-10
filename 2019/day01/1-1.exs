defmodule Day1 do

  def calculate_fuel(mass) do
    mass |> div(3) |> Kernel.-(2)
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
