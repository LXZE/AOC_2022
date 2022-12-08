trees = File.stream!("input.txt")
|> Enum.map(&String.trim_trailing/1)
|> Enum.map(&String.graphemes/1)
|> Enum.map(fn col ->
	Enum.map(col, &String.to_integer/1)
end)
transpose_trees = trees |> Enum.zip() |> Enum.map(&Tuple.to_list/1)
row_size = length(trees)
col_size = length(Enum.at(trees, 0))

check_visible = fn {idx_row, idx_col}, row, col ->
	self = Enum.at(row, idx_col)
	max_l = Enum.slice(row, 0..idx_col-1) |> Enum.max
	max_r = Enum.slice(row, idx_col+1..-1) |> Enum.max
	max_t = Enum.slice(col, 0..idx_row-1) |> Enum.max
	max_b = Enum.slice(col, idx_row+1..-1) |> Enum.max
	[max_l, max_r, max_t, max_b]
	|> Enum.map(& &1 < self)
	|> Enum.any?
end

for idx_row <- (1..row_size-2),
	idx_col <- (1..col_size-2), into: [] do
	check_visible.({idx_row, idx_col},
		Enum.at(trees, idx_row),
		Enum.at(transpose_trees, idx_col))
end
|> Enum.count(& &1)
|> Kernel.+(((row_size+col_size)*2) - 4)
|> IO.puts
