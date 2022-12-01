data = File.stream!('input.txt')
|> Stream.map(&String.trim/1)
|> Enum.reduce([0], fn elem, acc ->
	if elem != "" do
		[head | tail] = acc
		[head + String.to_integer(elem) | tail]
	else
		[0 | acc]
	end
end
)
|> Enum.max

IO.inspect data
