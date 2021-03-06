defmodule Memory do
  @type t :: tuple()

  def from_string(str) do
    str
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def read(memory, addr) when is_integer(addr), do: elem(memory, addr)
  def read(memory, addrs) when is_list(addrs) do
    Enum.map(addrs, & Memory.read(memory, &1))
  end
  def read(_memory, _addr, 0), do: []
  def read(memory, addr, count) do
    [Memory.read(memory, addr) | Memory.read(memory, addr+1, count-1)]
  end

  def save(memory, addr, value), do: put_elem(memory, addr, value)
  def save(memory, []), do: memory
  def save(memory, [{addr, value} | tail]) do
    Memory.save(memory, addr, value)
    |> Memory.save(tail)
  end
end


defmodule InstructionDesc do
  defstruct opcode: nil, input_params: nil, output_params: nil
end


defmodule Intcode do
  @instructions %{
    :"01" => %InstructionDesc{opcode: :"01", input_params: 2, output_params: 1},
    :"02" => %InstructionDesc{opcode: :"02", input_params: 2, output_params: 1},
    :"03" => %InstructionDesc{opcode: :"03", input_params: 0, output_params: 1},
    :"04" => %InstructionDesc{opcode: :"04", input_params: 1, output_params: 0},
    :"05" => %InstructionDesc{opcode: :"05", input_params: 2, output_params: 0},
    :"06" => %InstructionDesc{opcode: :"06", input_params: 2, output_params: 0},
    :"07" => %InstructionDesc{opcode: :"07", input_params: 2, output_params: 1},
    :"08" => %InstructionDesc{opcode: :"08", input_params: 2, output_params: 1},
    :"99" => %InstructionDesc{opcode: :"99", input_params: 0, output_params: 0},
  }

  def get_param(memory, addr, ?1), do: Memory.read(memory, addr)
  def get_param(memory, addr, ?0), do: Memory.read(memory, Memory.read(memory, addr))

  def get_params(_memory, []), do: []
  def get_params(memory, [{addr, mode} | tail]) do
    [get_param(memory, addr, mode) | get_params(memory, tail)]
  end

  def exec_instruction(:"01", [a, b]), do: {{:advance, 4}, [a + b]}
  def exec_instruction(:"02", [a, b]), do: {{:advance, 4}, [a * b]}
  def exec_instruction(:"03", []) do
    output = IO.gets("Input:\n") |> String.trim() |> String.to_integer()
    {{:advance, 2}, [output]}
  end
  def exec_instruction(:"04", [a]) do
    IO.puts("Output: #{a}")
    {{:advance, 2}, []}
  end
  def exec_instruction(:"05", [0, _]), do: {{:advance, 3}, []}
  def exec_instruction(:"05", [_, p]), do: {{:jump, p}, []}
  def exec_instruction(:"06", [0, p]), do: {{:jump, p}, []}
  def exec_instruction(:"06", [_, _]), do: {{:advance, 3}, []}
  def exec_instruction(:"07", [a, b]) when a < b, do: {{:advance, 4}, [1]}
  def exec_instruction(:"07", [_a, _b]), do: {{:advance, 4}, [0]}
  def exec_instruction(:"08", [a, a]), do: {{:advance, 4}, [1]}
  def exec_instruction(:"08", [_a, _b]), do: {{:advance, 4}, [0]}
  def exec_instruction(:"99", []), do: {:halt, []}

  def parse_instruction_intcode(intcode) do
    {param_modes, opcode} = intcode
      |> Integer.to_string()
      |> String.pad_leading(2, "0")
      |> String.split_at(-2)
    instruction = Map.fetch!(@instructions, String.to_atom(opcode))
    {input_modes, output_modes} = param_modes
     |> String.pad_leading(instruction.input_params + instruction.output_params, "0")
     |> String.reverse()
     |> String.split_at(instruction.input_params)
    %{
      instruction: instruction,
      input_modes: String.to_charlist(input_modes),
      output_modes: String.to_charlist(output_modes),
    }
  end

  def exec_addr(memory, address) do
    IO.puts(:standard_error, "#{address} - #{inspect(memory)}")
    %{instruction: instr, input_modes: im} = Memory.read(memory, address)
      |> Intcode.parse_instruction_intcode()
    inputs = Enum.zip(address+1..address+instr.input_params, im)
    input_values = Intcode.get_params(memory, inputs)
    {next, output_values} = Intcode.exec_instruction(instr.opcode, input_values)
    output_addresses = Memory.read(memory, address+instr.input_params+1, instr.output_params)
    memory = Memory.save(memory, Enum.zip(output_addresses, output_values))
    case next do
      {:advance, offset} -> {address + offset, memory}
      {:jump, pointer} -> {pointer, memory}
      :halt -> {:halt, memory}
    end
  end

end


defmodule IntcodeComputer do
  def run(memory, address) do
    result = Intcode.exec_addr(memory, address)
    case result do
      {:halt, memory} -> memory
      {next_addr, memory} -> run(memory, next_addr)
    end
  end
end


defmodule Day5 do
  def main() do
    IO.gets("Input memory:\n")
    |> Memory.from_string()
    |> IntcodeComputer.run(0)
  end
end


Day5.main()
