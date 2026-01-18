module learn;

import std::io;
import std::collections::elastic_array;
import std::collections::list;
import soa;

struct MySoa @generic(CAP)
{
	ElasticArray{int, CAP}    ints;
	ElasticArray{float, CAP}  floats;
	ElasticArray{String, CAP} strs;
}

struct MyDynSoa
{
	List{int}    ints;
	List{float}  floats;
	List{String} strs;
}

struct SoaVal {
	int int_val;
	float f_val;
	String str_val;
}

fn void SoaVal.print(&self) {
	io::printfn("i: %d, f: %.2f, s: %s", self.int_val, self.f_val, self.str_val);
}

fn int main(String[] args) {
	/* First example */

	const MEM_LEN = 3;
	{
		MySoa{10} my_soa;
		MySoa{10} my_soa2;

		SoaVal soa_val = { 11, 0.1f, "first!" };
		SoaVal soa_val2 = { 22, 0.2f, "sec!" };
		SoaVal soa_val3 = { 33, 0.3f, "third!" };

		SoaVal[] soa_val_slice = { soa_val, soa_val2, soa_val3, soa_val, soa_val2, soa_val3 };

		soa::@soa_push_all(my_soa, soa_val_slice);
		usz not_entered_cnt = soa::@soa_push_all_to_limit(my_soa2, soa_val_slice);
		io::printfn("not entered count: %d", not_entered_cnt);

		bool[MEM_LEN] eq_res;
		soa::@soa_equals(my_soa, my_soa2, eq_res[0:eq_res.len]);
		io::printfn("res: %s", eq_res);

		soa::@soa_remove_at(my_soa, 1);
		soa::@soa_pop(my_soa)!!;
		soa::@soa_pop_first(my_soa)!!;
		soa::@soa_push_front(my_soa, soa_val2);
		soa::@soa_push_front_try(my_soa, soa_val3)!!;
		soa::@soa_remove_last(my_soa)!!;
		soa::@soa_remove_first(my_soa)!!;
		soa::@soa_reverse(my_soa);
		soa::@soa_print(my_soa);
	}

	/* Second example */

	{
		MySoa{100} my_soa;
		SoaVal soa_val = { 13, 0.5f, "hello!" };

		soa::@soa_set_size(my_soa, 10);
	
		for (uint i = 0; i < 3; ++i) {
			soa::@soa_insert_at(my_soa, i, soa_val);
		}
		soa::@soa_pop(my_soa)!!;
		soa::@soa_clear(my_soa);
		soa::@soa_set_size(my_soa, 8);
		// NOTE: comment out if have fill defined on std::collections::elastic_array
		// soa::@soa_fill(my_soa, soa_val);
		soa::@soa_push(my_soa, soa_val);
		soa::@soa_reverse(my_soa);

		SoaVal set_val = { 228, 1337, "world" };
		soa::@soa_set_at(my_soa, 3, set_val);
		SoaVal get_val @noinit;
		soa::@soa_get(my_soa, 3, &get_val);

		soa::@soa_print(my_soa);

		io::printfn("get_val is: %d, %.2f, %s", get_val.int_val, get_val.f_val, get_val.str_val); // output: get_val: 228, 1337.00, world 
	}

	/* Third example */

	{
		MyDynSoa my_soa;
		SoaVal soa_val = { 13, 0.5f, "hello!" };

		soa::@soa_init(my_soa, tmem, 100u);
		defer {
			io::printn("\n\tdeferring free");
			soa::@soa_free(my_soa);
		}

		soa::@soa_set_size(my_soa, 10);
	
		for (uint i = 0; i < 3; ++i) {
			soa::@soa_insert_at(my_soa, i, soa_val);
		}
		soa::@soa_pop(my_soa)!!;
		soa::@soa_clear(my_soa);
		soa::@soa_set_size(my_soa, 8);
		// NOTE: comment out if have fill defined on std::collections::list
		// soa::@soa_fill(my_soa, soa_val);
		soa::@soa_push(my_soa, soa_val);
		soa::@soa_reverse(my_soa);

		SoaVal set_val = { 228, 1337, "world" };
		soa::@soa_set_at(my_soa, 3, set_val);
		SoaVal get_val @noinit;
		soa::@soa_get(my_soa, 3, &get_val);

		soa::@soa_print(my_soa);

		io::printfn("get_val is: %d, %.2f, %s", get_val.int_val, get_val.f_val, get_val.str_val); // output: get_val: 228, 1337.00, world 
	}

	return 0;
}
