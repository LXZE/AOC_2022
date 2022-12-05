[crates, _, moves] = File.stream!("input.txt")
|> Enum.map(&String.trim_trailing/1)
|> Enum.chunk_by(& &1 == "")

crate_regex = ~r/(\[\w\]|\s{3})\s?/
moves_regex = ~r/move (\d+) from (\d+) to (\d+)/

crates = List.pop_at(crates, -1) |> elem(1)
|> Enum.map(fn crate ->
	Regex.scan(crate_regex, crate, capture: :all_but_first)
	|> List.flatten
	|> Enum.map(& String.at(&1, 1))
end)
|> Enum.reduce(%{}, fn row, crates_acc ->
	Enum.with_index(row, & {&2 + 1, [&1]})
	|> Map.new
	|> Map.merge(crates_acc, fn _, l, r ->
		Enum.reject(l ++ r, & &1 == " ")
	end)
end)

Enum.reduce(moves, crates, fn move, cur_crates ->
	[amnt, from_idx, to_idx] = Regex.scan(moves_regex, move, capture: :all_but_first)
		|> List.flatten |> Enum.map(&String.to_integer/1)
	{crates_from, moved_crate} = Enum.split(cur_crates[from_idx], -amnt)
	Map.put(cur_crates, from_idx, crates_from)
		|> Map.update!(to_idx, & &1 ++ moved_crate)
end)
|> Map.values
|> Enum.map(& Enum.take(&1, -1))
|> List.flatten |> Enum.join("") |> IO.puts
