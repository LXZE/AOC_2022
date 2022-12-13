# -1 = not in order, 0 = equal, 1 = in order
defmodule Solver do
	def expand(lst, n) when n > length(lst), do: lst ++ List.duplicate(nil, n-length(lst))
	def expand(lst, _), do: lst
	def compare_int(l, r) when l<r, do: 1
	def compare_int(l, r) when l==r, do: 0
	def compare_int(l, r) when l>r, do: -1
	def solve({nil, _}), do: 1
	def solve({_, nil}), do: -1
	def solve({l, r}) when is_integer(l) and is_integer(r), do: compare_int(l, r)
	def solve({l, r}) when is_integer(l) and is_list(r), do: solve({[l], r})
	def solve({l, r}) when is_list(l) and is_integer(r), do: solve({l, [r]})
	def solve({l, r}) when is_list(l) and is_list(r) do
		max_len = max(length(l), length(r))
		Stream.map(Enum.zip(expand(l, max_len), expand(r, max_len)), &solve/1)
			|> Enum.find_value(& if &1 != 0, do: &1) # get first unequal value
			|> (& if is_nil(&1), do: 0, else: &1).() # if nil then it's equal
	end
end

signals = File.read!("input.txt")
|> String.trim |> String.split("\n\n")
|> Enum.map(&String.split(&1, "\n"))
|> Enum.map(fn vals ->
	Enum.map(vals, &(Code.eval_string(&1) |> elem(0)))
end)
|> Enum.reduce([], fn pair, acc -> acc ++ pair end)
first_index = Enum.reduce(signals, 1, fn signal, acc ->
	case Solver.solve({signal, [[2]]}) do
		-1 -> acc
		_ -> acc + 1
	end
end)
second_index = Enum.reduce(signals, 0, fn signal, acc ->
	case Solver.solve({[[6]], signal}) do
		-1 -> acc
		_ -> acc + 1
	end
end)
|> (& (length(signals)-&1) + 2).()
IO.puts(first_index * second_index)
