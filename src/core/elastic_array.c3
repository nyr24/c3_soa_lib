module std::collections::elastic_array{Type, MAX_SIZE};

<*
	@require new_cap <= MAX_SIZE : "Would exceed maximum capacity"
*>
fn void ElasticArray.set_size(&self, usz new_cap)
{
	self.size = new_cap;
}

fn Type* ElasticArray.data(&self)
{
	return &self.entries;
}

fn void ElasticArray.fill(&self, Type val)
{
	foreach (&entry : self.array_view()) {
		*entry = val;
	}
}
