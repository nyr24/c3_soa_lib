import std::io;
import std::collections::elastic_array;
import std::collections::list;
import soa;

struct MySoa <CAP>
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

struct MySoaViewHorizontal
{
	int[]   	ints;
	float[] 	floats;
	String[]	strs;
}

struct MySoaViewVertical
{
	int[]  	 	ints;
	String[] 	strs;
}

struct Value
{
	int    		int_val;
	float  		f_val;
	String 		str_val;
}

fn void Value.print(&self) {
	io::printfn("i: %d, f: %.2f, s: %s", self.int_val, self.f_val, self.str_val);
}

fn int main() {
	/* First example */

	const MEM_LEN = 3;
	const FIRST_EXAMPLE = true;
	const SEC_EXAMPLE = true;
	const THIRD_EXAMPLE = true;
	
	if (FIRST_EXAMPLE) {
		MySoa{10} my_soa;
		MySoa{10} my_soa2;

		Value soa_val = { 11, 0.1f, "first!" };
		Value soa_val2 = { 22, 0.2f, "sec!" };
		Value soa_val3 = { 33, 0.3f, "third!" };

		Value[] soa_val_slice = { soa_val, soa_val2, soa_val3, soa_val, soa_val2, soa_val3 };

		soa::@push_all(my_soa, soa_val_slice);

		usz len = soa::@size(my_soa);
		usz cap = soa::@cap(my_soa);
		// io::printfn("Stack-allocated SOA: len: %d, cap: %d", len, cap);

		MySoaViewHorizontal soa_view;
		soa::@soa_view(my_soa, soa_view);

		usz view_len = soa::@len(soa_view);
		// io::printfn("View SOA: len: %d", view_len);

		MySoaViewHorizontal soa_view_partial_hor;
		soa::@soa_view_partial_hor(my_soa, soa_view_partial_hor, 0, 2);

		MySoaViewVertical soa_view_partial_vert;
		soa::@soa_view_partial_vert(my_soa, soa_view_partial_vert, { 0, 2 });

		// soa::@print(soa_view);
		// soa::@print(soa_view_partial_hor);
		// soa::@print(soa_view_partial_vert);
		
		usz not_entered_cnt = soa::@push_all_to_limit(my_soa2, soa_val_slice);
		// io::printfn("not entered count: %d", not_entered_cnt);

		bool[MEM_LEN] eq_res;
		soa::@equals(my_soa, my_soa2, eq_res[0:eq_res.len]);
		// io::printfn("res: %s", eq_res);

		soa::@remove_at(my_soa, 1);
		soa::@pop(my_soa)!!;
		soa::@pop_first(my_soa)!!;
		soa::@push_front(my_soa, soa_val2);
		soa::@push_front_try(my_soa, soa_val3)!!;
		soa::@remove_last(my_soa)!!;
		soa::@remove_first(my_soa)!!;
		soa::@reverse(my_soa);
		// soa::@print(my_soa);
	}

	/* Second example */

	if (SEC_EXAMPLE) {
		MySoa{100} my_soa;
		Value soa_val = { 13, 0.5f, "hello!" };

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

		Value set_val = { 228, 1337, "world" };
		soa::@set_at(my_soa, 3, set_val);
		Value get_val @noinit;
		soa::@get(my_soa, 3, &get_val);

		// soa::@print(my_soa);
		// io::printfn("get_val is: %d, %.2f, %s", get_val.int_val, get_val.f_val, get_val.str_val); // output: get_val: 228, 1337.00, world 
	}

	/* Third example */

	if (THIRD_EXAMPLE) {
		MyDynSoa my_soa;
		Value soa_val = { 13, 0.5f, "hello!" };

		soa::@init(my_soa, tmem, 101u);
		defer {
			// io::printn("\n\tdeferring free");
			soa::@free(my_soa);
		}

		soa::@set_size(my_soa, 28);
	
		for (uint i = 0; i < 3; ++i) {
			soa::@insert_at(my_soa, i, soa_val);
		}

		usz len = soa::@len(my_soa);
		usz cap = soa::@cap(my_soa);
		// io::printfn("Heap-allocated SOA: len: %d, cap: %d", len, cap);

		soa::@pop(my_soa)!!;
		soa::@clear(my_soa);
		soa::@set_size(my_soa, 8);
		// NOTE: comment out if have fill defined on std::collections::list
		// soa::@fill(my_soa, soa_val);
		soa::@push(my_soa, soa_val);
		soa::@reverse(my_soa);

		Value set_val = { 228, 1337, "world" };
		soa::@set_at(my_soa, 3, set_val);
		Value get_val @noinit;
		soa::@get(my_soa, 3, &get_val);

		// soa::@print(my_soa);
		// io::printfn("get_val is: %d, %.2f, %s", get_val.int_val, get_val.f_val, get_val.str_val); // output: get_val: 228, 1337.00, world 
	}

	return 0;
}
