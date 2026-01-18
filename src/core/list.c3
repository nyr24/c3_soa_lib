module std::collections::list{Type};

fn void List.fill(&self, Type val)
{
	foreach (&entry : self.array_view()) {
		*entry = val;
	}
}
