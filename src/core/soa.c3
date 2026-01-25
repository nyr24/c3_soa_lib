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

macro @set_size(#soa, #size)
{
	@op_val(#soa, "set_size", #size);
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
	var $soa_mem = $SoaType.membersof[0];
	$if $soa_mem.kindof == TypeKind.SLICE:
		return #soa.$eval($soa_mem.nameof).len;
	$else
		return #soa.$eval($soa_mem.nameof).size;
	$endif
}

macro @size(#soa)
	=> @len(#soa);

macro usz @capacity(#soa)
{
	var $SoaType = $typeof(#soa);
	var $soa_mem = $SoaType.membersof[0];

	$switch:
	$case $soa_mem.kindof == TypeKind.SLICE:
		$assert(false);
	// assume its heap-allocated array
	$case has_field($soa_mem.typeid, "capacity"):
		return #soa.$eval($soa_mem.nameof).capacity;
	// assume its stack-allocated array
	$case has_field($soa_mem.typeid, "entries"):
		return #soa.$eval($soa_mem.nameof).entries.len;
	$endswitch;
}

macro usz @cap(#soa)
	=> @capacity(#soa);

macro @init(#soa, #alloc, uint #cap = 16u)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType.membersof;
	
	$foreach $m : $soa_members:
		#soa.$eval($m.nameof).init(#alloc, #cap);
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
	var $soa_members = $SoaType.membersof;
	
	$foreach $m : $soa_members:
		io::printn(#soa.$eval($m.nameof));
	$endforeach
}

macro @swap(#soa, usz #first, usz #second)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType.membersof;
	
	$foreach $m : $soa_members:
		#soa.$eval($m.nameof).swap(#first, #second);
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

	var $soa_members = $SoaType.membersof;
	var $out_members = $OutType.inner.membersof;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $out_mem = $out_members[$i];

		$switch $op:
		$case "first":
			#out.$eval($out_mem.nameof) = #soa.$eval($soa_mem.nameof).first()!;
		$case "last":
			#out.$eval($out_mem.nameof) = #soa.$eval($soa_mem.nameof).last()!;
		$case "get":
			#out.$eval($out_mem.nameof) = #soa.$eval($soa_mem.nameof)[#ind];
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

	var $soa_members = $SoaType.membersof;
	var $val_members = $ValType.membersof;

	usz[$soa_members.len] indices;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		indices[$i] = #soa.$eval($soa_mem.nameof).$eval($op)(#val.$eval($val_mem.nameof))!;
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

	var $soa_members = $SoaType.membersof;
	var $val_members = $ValType.inner.membersof;
	usz didnt_fit_cnt;

	$for var $i = 0; $i < $soa_members.len; $i++:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		var $Type = $val_mem.typeid;

		{
			$Type[] temp_arr = mem::alloc_array($Type, #vals.len);
			defer mem::free(temp_arr.ptr);

			for (uint i = 0; i < #vals.len; ++i) {
				temp_arr[i] = #vals[i].$eval($val_mem.nameof);
			}

			didnt_fit_cnt = #soa.$eval($soa_mem.nameof).push_all_to_limit(temp_arr[:#vals.len]);
		}
	$endfor
	return didnt_fit_cnt;
}

macro @soa_view(#soa, #out_view)
{
	var $SoaType = $typeof(#soa);
	var $OutType = $typeof(#out_view);
	var $soa_members = $SoaType.membersof;
	var $out_members = $OutType.membersof;

	$for var $i = 0; $i < $soa_members.len; ++$i:
		#out_view.$eval($out_members[$i].nameof) = #soa.$eval($soa_members[$i].nameof).array_view();
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
	var $soa_members = $SoaType.membersof;
	var $out_members = $OutType.membersof;

	assert(#start_ind < #soa.$eval($soa_members[0].nameof).size, "Start index should be at most = size - 1");
	assert(#end_ind <= #soa.$eval($soa_members[0].nameof).size, "End index would be out of bounds");

	$for var $i = 0; $i < $soa_members.len; ++$i:
		#out_view.$eval($out_members[$i].nameof) = #soa.$eval($soa_members[$i].nameof).entries[#start_ind..#end_ind];
	$endfor
}

// vertical partial view:
// creates views (slices) only for specified indices of fields in #field_indices
macro @soa_view_partial_vert(#soa, #out_view, usz[] $field_indices)
{
	var $SoaType = $typeof(#soa);
	var $OutType = $typeof(#out_view);
	var $soa_members = $SoaType.membersof;
	var $out_members = $OutType.membersof;

	var $i = 0;
	$foreach $field_ind : $field_indices:
		#out_view.$eval($out_members[$i].nameof) = #soa.$eval($soa_members[$field_ind].nameof).array_view();
		$i++;
	$endforeach
}

macro bool @contains(#soa, #val)
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	var $soa_members = $SoaType.membersof;
	var $val_members = $ValType.membersof;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		if (!#soa.$eval($soa_mem.nameof).contains(#val.$eval($val_mem.nameof))) {
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

	var $soa_members = $SoaType.membersof;
	var $val_members = $ValType.membersof;
	usz[$val_members.len] remove_res;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		remove_res[$i] = #soa.$eval($soa_mem.nameof).remove_item(#val.$eval($val_mem.nameof));
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

	var $soa_members = $SoaType.membersof;
	var $val_members = $ValType.membersof;
	bool[$val_members.len] remove_res;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		remove_res[$i] = #soa.$eval($soa_mem.nameof).$eval($op)(#val.$eval($val_mem.nameof));
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
	@require $typeof(#out_res).kindof == TypeKind.SLICE
*>
macro void @compact_inner(#soa, String $op, #out_res) @private
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType.membersof;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		$if has_method($soa_mem.typeid, $op):
			#out_res[$i] = #soa.$eval($soa_mem.nameof).$eval($op)();
		$else
			#out_res[$i] = 0u;
		$endif
	$endfor
}

<*
	@require $typeof(#soa) == $typeof(#with)
	@require $typeof(#out_res).kindof == TypeKind.SLICE
	@require $typeof(#out_res).inner.kindof == TypeKind.BOOL
*>
macro @equals(#soa, #with, #out_res)
{
	var $SoaType = $typeof(#soa);
	var $WithType = $typeof(#with);
	var $soa_members = $SoaType.membersof;
	var $with_members = $WithType.membersof;
	
	$for var $i = 0; $i < $soa_members.len; ++$i:
		var $soa_mem = $soa_members[$i];
		var $with_mem = $with_members[$i];
		#out_res[$i] = #soa.$eval($soa_mem.nameof).equals(#with.$eval($with_mem.nameof));
	$endfor
}

/* Generic API */

// e.g. clear(), reverse()
macro @op(#soa, String $op, bool $is_opt = false)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType.membersof;
	
	$foreach $soa_mem : $soa_members:
		$if $is_opt:
			#soa.$eval($soa_mem.nameof).$eval($op)()!;
		$else
			#soa.$eval($soa_mem.nameof).$eval($op)();
		$endif
	$endforeach
}

// e.g. push(), push_front(), set_size(), resize(), remove_at()
macro @op_val(#soa, String $op, #val, bool $is_opt = false)
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	$switch:
		$case $ValType.kindof == TypeKind.SLICE:
			var $soa_members = $SoaType.membersof;
			var $val_members = $ValType.inner.membersof;

			$for var $i = 0; $i < $soa_members.len; $i++:
				var $soa_mem = $soa_members[$i];
				var $val_mem = $val_members[$i];
				var $Type = $val_mem.typeid;

				{
					$Type[] temp_arr = mem::alloc_array($Type, #val.len);
					defer mem::free(temp_arr.ptr);

					for (uint i = 0; i < #val.len; ++i) {
						temp_arr[i] = #val[i].$eval($val_mem.nameof);
					}

					$if $is_opt:
						#soa.$eval($soa_mem.nameof).$eval($op)(temp_arr[:#val.len])!;
					$else
						#soa.$eval($soa_mem.nameof).$eval($op)(temp_arr[:#val.len]);
					$endif
				}
			$endfor
		$case $ValType.kindof == TypeKind.STRUCT:
			var $soa_members = $SoaType.membersof;
			var $val_members = $ValType.membersof;

			$for var $i = 0; $i < $soa_members.len; $i++:
				var $soa_mem = $soa_members[$i];
				var $val_mem = $val_members[$i];

				$if $is_opt:
					#soa.$eval($soa_mem.nameof).$eval($op)(#val.$eval($val_mem.nameof))!;
				$else
					#soa.$eval($soa_mem.nameof).$eval($op)(#val.$eval($val_mem.nameof));
				$endif
			$endfor
		$case $ValType.kindof == TypeKind.SIGNED_INT || $ValType.kindof == TypeKind.UNSIGNED_INT:
			var $soa_members = $SoaType.membersof;

			$foreach $soa_mem : $soa_members:
				$if $is_opt:
					#soa.$eval($soa_mem.nameof).$eval($op)(#val)!;
				$else
					#soa.$eval($soa_mem.nameof).$eval($op)(#val);
				$endif
			$endforeach
	$endswitch
}

// e.g. insert_at(), set_at(), insert_at_try()
macro @op_index_val(#soa, String $op, #index, #val, bool $is_opt = false)
{
	var $SoaType = $typeof(#soa);
	var $ValType = $typeof(#val);

	var $soa_members = $SoaType.membersof;
	var $val_members = $ValType.membersof;

	$for var $i = 0; $i < $soa_members.len; $i++:
		var $soa_mem = $soa_members[$i];
		var $val_mem = $val_members[$i];
		
		$if $is_opt:
			#soa.$eval($soa_mem.nameof).$eval($op)(#index, #val.$eval($val_mem.nameof))!;
		$else
			#soa.$eval($soa_mem.nameof).$eval($op)(#index, #val.$eval($val_mem.nameof));
		$endif
	$endfor
}

macro has_method($Type, String $name) @const
{
	var $methods = $Type.methodsof;
	$foreach $m : $methods:
		$if ($m == $name):
			return true;
		$endif
	$endforeach
	return false;
}

macro has_field($Type, String $name) @const
{
	var $members = $Type.membersof;
	$foreach $m : $members:
		$if ($m.nameof == $name):
			return true;
		$endif
	$endforeach
	return false;
}
