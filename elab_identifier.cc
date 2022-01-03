/*
 * Copyright (c) 2021 Stephen Williams (steve@icarus.com)
 *
 *    This source code is free software; you can redistribute it
 *    and/or modify it in source code form under the terms of the GNU
 *    General Public License as published by the Free Software
 *    Foundation; either version 2 of the License, or (at your option)
 *    any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

# include "config.h"
# include  <typeinfo>
# include  <cstdlib>
# include  <cstring>
# include  <climits>
# include "compiler.h"

# include  "PPackage.h"
# include  "pform.h"
# include  "netlist.h"
# include  "netclass.h"
# include  "netenum.h"
# include  "netparray.h"
# include  "netvector.h"
# include  "discipline.h"
# include  "netmisc.h"
# include  "netdarray.h"
# include  "netqueue.h"
# include  "netstruct.h"
# include  "netscalar.h"
# include  "util.h"
# include  "ivl_assert.h"

NetExpr *make_select(const LineInfo &li,
	NetExpr *sig, NetExpr *base, ivl_type_t type)
{
	sig = new NetESelect(sig, base, type->packed_width(), type);
	sig->set_line(li);
	return sig;
}

ivl_type_t path_resolve_struct_type(const LineInfo &li, Design *des, NetScope *scope,
								const netstruct_t *type, pform_name_t &path,
							 NetExpr*&sig)
{
      if (!type->packed()) {
		std::cerr << li.get_fileline() << "Sorry: unpacked struct not supported yet" << std::endl;
	    return 0;
	}

	// Leave indexing to the caller
	if (!path.front().index.empty())
		return type;

	// Continue to the next path element
	path.pop_front();

	// We are done, this is the full struct
	if (path.empty())
		return type;

	// If there are more elements this must be a struct member
	unsigned long off;
	auto member_name = path.front().name;
	const netstruct_t::member_t*mem = type->packed_member(member_name, off);
	if (!mem) {
		std::cerr << li.get_fileline() << ": Struct does not have a member `" << member_name << "`" << std::endl;
		return 0;
	  }

	  if (sig != 0) {
		NetEConst *base = make_const_val(off);
		base->set_line(li);
		sig = make_select(li, sig, base, mem->net_type);
	  }

	  return path_resolve_type(li, des, scope, mem->net_type, path, sig);
}

ivl_type_t path_resolve_sarray_type(const LineInfo &li, Design *des, NetScope *scope,
								const netsarray_t*sarray, pform_name_t &path,
							 NetExpr*&sig)
{
    name_component_t&head = path.front();

	if (head.index.empty()) {
		path.pop_front();
		return sarray;
	}

	auto dims = sarray->static_dimensions();

	// Consume as many indices as possible, handling part selects is up to the
	// caller
	while (!dims.empty() && !head.index.empty()) {
		if (head.index.front().sel != index_component_t::SEL_BIT)
			break;
		head.index.pop_front();
		dims.erase(dims.begin());
	}

	if (!dims.empty()) {
		if (dynamic_cast<const netuarray_t*>(sarray)) {
			std::cerr << li.get_fileline() << "Sorry: array slices are not supported yet" << std::endl;
			return 0;
		}

		// Create a new type with the remaining dimensions
		return new netparray_t(dims, sarray->element_type());
	}

	return path_resolve_type(li, des, scope, sarray->element_type(), path, sig);

}

ivl_type_t path_resolve_darray_type(const LineInfo &li, Design *des, NetScope *scope,
								const netdarray_t* darray, pform_name_t &path,
							 NetExpr*&sig)
{
    name_component_t&head = path.front();

	if (head.index.empty()) {
		path.pop_front();
		return darray;
	}

	switch (head.index.front().sel) {
	case index_component_t::SEL_BIT:
	case index_component_t::SEL_BIT_LAST:
		break;
	default:
		std::cerr << li.get_fileline() << "error: part index not supported on dynamic array" << std::endl;
		des->errors++;
		break;
	}

	if (sig) {
		NetExpr*mux = elab_and_eval(des, scope, head.index.front().msb, -1, false);
	    if (!mux)
			mux->set_line(li);
		sig = make_select(li, sig, mux, darray->element_type());
	}

	// Consume one index and continue
	head.index.pop_front();
	if (head.index.empty()) {
		path.pop_front();
		return darray->element_type();
	}
	return path_resolve_type(li, des, scope, darray->element_type(), path, sig);
}

ivl_type_t path_resolve_string_type(const LineInfo &li, Design *des, NetScope *scope,
								const netstring_t* type, pform_name_t &path,
							 NetExpr*&sig)
{
    auto& head_index = path.front().index;

	// String has no members
	if (head_index.empty()) {
		path.pop_front();
		return type;
	}

	switch (head_index.front().sel) {
	case index_component_t::SEL_BIT:
		break;
	default:
		std::cerr << li.get_fileline() << "error: part index not supported on string" << std::endl;
		des->errors++;
		break;
	}

	if (sig) {
		NetExpr*mux = elab_and_eval(des, scope, head_index.front().msb, -1, false);
	    if (!mux)
		  return 0;
		mux->set_line(li);
		sig = make_select(li, sig, mux,  &netvector_t::atom2u8);
	}

	// Index into a string returns a byte
	head_index.pop_front();
	if (head_index.empty())
		path.pop_front();
	return &netvector_t::atom2u8;
}

ivl_type_t path_resolve_class_type(const LineInfo &li, Design *des, NetScope *scope,
							const netclass_t* type, pform_name_t &path,
							 NetExpr*&sig)
{
	// Class types can not be indexed
	if (!path.front().index.empty()) {
		std::cerr << "Class can not be indexed\n" << std::endl;
		des->errors++;
		return 0;
	}

	path.pop_front();
	if (path.empty())
		return type;

	int pidx = type->property_idx_from_name(path.front().name);
	if (pidx < 0) {
		std::cerr << li.get_fileline() << "Class has no property " << path.front().name << std::endl;
		des->errors++;
		return 0;
	}

	property_qualifier_t qual = type->get_prop_qual(pidx);
	if (qual.test_local() && ! type->test_scope_is_method(scope)) {
		std::cerr << li.get_fileline() << ": error: "
		 << "Local property " << type->get_prop_name(pidx)
		 << " is not accessible in this context."
		 << " (scope=" << scope_path(scope) << ")" << std::endl;
	    des->errors += 1;
	}

	return path_resolve_type(li, des, scope, type->get_prop_type(pidx), path, sig);
}

ivl_type_t path_resolve_type(const LineInfo &li, Design *des, NetScope *scope,
						     const ivl_type_t type, pform_name_t &path,
							 NetExpr*&sig)
{
	ivl_assert(li, !path.empty());

    name_component_t&head = path.front();

	std::cout << li.get_fileline() << "looking at " << *type << " " << head.name << "/" << head.index.size() << std::endl;

    if (const netstruct_t*stype = dynamic_cast<const netstruct_t*>(type)) {
		return path_resolve_struct_type(li, des, scope, stype, path, sig);
	} else if (const netsarray_t*sarray = dynamic_cast<const netsarray_t*>(type)) {
		return path_resolve_sarray_type(li, des, scope, sarray, path, sig);
	} else if (const netdarray_t*darray= dynamic_cast<const netdarray_t*> (type)) {
		return path_resolve_darray_type(li, des, scope, darray, path, sig);
	} else if (const netclass_t*ctype = dynamic_cast<const netclass_t*> (type)) {
		return path_resolve_class_type(li, des, scope, ctype, path, sig);
	} else if (const netstring_t*strtype = dynamic_cast<const netstring_t*> (type)) {
		return path_resolve_string_type(li, des, scope, strtype, path, sig);
	}

	if (path.front().index.empty())
		path.pop_front();

	return type;
}
