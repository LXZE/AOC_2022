priority = Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z)
|> List.to_string |> String.graphemes
find_priority = fn ch -> Enum.find_index(priority, &(&1 == ch)) + 1 end

File.stream!('input.txt')
|> Enum.map(&String.trim/1)
|> Enum.map(&(String.split_at(&1, div(String.length(&1), 2))))
|> Enum.map(&({
	MapSet.new(elem(&1, 0) |> String.graphemes),
	MapSet.new(elem(&1, 1) |> String.graphemes)
}))
|> Enum.map(&(MapSet.intersection(elem(&1, 0), elem(&1, 1))))
|> Enum.map(&MapSet.to_list/1)
|> Enum.map(fn [x] -> find_priority.(x) end)
|> Enum.sum
|> IO.inspect
