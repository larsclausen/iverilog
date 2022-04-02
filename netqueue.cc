/*
 * Copyright (c) 2014-2020 Stephen Williams (steve@icarus.com)
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

# include  "netqueue.h"
# include  "netvector.h"
# include  "netlist.h"
# include  <iostream>

using namespace std;

netqueue_t::netqueue_t(ivl_type_t vec, long max_idx)
: netdarray_t(vec), max_idx_(max_idx)
{
}

netqueue_t::~netqueue_t()
{
}

ivl_variable_type_t netqueue_t::base_type() const
{
      return IVL_VT_QUEUE;
}

bool netqueue_t::test_compatibility(ivl_type_t that) const
{
      ivl_type_t elem_type = 0;

      if (const netqueue_t*that_q = dynamic_cast<const netqueue_t*>(that))
	    elem_type = that_q->element_type();

      if (const netdarray_t*that_da = dynamic_cast<const netdarray_t*>(that))
	    elem_type = that_da->element_type();

      if (elem_type == 0)
	    return false;

      return element_type()->type_compatible(elem_type);
}

ivl_type_t netqueue_t::method_get_type(Design*, NetScope*,
				       const perm_string &method_name) const
{
      if (method_name == "size") {
	    return &netvector_t::atom2s32;
      } else if (method_name=="pop_back" || method_name=="pop_front") {
	    return element_type();
      }

      return 0;
}

NetExpr* netqueue_t::method_elaborate(const LineInfo *li, Design *des,
				      NetScope *scope,
				      const pform_name_t &use_path,
				      const perm_string &method_name,
				      NetExpr *expr, unsigned rtn_wid,
				      const std::vector<PExpr*> &args) const
{
      if (method_name == "size") {
	    if (args.size() != 0) {
		  cerr << li->get_fileline() << ": error: size() method "
		       << "takes no arguments" << endl;
		  des->errors++;
	    }
	    NetESFunc*sys_expr = new NetESFunc("$size", &netvector_t::atom2s32, 1);
	    sys_expr->parm(0, expr);
	    return sys_expr;
      }

      if (method_name == "pop_back") {
	    if (args.size() != 0) {
		  cerr << li->get_fileline() << ": error: pop_back() method "
		       << "takes no arguments" << endl;
		  des->errors++;
	    }
	    NetESFunc*sys_expr = new NetESFunc("$ivl_queue_method$pop_back",
					       element_type(), 1);
	    sys_expr->parm(0, expr);
	    return sys_expr;
      }

      if (method_name == "pop_front") {
	    if (args.size() != 0) {
		  cerr << li->get_fileline() << ": error: pop_front() method "
		       << "takes no arguments" << endl;
		  des->errors++;
	    }
	    NetESFunc*sys_expr = new NetESFunc("$ivl_queue_method$pop_front",
					       element_type(), 1);
	    sys_expr->parm(0, expr);
	    return sys_expr;
      }

      cerr << li->get_fileline() << ": error: Method " << method_name
	   << " is not a queue method." << endl;
      des->errors++;
      return 0;
}
