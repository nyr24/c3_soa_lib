module soa;

import std::io;

macro @soa_push(#soa, #val)
{
	@soa_op_val(#soa, "push", #val);
}

macro @soa_push_all(#soa, #vals)
{
	@soa_op_val(#soa, "push_all", #vals);
}

macro @soa_push_front(#soa, #val)
{
	@soa_op_val(#soa, "push_front", #val);
}

macro @soa_push_try(#soa, #val)
{
	@soa_op_val(#soa, "push_try", #val, true)!;
}

macro @soa_push_front_try(#soa, #val)
{
	@soa_op_val(#soa, "push_front_try", #val, true)!;
}

macro @soa_pop(#soa)
{
	@soa_op(#soa, "pop", true)!;
}

macro @soa_pop_first(#soa)
{
	@soa_op(#soa, "pop_first", true)!;
}

macro @soa_insert_at(#soa, #ind, #val)
{
	@soa_op_index_val(#soa, "insert_at", #ind, #val);
}

macro @soa_insert_at_try(#soa, #ind, #val)
{
	@soa_op_index_val(#soa, "insert_at_try", #ind, #val, true)!;
}

macro @soa_fill(#soa, #val)
{
	@soa_op_val(#soa, "fill", #val);
}

macro @soa_set_at(#soa, #ind, #val)
{
	@soa_op_index_val(#soa, "set_at", #ind, #val);
}

macro @soa_remove_at(#soa, #ind)
{
	@soa_op_val(#soa, "remove_at", #ind);
}

macro @soa_remove_last(#soa)
{
	@soa_op(#soa, "remove_last", true)!;
}

macro @soa_remove_first(#soa)
{
	@soa_op(#soa, "remove_first", true)!;
}

macro @soa_set_size(#soa, #size)
{
	@soa_op_val(#soa, "set_size", #size);
}

macro @soa_ensure_capacity(#soa, #cap)
{
	@soa_op_val(#soa, "ensure_capacity", #cap);
}

macro @soa_clear(#soa)
{
	@soa_op(#soa, "clear");
}

macro @soa_free(#soa)
{
	@soa_op(#soa, "free");
}

macro @soa_reverse(#soa)
{
	@soa_op(#soa, "reverse");
}

macro @soa_init(#soa, #alloc, uint #cap = 16u)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType.membersof;
	
	$foreach $m : $soa_members:
		#soa.$eval($m.nameof).init(#alloc, #cap);
	$endforeach
}

macro @soa_tinit(#soa, uint #cap = 16u)
{
	@soa_op_val(#soa, "tinit", #cap);
}

macro @soa_reserve(#soa, uint #cap)
{
	@soa_op_val(#soa, "reserve", #cap);
}

macro @soa_print(#soa)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType.membersof;
	
	$foreach $m : $soa_members:
		io::printn(#soa.$eval($m.nameof));
	$endforeach
}

macro @soa_swap(#soa, usz #first, usz #second)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType.membersof;
	
	$foreach $m : $soa_members:
		#soa.$eval($m.nameof).swap(#first, #second);
	$endforeach
}

macro @soa_first(#soa, #out)
{
	@soa_at(#soa, "first", 0, #out)!;
}

macro @soa_last(#soa, #out)
{
	@soa_at(#soa, "last", 0, #out)!;
}

macro @soa_get(#soa, uint #ind, #out)
{
	@soa_at(#soa, "get", #ind, #out);
}

<*
	@require $op == "first" || $op == "last" || $op == "get"
	@require #out != null
*>
macro @soa_at(#soa, String $op, uint #ind, #out) @private
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

macro usz? @soa_index_of(#soa, #val)
{
	return @soa_index_of_inner(#soa, "index_of", #val);
}

macro usz? @soa_rindex_of(#soa, #val)
{
	return @soa_index_of_inner(#soa, "rindex_of", #val);
}

<*
	@require $op == "index_of" || $op =="rindex_of"
*>
macro usz? @soa_index_of_inner(#soa, String $op, #val) @private
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
			return NOT_FOUND?;
		}
	}
	return indices[0];
}

<*
	Add as many values from this array as possible, returning the
	number of elements that didn't fit.
*>
macro usz @soa_push_all_to_limit(#soa, #vals)
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

macro @soa_array_view(#soa, #i)
{
	var $SoaType = $typeof(#soa);
	var $soa_members = $SoaType.membersof;
	assert(#i >= 0 && #i < $soa_members.len, "Out of bounds");
	return #soa.$eval($soa_members[#i].nameof).array_view();
}

macro bool @soa_contains(#soa, #val)
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
macro usz @soa_remove_item(#soa, #val)
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

macro bool @soa_remove_last_item(#soa, #val)
{
	return @soa_remove_item_inner(#soa, "remove_last_item", #val);
}

macro bool @soa_remove_first_item(#soa, #val)
{
	return @soa_remove_item_inner(#soa, "remove_first_item", #val);
}

<*
	@require $op =="remove_first_item" || $op == "remove_last_item"
*>
macro bool @soa_remove_item_inner(#soa, String $op, #val) @private
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
macro @soa_compact_count(#soa, #out_res)
{
	@soa_compact_inner(#soa, "compact_count", #out_res);
}

<*
	Requires a list of pointers
	@return "the number of deleted null elements."
*>
macro @soa_compact(#soa, #out_res)
{
	@soa_compact_inner(#soa, "compact", #out_res);
}

<*
	@require $op == "compact" || $op == "compact_count"
	@require $typeof(#out_res).kindof == TypeKind.SLICE
*>
macro void @soa_compact_inner(#soa, String $op, #out_res) @private
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
macro @soa_equals(#soa, #with, #out_res)
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
macro @soa_op(#soa, String $op, bool $is_opt = false)
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
macro @soa_op_val(#soa, String $op, #val, bool $is_opt = false)
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
macro @soa_op_index_val(#soa, String $op, #index, #val, bool $is_opt = false)
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
