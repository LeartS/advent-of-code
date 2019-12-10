defmodule Day2 do

    def execute_opcode(memory, position, operator) do
        op1 = elem(memory, elem(memory, position+1))
        op2 = elem(memory, elem(memory, position+2))
        put_elem(memory, elem(memory, position+3), operator.(op1, op2))
    end

    def step(memory, position) when elem(memory, position) == 99, do: memory
    def step(memory, position) do
        opcode = elem(memory, position)
        operator = case opcode do
            1 -> &+/2
            2 -> &*/2
        end
        memory = execute_opcode(memory, position, operator)
        step(memory, position+4)
    end

    def alarm_state(memory) do
        memory
        |> put_elem(1, 12)
        |> put_elem(2, 2)
    end

    def main() do
        memory = IO.gets(:stdio, "Inserisci la stringa\n")
        |> String.trim()
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
        |> alarm_state
        step(memory, 0)
    end
end

Day2.main() |> elem(0) |> IO.puts()
