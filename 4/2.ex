File.stream!('input.txt')
|> Enum.map(&String.trim/1)
|> Enum.map(&(String.split(&1, ",")))
|> Enum.map(fn ranges ->
	[r1, r2] = Enum.map(ranges, fn range ->
		String.split(range, "-")
			|> Enum.map(&String.to_integer/1)
			|> (fn [x, y] -> x..y end).()
	end)
	!Range.disjoint?(r1, r2)
end)
|> Enum.count(&(&1))
|> IO.inspect
