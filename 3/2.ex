priority = Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z)
|> List.to_string |> String.graphemes
find_priority = fn ch -> Enum.find_index(priority, &(&1 == ch)) + 1 end

File.stream!('input.txt')
|> Enum.map(&String.trim/1)
|> Enum.chunk_every(3) |> Enum.map(fn x ->
	x
	|> Enum.map(&String.graphemes/1)
	|> Enum.map(&MapSet.new/1)
	|> Enum.reduce(fn new_set, acc ->
		MapSet.intersection(new_set, acc)
	end)
	|> MapSet.to_list
end)
|> Enum.map(fn [x] -> find_priority.(x) end)
|> Enum.sum
|> IO.inspect
