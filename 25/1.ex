defmodule SNAFU do
	def mod(x, y) when x < 0, do: rem(x, y) + y
	def mod(x, y), do: rem(x, y)

	@snafu %{"2" => 2, "1" => 1, "0" => 0, "-" => -1, "=" => -2}
	def convert({item, digit}), do: @snafu[item]*(5**digit)
	def to_dec(str) do
		String.graphemes(str) |> Enum.reverse |> Enum.with_index
		|> Enum.map(&convert/1) |> Enum.sum
	end

	def to_SNAFU(0), do: ""
	def to_SNAFU(num) do
		case mod(num, 5) do
			0 -> to_SNAFU(div(num, 5)) <> "0"
			1 -> to_SNAFU(div(num, 5)) <> "1"
			2 -> to_SNAFU(div(num, 5)) <> "2"
			3 -> to_SNAFU(div(num+2, 5)) <> "="
			4 -> to_SNAFU(div(num+1, 5)) <> "-"
		end
	end
end

answer = File.stream!("input.txt")
|> Enum.map(&String.trim_trailing(&1))
|> Enum.map(&SNAFU.to_dec/1)
|> Enum.sum

IO.puts(SNAFU.to_SNAFU(answer))
