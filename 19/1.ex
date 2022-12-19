defmodule Solver do
	def update_items(bots, items) do items
		|> Map.update!(:ore, & &1 + bots.ore_bot)
		|> Map.update!(:cly, & &1 + bots.cly_bot)
		|> Map.update!(:obs, & &1 + bots.obs_bot)
		|> Map.update!(:geo, & &1 + bots.geo_bot)
	end

	def solve(_, _bots, step, items) when step == 25 do items.geo end
	def solve(plan, bots, step, items) do
		new_items = update_items(bots, items)
		cond do
			# 1. if can create geo bot then proceed
			items.ore >= plan.geo_bot_ore and items.obs >= plan.geo_bot_obs ->
				new_bots = Map.update!(bots, :geo_bot, & &1+1)
				used_items = Map.update!(new_items, :ore, & &1 - plan.geo_bot_ore)
				|> Map.update!(:obs, & &1 - plan.geo_bot_obs)
				solve(plan, new_bots, step+1, used_items)
			# 2. if can create obs bot then proceed
			items.ore >= plan.obs_bot_ore and items.cly >= plan.obs_bot_cly ->
				new_bots = Map.update!(bots, :obs_bot, & &1+1)
				used_items = Map.update!(new_items, :ore, & &1 - plan.obs_bot_ore)
				|> Map.update!(:cly, & &1 - plan.obs_bot_cly)
				solve(plan, new_bots, step+1, used_items)
			true ->
				choices = [
					# 3. produce ore as much as possible
					# ore = 4 should ok as max of require ore in all type of bots = 4
					if items.ore < 5 do # 4 doesn't work, 5 works, I don't know why
						solve(plan, bots, step+1, new_items)
					else 0 end,
					# 4. if can create ore bot then proceed
					if items.ore >= plan.ore_bot_ore do
						new_bots = Map.update!(bots, :ore_bot, & &1+1)
						used_items = Map.update!(new_items, :ore, & &1 - plan.ore_bot_ore)
						solve(plan, new_bots, step+1, used_items)
					else 0 end,
					# 5. if can create clay bot then proceed
					if items.ore >= plan.cly_bot_ore do
						new_bots = Map.update!(bots, :cly_bot, & &1+1)
						used_items = Map.update!(new_items, :ore, & &1 - plan.cly_bot_ore)
						solve(plan, new_bots, step+1, used_items)
					else 0 end
				]
				Enum.max(choices)
		end
	end
end

init_bots = %{ ore_bot: 1, cly_bot: 0, obs_bot: 0, geo_bot: 0 }
init_material = %{ ore: 0, cly: 0, obs: 0, geo: 0 }

File.stream!("input.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(fn row ->
	[a,b,c,d,e,f] = Regex.scan(~r/(\d+)/, row, capture: :all_but_first)
	|> List.flatten |> Enum.map(&String.to_integer/1)
	|> List.delete_at(0)
	%{ 	ore_bot_ore: a, cly_bot_ore: b,
		obs_bot_ore: c, obs_bot_cly: d,
		geo_bot_ore: e, geo_bot_obs: f}
end)
|> Enum.with_index(1)
|> Enum.reduce(0, fn {blueprint, step}, acc ->
	acc + (Solver.solve(blueprint, init_bots, 1, init_material) * step)
end)
|> IO.puts
