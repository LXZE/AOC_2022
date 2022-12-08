trees = File.stream!("input.txt")
|> Enum.map(&String.trim_trailing/1)
|> Enum.map(&String.graphemes/1)
|> Enum.map(fn col ->
	Enum.map(col, &String.to_integer/1)
end)
transpose_trees = trees |> Enum.zip() |> Enum.map(&Tuple.to_list/1)
row_size = length(trees)
col_size = length(Enum.at(trees, 0))

check_score = fn {idx_row, idx_col}, row, col ->
	self = Enum.at(row, idx_col)
	l = Enum.slice(row, 0..idx_col-1) |> Enum.reverse
	r = Enum.slice(row, idx_col+1..-1)
	t = Enum.slice(col, 0..idx_row-1) |> Enum.reverse
	b = Enum.slice(col, idx_row+1..-1)
	Enum.map([l,r,t,b], fn slice ->
		case Enum.find_index(slice, & &1 >= self) do
			nil -> length(slice)
			res -> res + 1
		end
	end)
	|> Enum.product
end

for idx_row <- (1..row_size-2),
	idx_col <- (1..col_size-2), into: [] do
	check_score.({idx_row, idx_col},
		Enum.at(trees, idx_row),
		Enum.at(transpose_trees, idx_col))
end
|> Enum.max |> IO.puts
