defmodule Day2Part2 do
  @desired_output 19690720

  def exec_instruction(memory, address, operator) do
      op1 = elem(memory, elem(memory, address+1))
      op2 = elem(memory, elem(memory, address+2))
      put_elem(memory, elem(memory, address+3), operator.(op1, op2))
  end

  def run(memory, instruction_pointer) when elem(memory, instruction_pointer) == 99, do: memory
  def run(memory, instruction_pointer) do
      opcode = elem(memory, instruction_pointer)
      operator = case opcode do
          1 -> &+/2
          2 -> &*/2
      end
      memory = exec_instruction(memory, instruction_pointer, operator)
      run(memory, instruction_pointer+4)
  end

  def replace_noun_and_verb(memory, noun, verb) do
      memory
      |> put_elem(1, noun)
      |> put_elem(2, verb)
  end

  def main() do
      memory = IO.gets(:stdio, "Inserisci la stringa\n")
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
      run(memory, 0)

      try do
        for noun <- 0..99, verb <- 0..99 do
          first = memory
          |> replace_noun_and_verb(noun, verb)
          |> run(0)
          |> elem(0)
          if first == @desired_output, do: throw({noun, verb}), else: nil
        end
      catch
        {noun, verb} -> 100 * noun + verb
      end
  end
end

Day2Part2.main() |> IO.inspect()

