idx_list = [20, 60, 100, 140, 180, 220]
File.stream!("input.txt")
|> Enum.map(&String.trim_trailing/1)
|> Enum.map(&String.split/1)
|> Enum.map(fn
	val when length(val) == 2 -> String.to_integer(Enum.at(val, -1))
	_ -> 0
end)
|> Enum.reduce([1], fn val, acc ->
	last = List.last(acc)
	case val do
		0 -> acc ++ [last]
		val -> acc ++ [last, last+val]
	end
end)
|> Enum.with_index
|> Enum.filter(fn {_, idx} -> idx+1 in idx_list end)
|> Enum.map(fn {val, idx} -> val * (idx+1) end)
|> Enum.sum |> IO.puts
