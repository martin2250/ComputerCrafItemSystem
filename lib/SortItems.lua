function sortItems()
	table.sort(items, 
		function(a, b)
			if a.color == b.color then
				return string.lower(a.alias) < string.lower(b.alias)
			else
				return a.color < b.color
			end
		end
	)
end