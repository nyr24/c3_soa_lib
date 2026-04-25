module soa;

import std::io;

macro @push(#soa, #val)
{
	@op_val(#soa, "push", #val);
}

macro @push_all(#soa, #vals)
{
	@op_val(#soa, "push_all", #vals);
}

macro @push_front(#soa, #val)
{
	@op_val(#soa, "push_front", #val);
}

macro @push_try(#soa, #val)
{
	@op_val(#soa, "push_try", #val, true)!;
}

macro @push_front_try(#soa, #val)
{
	@op_val(#soa, "push_front_try", #val, true)!;
}

macro @pop(#soa)
{
	@op(#soa, "pop", true)!;
}

macro @pop_first(#soa)
{
	@op(#soa, "pop_first", true)!;
}

macro @insert_at(#soa, #ind, #val)
{
	@op_index_val(#soa, "insert_at", #ind, #val);
}

macro @insert_at_try(#soa, #ind, #val)
{
	@op_index_val(#soa, "insert_at_try", #ind, #val, true)!;
}

macro @fill(#soa, #val)
{
	@op_val(#soa, "fill", #val);
}

macro @set_at(#soa, #ind, #val)
{
	@op_index_val(#soa, "set_at", #ind, #val);
}

macro @remove_at(#soa, #ind)
{
	@op_val(#soa, "remove_at", #ind);
}

macro @remove_last(#soa)
{
	@op(#soa, "remove_last", true)!;
}

macro @remove_first(#soa)
{
	@op(#soa, "remove_first", true)!;
}

macro @ensure_capacity(#soa, #cap)
{
	@op_val(#soa, "ensure_capacity", #cap);
}

macro @clear(#soa)
{
	@op(#soa, "clear");
}

macro @free(#soa)
{
	@op(#soa, "free");
}

macro @reverse(#soa)
{
	@op(#soa, "reverse");
}

macro @len(#soa)
{
	var $SoaType = $typeof(#soa);
	var $soa_mem = $SoaType::members[0];
	$if $soa_mem.type.kind == SLICE:
		return #soa.$eval($soa_mem.name).len;
	$else
		return #soa.$eval($soa_mem.name).size;
	$endif
}

macro @size(#soa)
	=> @len(#soa);

macro usz @capacity(#soa)
{
	var $SoaType = $typeof(#soa);
	var $soa_mem = $SoaType::members[0];

	$switch:
	$case $soa_mem.type.kind == SLICE:
		$assert(false);
	// assume its heap-allocated array
	$case has_field($soa_mem.type, "capacity"):
		return #soa.$eval($soa_mem.name).capacity;
	// assume its stack-allocated array
	$case has_field($soa_mem.type, "entries"):
		return #soa.$eval($soa_mem.name).entries.len;
	$endswitch;
}

macro usz @cap(#soa)
	=> @capacity(#soa);

macro @init(#soa, #alloc, uint #cap = 16u)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType::members;
	
	$foreach $m : $soa_members:
		#soa.$eval($m.name).init(#alloc, #cap);
	$endforeach
}

macro @tinit(#soa, uint #cap = 16u)
{
	@op_val(#soa, "tinit", #cap);
}

macro @reserve(#soa, uint #cap)
{
	@op_val(#soa, "reserve", #cap);
}

macro @print(#soa)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType::members;
	
	$foreach $m : $soa_members:
		io::printn(#soa.$eval($m.name));
	$endforeach
}

macro @swap(#soa, usz #first, usz #second)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType::members;
	
	$foreach $m : $soa_members:
		#soa.$eval($m.name).swap(#first, #second);
	$endforeach
}

macro @first(#soa, #out)
{
	@at(#soa, "first", 0, #out)!;
}

macro @last(#soa, #out)
{
	@at(#soa, "last", 0, #out)!;
}

macro @get(#soa, uint #ind, #out)
{
	@at(#soa, "get", #ind, #out);
}

<*
 @require $op == "first" || $op == "last" || $op == "get"
 @require #out != null
*>
macro @at(#soa, String $op, uint #ind, #out) @private
{
	var $SoaType = $typeof(#soa);
	var $OutType = $typeof(#out);

	var $soa_members = $SoaType::members;
	var $out_members = $OutType::inner.members;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $out_mem = $out_members[$i];

		$switch $op:
		$case "first":
			#out.$eval($out_mem.name) = #soa.$eval($soa_mem.name).first()!;
		$case "last":
			#out.$eval($out_mem.name) = #soa.$eval($soa_mem.name).last()!;
		$case "get":
			#out.$eval($out_mem.name) = #soa.$eval($soa_mem.name)[#ind];
		$endswitch
	$endfor
}

macro usz? @index_of(#soa, #val)
{
	return @index_of_inner(#soa, "index_of", #val);
}

macro usz? @rindex_of(#soa, #val)
{
	return @index_of_inner(#soa, "rindex_of", #val);
}

<*
 @require $op == "index_of" || $op =="rindex_of"
*>
macro usz? @index_of_inner(#soa, String $op, #val) @private
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	var $soa_members = $SoaType::members;
	var $val_members = $ValType::members;

	usz[$soa_members.len] indices;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		indices[$i] = #soa.$eval($soa_mem.name).$eval($op)(#val.$eval($val_mem.name))!;
	$endfor

	for (uint j = 1; j < $soa_members.len; ++j) {
		if (indices[0] != indices[j]) {
			return NOT_FOUND~;
		}
	}
	return indices[0];
}

<*
	Add as many values from this array as possible, returning the
	number of elements that didn't fit.
*>
macro usz @push_all_to_limit(#soa, #vals)
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#vals);

	var $soa_members = $SoaType::members;
	var $val_members = $ValType::inner.members;
	usz didnt_fit_cnt;

	$for var $i = 0; $i < $soa_members.len; $i++:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		var $Type = $val_mem.type;

		{
			$Type[] temp_arr = alloc::alloc_array(tmem, $Type, #vals.len);
			defer alloc::free(tmem, temp_arr.ptr);

			for (uint i = 0; i < #vals.len; ++i) {
				temp_arr[i] = #vals[i].$eval($val_mem.name);
			}

			didnt_fit_cnt = #soa.$eval($soa_mem.name).push_all_to_limit(temp_arr[:#vals.len]);
		}
	$endfor
	return didnt_fit_cnt;
}

macro @soa_view(#soa, #out_view)
{
	var $SoaType = $typeof(#soa);
	var $OutType = $typeof(#out_view);
	var $soa_members = $SoaType::members;
	var $out_members = $OutType::members;

	$for var $i = 0; $i < $soa_members.len; ++$i:
		#out_view.$eval($out_members[$i].name) = #soa.$eval($soa_members[$i].name).array_view();
	$endfor
}

// horizontal partial view:
// slices all arrays from #start_ind to #end_ind
<*
 @require #start_ind >= 0
 @require #end_ind > 0
 @require #start_ind < #end_ind
*>
macro @soa_view_partial_hor(#soa, #out_view, usz #start_ind, usz #end_ind)
{
	var $SoaType = $typeof(#soa);
	var $OutType = $typeof(#out_view);
	var $soa_members = $SoaType::members;
	var $out_members = $OutType::members;

	assert(#start_ind < #soa.$eval($soa_members[0].name).size, "Start index should be at most = size - 1");
	assert(#end_ind <= #soa.$eval($soa_members[0].name).size, "End index would be out of bounds");

	$for var $i = 0; $i < $soa_members.len; ++$i:
		#out_view.$eval($out_members[$i].name) = #soa.$eval($soa_members[$i].name).entries[#start_ind..#end_ind];
	$endfor
}

// vertical partial view:
// creates views (slices) only for specified indices of fields in #field_indices
macro @soa_view_partial_vert(#soa, #out_view, usz[] $field_indices)
{
	var $SoaType = $typeof(#soa);
	var $OutType = $typeof(#out_view);
	var $soa_members = $SoaType::members;
	var $out_members = $OutType::members;

	var $i = 0;
	$foreach $field_ind : $field_indices:
		#out_view.$eval($out_members[$i].name) = #soa.$eval($soa_members[$field_ind].name).array_view();
		$i++;
	$endforeach
}

macro bool @contains(#soa, #val)
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	var $soa_members = $SoaType::members;
	var $val_members = $ValType::members;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		if (!#soa.$eval($soa_mem.name).contains(#val.$eval($val_mem.name))) {
			return false;
		}
	$endfor

	return true;
}

<*
 @return "the number of deleted elements."
*>
macro usz @remove_item(#soa, #val)
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	var $soa_members = $SoaType::members;
	var $val_members = $ValType::members;
	usz[$val_members.len] remove_res;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		remove_res[$i] = #soa.$eval($soa_mem.name).remove_item(#val.$eval($val_mem.name));
	$endfor
	return remove_res[0];
}

macro bool @remove_last_item(#soa, #val)
{
	return @remove_item_inner(#soa, "remove_last_item", #val);
}

macro bool @remove_first_item(#soa, #val)
{
	return @remove_item_inner(#soa, "remove_first_item", #val);
}

<*
 @require $op =="remove_first_item" || $op == "remove_last_item"
*>
macro bool @remove_item_inner(#soa, String $op, #val) @private
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	var $soa_members = $SoaType::members;
	var $val_members = $ValType::members;
	bool[$val_members.len] remove_res;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		remove_res[$i] = #soa.$eval($soa_mem.name).$eval($op)(#val.$eval($val_mem.name));
	$endfor

	for (uint i = 0; i < $val_members.len; ++i) {
		if (!remove_res[i]) {
			return false;
		}
	}
	return true;
}

<*
 Requires a list of pointers
 @return "The number non-null values in the list"
*>
macro @compact_count(#soa, #out_res)
{
	@compact_inner(#soa, "compact_count", #out_res);
}

<*
 Requires a list of pointers
 @return "the number of deleted null elements."
*>
macro @compact(#soa, #out_res)
{
	@compact_inner(#soa, "compact", #out_res);
}

<*
 @require $op == "compact" || $op == "compact_count"
 @require $typeof(#out_res).type.kind == SLICE
*>
macro void @compact_inner(#soa, String $op, #out_res) @private
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType::members;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		$if has_method($soa_mem.type, $op):
			#out_res[$i] = #soa.$eval($soa_mem.name).$eval($op)();
		$else
			#out_res[$i] = 0u;
		$endif
	$endfor
}

<*
 @require $typeof(#soa) == $typeof(#with)
 @require $typeof(#out_res)::kind == SLICE
 @require $reflect(#out_res).type.inner.kind == BOOL
*>
macro void @equals(#soa, #with, #out_res)
{
	var $SoaType = $typeof(#soa);
	var $WithType = $typeof(#with);
	var $soa_members = $SoaType::members;
	var $with_members = $WithType::members;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $with_mem = $with_members[$i];
		#out_res[$i] = #soa.$eval($soa_mem.name).equals(#with.$eval($with_mem.name));
	$endfor
}

macro void @resize(#soa, sz #val)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType::members;
	
	$foreach $mem : $soa_members:
		#soa.$eval($mem.name).size = #val;
	$endforeach
}

macro void @set_size(#soa, sz #val) => @resize(#soa, #val);

/* Generic API */

// e.g. clear(), reverse()
macro @op(#soa, String $op, bool $is_opt = false)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType::members;
	
	$foreach $soa_mem : $soa_members:
		$if $is_opt:
			#soa.$eval($soa_mem.name).$eval($op)()!;
		$else
			#soa.$eval($soa_mem.name).$eval($op)();
		$endif
	$endforeach
}

// e.g. push(), push_front(), set_size(), resize(), remove_at()
macro @op_val(#soa, String $op, #val, bool $is_opt = false)
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	$switch:
		$case $ValType::kind == SLICE:
			var $soa_members = $SoaType::members;
			var $val_members = $ValType::inner.members;

			$for var $i = 0; $i < $soa_members.len; $i++:
				var $soa_mem = $soa_members[$i];
				var $val_mem = $val_members[$i];
				var $Type = $val_mem.type;

				{
					$Type[] temp_arr = alloc::alloc_array(tmem, $Type, #val.len);
					defer alloc::free(tmem, temp_arr.ptr);

					for (uint i = 0; i < #val.len; ++i) {
						temp_arr[i] = #val[i].$eval($val_mem.name);
					}

					$if $is_opt:
						#soa.$eval($soa_mem.name).$eval($op)(temp_arr[:#val.len])!;
					$else
						#soa.$eval($soa_mem.name).$eval($op)(temp_arr[:#val.len]);
					$endif
				}
			$endfor
		$case $ValType::kind == STRUCT:
			var $soa_members = $SoaType::members;
			var $val_members = $ValType::members;

			$for var $i = 0; $i < $soa_members.len; $i++:
				var $soa_mem = $soa_members[$i];
				var $val_mem = $val_members[$i];

				$if $is_opt:
					#soa.$eval($soa_mem.name).$eval($op)(#val.$eval($val_mem.name))!;
				$else
					#soa.$eval($soa_mem.name).$eval($op)(#val.$eval($val_mem.name));
				$endif
			$endfor
		$case $ValType::kind == SIGNED_INT || $ValType::kind == UNSIGNED_INT:
			var $soa_members = $SoaType::members;

			$foreach $soa_mem : $soa_members:
				$if $is_opt:
					#soa.$eval($soa_mem.name).$eval($op)(#val)!;
				$else
					#soa.$eval($soa_mem.name).$eval($op)(#val);
				$endif
			$endforeach
	$endswitch
}

// e.g. insert_at(), set_at(), insert_at_try()
macro @op_index_val(#soa, String $op, #index, #val, bool $is_opt = false)
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	var $soa_members = $SoaType::members;
	var $val_members = $ValType::members;

	$for var $i = 0; $i < $soa_members.len; $i++:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		
		$if $is_opt:
			#soa.$eval($soa_mem.name).$eval($op)(#index, #val.$eval($val_mem.name))!;
		$else
			#soa.$eval($soa_mem.name).$eval($op)(#index, #val.$eval($val_mem.name));
		$endif
	$endfor
}

macro bool has_method($Type, String $name) @const
{
	var $methods = $Type.methodsof;
	$foreach $m : $methods:
		$if ($m == $name):
			return true;
		$endif
	$endforeach
	return false;
}

macro bool has_field($Type, String $name) @const
{
	var $members = $Type::members;
	$foreach $m : $members:
		$if ($m.name == $name):
			return true;
		$endif
	$endforeach
	return false;
}
