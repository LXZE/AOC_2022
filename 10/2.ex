print = fn matrix ->
	Enum.each(matrix, &Enum.join(&1, "") |> IO.puts)
end

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
|> Enum.with_index |> Enum.take(241) |> List.delete_at(0)
|> Enum.reduce({[], 1}, fn {val, idx}, {current_crt, last_pos} ->
	sprite_pos = [last_pos-1, last_pos, last_pos+1]
	pixel = cond do
		Integer.mod(idx - 1, 40) in sprite_pos -> "#"
		true -> "."
	end
	{ current_crt ++ [pixel], val }
end)
|> elem(0) |> Enum.chunk_every(40) |> Enum.take(6)
|> print.()
