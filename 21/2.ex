defmodule Solver do
	def get_var_name(eq) do
		Regex.scan(~r/(\w{4})/, eq, capture: :all_but_first) |> List.flatten
	end
	def create_eq(current_eq, tables) do
		Regex.scan(~r/(\w{4})/, current_eq, capture: :all_but_first) |> List.flatten
		|> Enum.reduce(current_eq, fn var, acc ->
			sub = tables[String.to_atom(var)]
			|> (&unless(Regex.match?(~r/\d+/, &1), do: "(#{&1})", else: &1)).()
			String.replace(acc, var, sub)
		end)
	end
	def normalize_eq(eq) do
		Regex.replace(~r/(\(\d+[\+\-\*\/]\d+\))/, eq, fn _, val ->
			Code.eval_string(val) |> elem(0) |> round |> Integer.to_string
		end)
	end
	def capture(eq, start_idx) do
		stop_idx = Enum.reduce_while(start_idx..length(eq)-1, 0, fn idx, acc ->
			case Enum.at(eq, idx) do
				")" -> if acc == 1, do: {:halt, idx}, else: {:cont, acc-1}
				"(" -> {:cont, acc+1}
				_ -> {:cont, acc}
			end
		end)
		start_idx..stop_idx
	end
	def split_eq(eq) do
		splited_eq = String.graphemes(eq)
		start..stop = capture(splited_eq, Enum.find_index(splited_eq, & &1=="("))
		rem = String.slice(eq, start..stop) |> String.slice(1..-2)
		cond do
			String.at(eq, 0) == "(" ->
				ops = String.at(eq, stop+1)
				val = String.slice(eq, stop+2..-1) |> String.to_integer
				%{next: rem, ops: ops, val: val, rev: false}
			String.at(eq, -1) == ")" ->
				ops = String.at(eq, start-1)
				val = String.slice(eq, 0..start-2) |> String.to_integer
				rev = ops == "-" or ops == "/"
				%{next: rem, ops: ops, val: val, rev: rev}
		end
	end
end

cmds = File.stream!("input.txt")
|> Enum.map(&String.trim(&1) |> String.replace(": ", " = "))
|> Enum.sort_by(&String.length(&1))

root_eq = Enum.find_value(cmds, &if(String.contains?(&1, "root = "), do: &1))
humn_eq = Enum.find_value(cmds, &if(String.contains?(&1, "humn = "), do: &1))
[_, l_var, r_var] = Solver.get_var_name(root_eq)
l_eq = Enum.find_value(cmds, &if(String.contains?(&1, "#{l_var} = "), do: &1))
r_eq = Enum.find_value(cmds, &if(String.contains?(&1, "#{r_var} = "), do: &1))

cmds = (cmds -- [root_eq, humn_eq, l_eq, r_eq]) ++ ["humn = x"]
l_eq = l_eq |> String.split(" = ") |> Enum.at(1)
r_eq = r_eq |> String.split(" = ") |> Enum.at(1)

cmds = for cmd <- cmds do
	[k, v] = String.split(cmd, " = ")
	{String.to_atom(k), v}
end

loop_til_stop = fn (starter, func) ->
	Stream.repeatedly(fn -> nil end)
	|> Enum.reduce_while(starter, fn _, acc ->
		res = func.(acc)
		if res == acc, do: {:halt, res}, else: {:cont, res}
	end)
end

left_var = loop_til_stop.("(#{l_eq})", fn i -> Solver.create_eq(i, cmds) end)
right_var = loop_til_stop.("(#{r_eq})", fn i -> Solver.create_eq(i, cmds) end)

{eq, const} = if String.contains?(left_var, "(x)")
	and !String.contains?(right_var, "(x)"), do: {left_var, right_var}, else: {right_var, left_var}
const = Code.eval_string(const) |> elem(0) |> round
eq = loop_til_stop.(String.replace(eq, " ", ""), fn i -> Solver.normalize_eq(i) end)
|> String.slice(1..-2)

Enum.reduce_while(Stream.repeatedly(fn -> 0 end), %{eq: eq, const: const}, fn _, state ->
	res = Solver.split_eq(state.eq)
	new_state = Map.update!(state, :eq, fn _ -> res.next end)
	|> Map.update!(:const, fn c ->
		case res.ops do
			"+" -> c - res.val
			"-" -> unless res.rev, do: c + res.val, else: res.val - c
			"*" -> div(c, res.val)
			"/" -> unless res.rev, do: c * res.val, else: div(res.val, c)
		end
	end)
	if new_state.eq == "x", do: {:halt, new_state.const},
	else: {:cont, new_state}
end) |> IO.puts
