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

  def save(memory, addr, value), do: put_elem(memory, addr, value)
  def save(memory, [{addr, value} | tail]) do
    Memory.save(memory, addr, value)
    |> Memory.save(tail)
  end
end


# defmodule Instruction do
#   @callback exec(memory :: Memory.t(), addr :: integer) ::
#     {:halt, Memory.t()}
#     {next_addr :: integer, Memory.t()}
# end

# defmodule Instruction.Multiply do
#   @behaviour Instruction

#   # exec
# end


# defmodule Instruction do
#   # @type t :: %Instruction{opcode: atom(), }

#   def new(opcode, input_arity, output_arity, function) do
#     %Instruction{opcode: opcode, input_arity: input_arity, output_arity: output_arity, function: function}
#   end


#   def get_inputs_and_outputs(memory) do

#   end

#   def save_output(memory, outputs, output_addrs) do
#     Memory.save(memory, Enum.zip(outputs, output_addrs))
#   end

#   def exec(instruction, memory, address) do
#     param_modes = elem(memory, address)
#     |> to_string()
#     |> String.slice(0..-3)  # remove opcode
#     |> String.pad_leading(instruction.input_arity, "0")
#     |> String.reverse()
#     |> String.to_charlist()

#     input_values = address+1..address+instruction.input_arity
#     |> Enum.zip(param_modes)
#     |> Enum.map(fn {addr, mode} -> get_param(memory, addr, mode) end)
#     |> IO.inspect()

#     output_addresses = address+instruction.input_arity+1..address.

#     outputs = apply(instruction.function, input_values) |> List.wrap()
#     Instruction.save_outputs(memory, outputs, )
#     memory = put_elem(memory, address + instruction.input_arity + instruction.output_arity + 1, output)
#     IO.puts("Opcode: #{instruction.opcode} input: #{inspect(input_values)} output: #{output}")
#     {address + instruction.input_arity + instruction.output_arity + 1, memory}
#   end
# end

defmodule InstructionDesc do
  defstruct opcode: nil, input_params: nil, output_params: nil
end

defmodule Intcode do
  @instructions %{
    :"01" => %InstructionDesc{opcode: :"01", input_params: 2, output_params: 1},
    :"02" => %InstructionDesc{opcode: :"02", input_params: 2, output_params: 1},
    :"03" => %InstructionDesc{opcode: :"03", input_params: 0, output_params: 1},
    :"04" => %InstructionDesc{opcode: :"04", input_params: 1, output_params: 0},
    :"99" => %InstructionDesc{opcode: :"99", input_params: 0, output_params: 0},
  }

  def get_param(memory, addr, ?1), do: Memory.read(memory, addr)
  def get_param(memory, addr, ?0), do: Memory.read(memory, Memory.read(memory, addr))

  def get_params(_memory, []), do: []
  def get_params(memory, [{addr, mode} | tail]) do
    [get_param(memory, addr, mode) | get_params(memory, tail)]
  end

  def exec_instruction(:"01", [a, b]), do: a + b
  def exec_instruction(:"02", [a, b]), do: a * b
  def exec_instruction(:"03", []) do
    IO.gets("Input: ") |> String.trim() |> String.to_integer()
  end
  def exec_instruction(:"04", [a]), do: IO.puts(a)

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

  def save_outputs(instruction, memory, address, outputs) do
    Enum.with_index(outputs, address + instruction.input_params + 1)
    |> IO.inspect()
    |> Enum.reduce(memory, fn out, addr -> Memory.save(memory, addr, out) end)
  end

  def exec_addr(memory, address) do
    %{instruction: instr, input_modes: im, output_modes: om} = c =
      Memory.read(memory, address)
      # |> IO.inspect()
      |> Intcode.parse_instruction_intcode()
    # IO.inspect(c)
    inputs = Enum.zip(address+1..address+instr.input_params, im)
    # |> IO.inspect()
    input_values = Intcode.get_params(memory, inputs)
    # IO.inspect(input_values)
    IO.puts("merda")
    boh = Enum.zip(address+instr.input_params+1..address+instr.input_params+instr.output_params, om)
    |> IO.inspect()
    output_addresses = Intcode.get_params(memory, boh)
    |> IO.inspect()
    outputs = Intcode.exec_instruction(instr.opcode, input_values) |> List.wrap()
    memory = Intcode.save_outputs(instr, memory, address, outputs)
    # IO.inspect(memory)
    if instr.opcode == :"99" do
      {:halt, memory}
    else
      {address + instr.input_params + instr.output_params + 1, memory}
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
    IO.gets("Memory:\n")
    |> Memory.from_string()
    |> IO.inspect()
    |> IntcodeComputer.run(0)
  end
end


Day5.main()
