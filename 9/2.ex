move_diag = fn {hx, hy}, {tx, ty} ->
	case {hx-tx, hy-ty} do
		{dx, dy} when abs(dx) == 1 and abs(dy) == 1 -> {tx, ty}
		{dx, dy} -> cond do
			dx < 0 and dy < 0 -> {tx-1, ty-1} # top right
			dx < 0 and dy > 0 -> {tx-1, ty+1} # bot right
			dx > 0 and dy > 0 -> {tx+1, ty+1} # bot left
			dx > 0 and dy < 0 -> {tx+1, ty-1} # top left
		end
	end
end

calculate_pos = fn h, t -> if t < h, do: h-1, else: h+1 end
update_tail = fn {hx, hy}, {tx, ty} ->
	case {hx-tx, hy-ty} do
		{0,0} -> {tx, ty} # same pos = no update
		{0, _} -> {tx , calculate_pos.(hy, ty)} # same x = move y
		{_, 0} -> {calculate_pos.(hx, tx) , ty} # same y = move x
		_ -> move_diag.({hx, hy}, {tx, ty}) # else = diagonal move
	end
end

move = fn state, direction, size ->
	Enum.reduce(1..size, state, fn _, iter_size_state ->
		head_moved_state = case direction do
			"U" -> Map.update!(iter_size_state, 1, fn {x, y} -> {x, y+1} end)
			"D" -> Map.update!(iter_size_state, 1, fn {x, y} -> {x, y-1} end)
			"L" -> Map.update!(iter_size_state, 1, fn {x, y} -> {x-1, y} end)
			"R" -> Map.update!(iter_size_state, 1, fn {x, y} -> {x+1, y} end)
		end
		Enum.reduce(2..10, head_moved_state, fn idx, cur_state ->
			Map.update!(cur_state, idx, fn old_T ->
				update_tail.(cur_state[idx-1], old_T)
			end)
		end)
		|> (& Map.update!(&1, :mem, fn set -> MapSet.put(set, &1[10]) end)).()
	end)
end

state = Enum.reduce(1..10, %{mem: MapSet.new([{0,0}])}, &Map.put(&2, &1, {0,0}))
File.stream!("input.txt")
|> Enum.map(&String.trim_trailing/1)
|> Enum.map(&String.split/1)
|> Enum.reduce(state, fn [dir, size], cur_state ->
	move.(cur_state, dir, String.to_integer(size))
end)
|> (& &1[:mem]).() |> MapSet.size |> IO.puts
