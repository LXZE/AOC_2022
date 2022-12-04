# range &1 < &2
is_in_range? = fn l..h, range -> l in range && h in range end

File.stream!('input.txt')
|> Enum.map(&String.trim/1)
|> Enum.map(&(String.split(&1, ",")))
|> Enum.map(fn ranges ->
	[r1, r2] = Enum.map(ranges, fn range ->
		String.split(range, "-")
			|> Enum.map(&String.to_integer/1)
			|> (fn [x, y] -> x..y end).()
	end)
	|> Enum.sort_by(&Range.size/1)
	is_in_range?.(r1, r2)
end)
|> Enum.count(&(&1))
|> IO.inspect
