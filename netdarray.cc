/*
 * Copyright (c) 2012-2020 Stephen Williams (steve@icarus.com)
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

# include  "netdarray.h"
# include  "netqueue.h"
# include  "netlist.h"
# include  "netvector.h"
# include  <iostream>

using namespace std;

netdarray_t::netdarray_t(ivl_type_t vec)
: netarray_t(vec)
{
}

netdarray_t::~netdarray_t()
{
}

ivl_variable_type_t netdarray_t::base_type(void) const
{
      return IVL_VT_DARRAY;
}

bool netdarray_t::test_compatibility(ivl_type_t that) const
{
      ivl_type_t elem_type = 0;

      if (const netdarray_t*that_da = dynamic_cast<const netdarray_t*>(that))
	    elem_type = that_da->element_type();

      if (const netqueue_t*that_q = dynamic_cast<const netqueue_t*>(that))
            elem_type = that_q->element_type();

      if (elem_type == 0)
	    return false;

      return element_type()->type_compatible(elem_type);
}

ivl_type_t netdarray_t::method_get_type(Design*, NetScope*,
				      const perm_string &method_name) const
{
      if (method_name == "size") {
	    return &netvector_t::atom2s32;
      } else if (method_name == "find" ||
		 method_name == "find_index" ||
		 method_name == "find_first" ||
		 method_name == "find_first_index" ||
		 method_name == "find_last" ||
		 method_name == "find_last_index" ||
		 method_name == "min" ||
		 method_name == "max" ||
		 method_name == "unique" ||
		 method_name == "unique_index" ||
		 method_name == "sum" ||
	         method_name == "product" ||
		 method_name == "and" ||
		 method_name == "or" ||
		 method_name == "xor") {
	    return element_type();
      }

      return 0;
}

NetExpr* netdarray_t::method_elaborate(const LineInfo *li, Design *des,
				       NetScope *scope, const pform_name_t &use_path,
				       const perm_string &method_name,
				       NetExpr*expr, unsigned rtn_wid,
				       const std::vector<PExpr*> &args) const
{

      if (method_name == "size") {
	    NetESFunc*fun = new NetESFunc("$size", IVL_VT_BOOL, 32, 1);
	    fun->parm(0, expr);
	    return fun;
      } else if (method_name == "find" ||
		 method_name == "find_index" ||
		 method_name == "find_first" ||
		 method_name == "find_first_index" ||
		 method_name == "find_last" ||
		 method_name == "find_last_index" ||
		 method_name == "min" ||
		 method_name == "max" ||
		 method_name == "unique" ||
		 method_name == "unique_index") {
	    cerr << li->get_fileline() << ": sorry: '" << method_name << "()' "
		    "array location method is not currently "
		    "implemented." << endl;
	    des->errors += 1;
	    return 0;
      } else if (method_name == "sum" ||
	         method_name == "product" ||
		 method_name == "and" ||
		 method_name == "or" ||
		 method_name == "xor") {
	    cerr << li->get_fileline() << ": sorry: '" << method_name << ")' "
		    "array reduction method is not currently "
		    "implemented." << endl;
	    des->errors += 1;
	    return 0;
      }

      return 0;
}
