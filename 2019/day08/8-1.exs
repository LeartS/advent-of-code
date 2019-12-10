defmodule Day8Part1 do
  @layer_width 25
  @layer_height 6

  def main() do
    layer = IO.read(:all)
    |> String.trim()
    |> String.to_charlist()
    |> Enum.chunk_every(@layer_height * @layer_width)
    |> Enum.min_by(fn layer -> Enum.count(layer, fn digit -> digit == ?0 end) end)
    {ones, twos} = Enum.reduce(layer, {0, 0}, fn
      ?1, {ones, twos} -> {ones+1, twos}
      ?2, {ones, twos} -> {ones, twos+1}
      _, acc -> acc
    end)
    ones * twos |> IO.puts()
  end

end

Day8Part1.main()
