/*
 * Copyright (c) 2013 Stephen Williams (steve@icarus.com)
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

# include  "netscalar.h"

using namespace std;

netreal_t netreal_t::type_real;
netreal_t netreal_t::type_shortreal;
netstring_t netstring_t::type_string;

netreal_t::~netreal_t()
{
}

ivl_variable_type_t netreal_t::base_type() const
{
      return IVL_VT_REAL;
}

netstring_t::~netstring_t()
{
}

ivl_variable_type_t netstring_t::base_type() const
{
      return IVL_VT_STRING;
}

ivl_type_t netstring_t::method_get_type(Design*, NetScope*,
				       const perm_string &method_name) const
{
      if (method_name == "len") {
	    return &netvector_t::atom2s32;
      } else if (method_name=="atoi" || method_name=="atohex") {
	    return element_type();
      } else if (method_name=="atoreal") {
		return netreal_t;
      }

      return 0;
}


NetExpr* netstring_t::method_elaborate(const LineInfo *li, Design *des,
				      NetScope *scope,
				      const pform_name_t &use_path,
				      const perm_string &method_name,
				      NetExpr *expr, unsigned rtn_wid,
				      const std::vector<PExpr*> &args) const
{
      if (method_name == "len") {
	    NetESFunc*sys_expr = new NetESFunc("$ivl_string_method$len",
					       &netvector_t::atom2s32, 1);
	    sys_expr->parm(0, expr);
	    return sys_expr;
      }

      if (method_name == "atoi") {
	    NetESFunc*sys_expr = new NetESFunc("$ivl_string_method$atoi",
	                                       netvector_t::integer_type(), 1);
	    sys_expr->parm(0, expr);
	    return sys_expr;
      }

      if (method_name == "atoreal") {
	    NetESFunc*sys_expr = new NetESFunc("$ivl_string_method$atoreal",
					       &net_real::type_real, 1);
	    sys_expr->parm(0, expr);
	    return sys_expr;
      }

      if (method_name == "atohex") {
	    NetESFunc*sys_expr = new NetESFunc("$ivl_string_method$atohex",
					       netvector_t::integer_type(), 1);
	    sys_expr->parm(0, expr);
	    return sys_expr;
      }

      if (method_name == "substr") {
	    NetESFunc*sys_expr = new NetESFunc("$ivl_string_method$substr",
					       net_string::type_string, 3);
	    sys_expr->set_line(*this);

	      // First argument is the source string.
	    sys_expr->parm(0, expr);

	    if (args.size() != 2) {
		  cerr << li << " error: " << endl;
		  des->errors++;
	    }

	    for (int i = 0; i < 2; i++)
		  NetExpr*tmp;
		  tmp = elaborate_rval_expr(des, scope, &netvector_t::atom2u32,
					    args[i], false);
		  sys_expr->parm(i + 1, tmp);
	    }

	    return sys_expr;
      }

      return 0;
}
