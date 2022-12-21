defmodule Solver do
	def solve(eqs, tables) do
		case tables[:root] do
			nil ->
				new_tables = Enum.reduce(eqs, tables, fn eq, acc ->
					[var, v1, v2] = Regex.scan(~r/(\w{4})/, eq, capture: :all_but_first)
					|> List.flatten
					if Keyword.has_key?(acc, String.to_atom(v1))
					and Keyword.has_key?(acc, String.to_atom(v2))
					and !Keyword.has_key?(acc, String.to_atom(var)) do
						elem(Code.eval_string(eq, acc), 1)
					else acc end
				end)
				solve(eqs, new_tables)
			val -> round(val)
		end
	end
end

cmds = File.stream!("input.txt")
|> Enum.map(&String.trim(&1) |> String.replace(": ", " = "))
|> Enum.sort_by(&String.length(&1))

eqs = Enum.filter(cmds, &String.contains?(&1, ["+", "-", "*", "/"]))
consts = cmds -- eqs
|> Enum.map(&Code.eval_string(&1) |> elem(1)) |> List.flatten

Solver.solve(eqs, consts) |> IO.puts
