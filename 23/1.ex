adjacents = fn {x, y} ->
	for dx <- -1..1, dy <- -1..1, {dx, dy} != {0, 0}, into: [], do: {x+dx, y+dy}
end

lookup_methods = [
	fn {r, c}, set -> Enum.all?(for dc <- [-1, 0, 1], do: {r-1, c+dc} not in set) end,
	fn {r, c}, set -> Enum.all?(for dc <- [-1, 0, 1], do: {r+1, c+dc} not in set) end,
	fn {r, c}, set -> Enum.all?(for dr <- [-1, 0, 1], do: {r+dr, c-1} not in set) end,
	fn {r, c}, set -> Enum.all?(for dr <- [-1, 0, 1], do: {r+dr, c+1} not in set) end
] |> Stream.cycle

move_methods = [
	fn {r, c} -> {r-1, c} end,
	fn {r, c} -> {r+1, c} end,
	fn {r, c} -> {r, c-1} end,
	fn {r, c} -> {r, c+1} end
] |> Stream.cycle

elves = File.stream!("input.txt")
|> Enum.map(&(String.trim(&1) |> String.graphemes))
|> Enum.with_index |> Enum.flat_map(fn {row, ridx} ->
	Enum.with_index(row) |> Enum.map(fn
		{".", _} -> {nil, nil}
		{"#", cidx} -> {ridx, cidx}
	end)
end) |> Enum.reject(& &1 == {nil, nil}) |> MapSet.new

init_state = %{elves: elves, method_idx: 0}
elves = Enum.reduce(1..10, init_state, fn _, state ->
	new_elves = Enum.filter(state.elves, fn elf_pos ->
		Enum.any?(for pos <- adjacents.(elf_pos), do: MapSet.member?(state.elves, pos))
	end)
	|> Enum.map(fn elf_pos ->
		offset = Enum.find_index(0..3,
			&Enum.at(lookup_methods, state.method_idx+&1) |> apply([elf_pos, state.elves]))
		if offset, do: {elf_pos, Enum.at(move_methods, state.method_idx+offset) |> apply([elf_pos])},
		else: nil
	end) |> Enum.filter(& &1)
	|> Enum.group_by(&elem(&1, 1))
	|> Map.reject(fn {_k, v} -> length(v) > 1 end) |> Map.values |> List.flatten
	|> Enum.reduce(state.elves, fn {from, to}, cur_elves ->
		MapSet.delete(cur_elves, from) |> MapSet.put(to)
	end)
	Map.update!(state, :elves, fn _ -> new_elves end)
	|> Map.update!(:method_idx, & &1+1)
end)
|> (& &1.elves).()

{{lo_r, _}, {hi_r, _}} = Enum.min_max_by(elves, &elem(&1, 0))
{{_, lo_c}, {_, hi_c}} = Enum.min_max_by(elves, &elem(&1, 1))
((hi_r - lo_r + 1) * (hi_c - lo_c + 1)) - MapSet.size(elves) |> IO.puts
