int_list = File.stream!("input.txt")
|> Enum.map(&(String.trim(&1) |> String.to_integer |> Kernel.*(811589153)))
int_len = length(int_list)
indexes = 0..int_len-1 |> Enum.to_list
mod = fn 0, _ -> 0; x, y when x < 0 -> rem(x, y) + y; x, y -> rem(x, y) end
result = Enum.reduce(1..10, indexes, fn _, mixed_indexes ->
	Enum.reduce(indexes, mixed_indexes, fn target_idx, acc ->
		# pop list of current state_idx with given target idx
		# and put at the newly calculated position (current_idx + int[target_index])
		# mod by length of list - 1 (as item is removed from list)
		current_idx = Enum.find_index(acc, & &1 == target_idx)
		res_idx = mod.(current_idx + Enum.at(int_list, target_idx), int_len-1)
		List.delete_at(acc, current_idx)
		|> List.insert_at(res_idx, target_idx)
	end)
end)
|> Enum.map(&Enum.at(int_list, &1))

zero_idx = Enum.find_index(result, & &1 == 0)
result = Enum.slice(result, zero_idx..-1) ++ Enum.slice(result, 0..zero_idx-1)

[1000, 2000, 3000] |> Enum.map(&Enum.at(Stream.cycle(result), &1)) |> Enum.sum |> IO.puts
