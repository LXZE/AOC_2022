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

File.read!("input.txt")
|> String.trim |> String.split("\n\n")
|> Enum.map(&String.split(&1, "\n"))
|> Enum.map(fn vals ->
	Enum.map(vals, &(Code.eval_string(&1) |> elem(0)))
		|> List.to_tuple()
end)
|> Enum.map(&Solver.solve/1) |> Enum.with_index(1)
|> Enum.filter(&elem(&1, 0) != -1) |> Enum.map(&elem(&1, 1))
|> Enum.sum |> IO.puts
