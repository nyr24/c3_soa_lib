## Simple library for operating on SOA (Structure Of Arrays) in C3 programming language

### Examples:
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

	...

	/* First example */
	const MEM_LEN = 3;
	{
		MySoa{10} my_soa;
		MySoa{10} my_soa2;

		SoaVal soa_val = { 11, 0.1f, "first!" };
		SoaVal soa_val2 = { 22, 0.2f, "sec!" };
		SoaVal soa_val3 = { 33, 0.3f, "third!" };

		SoaVal[] soa_val_slice = { soa_val, soa_val2, soa_val3, soa_val, soa_val2, soa_val3 };

		soa::@push_all(my_soa, soa_val_slice);
		usz not_entered_cnt = soa::@push_all_to_limit(my_soa2, soa_val_slice);
		io::printfn("not entered count: %d", not_entered_cnt);

		bool[MEM_LEN] eq_res;
		soa::@equals(my_soa, my_soa2, eq_res[0:eq_res.len]);
		io::printfn("res: %s", eq_res);

		soa::@remove_at(my_soa, 1);
		soa::@pop(my_soa)!!;
		soa::@pop_first(my_soa)!!;
		soa::@push_front(my_soa, soa_val2);
		soa::@push_front_try(my_soa, soa_val3)!!;
		soa::@remove_last(my_soa)!!;
		soa::@remove_first(my_soa)!!;
		soa::@reverse(my_soa);
		soa::@print(my_soa);
	}

	/* Second example */

	{
		MySoa{100} my_soa;
		SoaVal soa_val = { 13, 0.5f, "hello!" };

		soa::@set_size(my_soa, 10);
	
		for (uint i = 0; i < 3; ++i) {
			soa::@insert_at(my_soa, i, soa_val);
		}
		soa::@pop(my_soa)!!;
		soa::@clear(my_soa);
		soa::@set_size(my_soa, 8);
		// NOTE: comment out if have fill defined on std::collections::elastic_array
		// soa::@fill(my_soa, soa_val);
		soa::@push(my_soa, soa_val);
		soa::@reverse(my_soa);

		SoaVal set_val = { 228, 1337, "world" };
		soa::@set_at(my_soa, 3, set_val);
		SoaVal get_val @noinit;
		soa::@get(my_soa, 3, &get_val);

		soa::@print(my_soa);

		io::printfn("get_val is: %d, %.2f, %s", get_val.int_val, get_val.f_val, get_val.str_val); // output: get_val: 228, 1337.00, world 
	}

	/* Third example */

	{
		MyDynSoa my_soa;
		SoaVal soa_val = { 13, 0.5f, "hello!" };

		soa::@init(my_soa, tmem, 100u);
		defer {
			io::printn("\n\tdeferring free");
			soa::@free(my_soa);
		}

		soa::@set_size(my_soa, 10);
	
		for (uint i = 0; i < 3; ++i) {
			soa::@insert_at(my_soa, i, soa_val);
		}
		soa::@pop(my_soa)!!;
		soa::@clear(my_soa);
		soa::@set_size(my_soa, 8);
		// NOTE: comment out if have fill defined on std::collections::list
		// soa::@fill(my_soa, soa_val);
		soa::@push(my_soa, soa_val);
		soa::@reverse(my_soa);

		SoaVal set_val = { 228, 1337, "world" };
		soa::@set_at(my_soa, 3, set_val);
		SoaVal get_val @noinit;
		soa::@get(my_soa, 3, &get_val);

		soa::@print(my_soa);

		io::printfn("get_val is: %d, %.2f, %s", get_val.int_val, get_val.f_val, get_val.str_val); // output: get_val: 228, 1337.00, world 
	}
