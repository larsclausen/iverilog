/*
 * Copyright (c) 2010-2014 Stephen Williams (steve@icarus.com)
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

# include  "netenum.h"
# include  "PExpr.h"
# include  "netmisc.h"
# include  "netvector.h"
# include  "netscalar.h"
# include  "compiler.h"
# include  <cassert>

using namespace std;

netenum_t::netenum_t(ivl_type_t btype, size_t name_count, bool integer_flag)
: base_type_(btype), integer_flag_(integer_flag), names_(name_count),
  bits_(name_count)
{
}

netenum_t::~netenum_t()
{
}

bool netenum_t::get_signed() const
{
      return base_type_->get_signed();
}

bool netenum_t::get_isint() const
{
      return integer_flag_;
}

/*
 * Enumerations are by definition always packed.
 */
bool netenum_t::packed() const
{
      return true;
}

long netenum_t::packed_width() const
{
	return base_type_->packed_width();
}

vector<netrange_t> netenum_t::slice_dimensions() const
{
      return base_type_->slice_dimensions();
}

bool netenum_t::insert_name(size_t name_idx, perm_string name, const verinum&val)
{
      std::pair<std::map<perm_string,verinum>::iterator, bool> res;

      assert(val.has_len() && val.len() == packed_width());

	// Insert a map of the name to the value. This also gets a
	// flag that returns true if the  name is unique, or false
	// otherwise.
      res = names_map_.insert( make_pair(name,val) );

      assert(name_idx < names_.size() && names_[name_idx] == 0);
      names_[name_idx] = name;

      return res.second;
}

void netenum_t::insert_name_close(void)
{
      for (size_t idx = 0 ; idx < names_.size() ; idx += 1) {
	      // If we failed to elaborate the name then skip this step.
	    if (names_[idx].nil()) continue;

	    netenum_t::iterator cur = names_map_.find(names_[idx]);

	    vector<char>str (cur->second.len() + 1);
	    for (unsigned bit = 0 ; bit < cur->second.len() ; bit += 1) {
		  switch (cur->second.get(bit)) {
		      case verinum::V0:
			str[bit] = '0';
			break;
		      case verinum::V1:
			str[bit] = '1';
			break;
		      case verinum::Vx:
			str[bit] = 'x';
			break;
		      case verinum::Vz:
			str[bit] = 'z';
			break;
		  }
	    }
	    bits_[idx] = bits_strings.make(&str[0]);
      }
}

netenum_t::iterator netenum_t::find_name(perm_string name) const
{
      return names_map_.find(name);
}

/*
 * Check to see if the given value is already in the enumeration mapping.
 */
perm_string netenum_t::find_value(const verinum&val) const
{
      perm_string res;
      for(netenum_t::iterator cur = names_map_.begin();
          cur != names_map_.end(); ++ cur) {
	    if (cur->second == val) {
		  res = cur->first;
		  break;
	    }
      }
      return res;
}

netenum_t::iterator netenum_t::end_name() const
{
      return names_map_.end();
}

netenum_t::iterator netenum_t::first_name() const
{
      return names_map_.find(names_.front());
}

netenum_t::iterator netenum_t::last_name() const
{
      return names_map_.find(names_.back());
}

perm_string netenum_t::name_at(size_t idx) const
{
      assert(idx < names_.size());
      return names_[idx];
}

perm_string netenum_t::bits_at(size_t idx) const
{
      return bits_[idx];
}

bool netenum_t::matches(const netenum_t*other) const
{
      return this == other;
}


ivl_type_t netenum_t::method_get_type(Design*, NetScope*,
				      const perm_string &method_name) const
{
      if (method_name == "num") {
	    return &netvector_t::atom2s32;
      } else if (method_name == "first" || method_name == "last" ||
		 method_name == "next" || method_name == "prev") {
	    return this;
      } else if (method_name == "name") {
	    return &netstring_t::type_string;
      }

      return 0;
}

/*
 * Routine to look for and build enumeration method calls.
 */
NetExpr* netenum_t::method_elaborate(const LineInfo*li,
                                       Design*des, NetScope*scope,
                                       const pform_name_t&use_path,
                                       const perm_string&method_name,
                                       NetExpr*expr,
                                       unsigned rtn_wid,
				       const std::vector<PExpr*> &args) const
{
      if (debug_elaborate) {
	    cerr << li->get_fileline() << ": " << __func__ << ": "
		 << "Check for method " << method_name
		 << " of enumeration at " << get_fileline()
		 << endl;
	    cerr << li->get_fileline() << ": " << __func__ << ": "
		 << "use_path=" << use_path << endl;
	    cerr << li->get_fileline() << ": " << __func__ << ": "
		 << "rtn_wid=" << rtn_wid << endl;
	    cerr << li->get_fileline() << ": " << __func__ << ": "
		 << "expr=" << *expr << endl;
      }

      // First, look for some special methods that can be replace with
      // constant literals. These get properties of the enumeration type, and
      // so can be fully evaluated at compile time.

      if (method_name == "num") {
	    // The "num()" method returns the number of elements. This is
	    // actually a static constant, and can be replaced at compile time
	    // with a constant value.
	    if (args.size() != 0) {
		  cerr << li->get_fileline() << ": error: enumeration "
		          "method " << use_path << ".num() does not "
		          "take an argument." << endl;
		  des->errors += 1;
	    }
	    NetEConst*tmp = make_const_val(size());
	    tmp->set_line(*li);
	    delete expr; // The elaborated enum variable is not needed.
	    return tmp;
      }

      if (method_name == "first") {
	    // The "first()" method returns the first enumeration value. This
	    // doesn't actually care about the constant value, and instead
	    // returns as a constant literal the first value of the enumeration.
	    if (args.size() != 0) {
		  cerr << li->get_fileline() << ": error: enumeration "
		          "method " << use_path << ".first() does not "
		          "take an argument." << endl;
		  des->errors += 1;
	    }
	    iterator item = first_name();
	    NetEConstEnum*tmp = new NetEConstEnum(scope, item->first,
	                                          this, item->second);
	    tmp->set_line(*li);
	    delete expr; // The elaborated enum variable is not needed.
	    return tmp;
      }

      if (method_name == "last") {
	    // The "last()" method returns the first enumeration value. This
	    // doesn't actually care about the constant value, and instead
	    // returns as a constant literal the last value of the enumeration.
	    if (args.size() != 0) {
		  cerr << li->get_fileline() << ": error: enumeration "
		          "method " << use_path << ".last() does not "
		          "take an argument." << endl;
		  des->errors += 1;
	    }
	    iterator item = last_name();
	    NetEConstEnum*tmp = new NetEConstEnum(scope, item->first,
	                                          this, item->second);
	    tmp->set_line(*li);
	    delete expr; // The elaborated enum variable is not needed.
	    return tmp;
      }

      NetESFunc*sys_expr;

	// Process the method argument if it is available.
      NetExpr* count = 0;
      if (args.size() != 0) {
	    count = elaborate_rval_expr(des, scope, &netvector_t::atom2u32,
					IVL_VT_BOOL, 32, args[0]);
	    if (count == 0) {
		  cerr << li->get_fileline() << ": error: unable to elaborate "
		          "enumeration method argument " << use_path << "."
		       << method_name << "(" << args[0] << ")." << endl;
		  des->errors += 1;
	    } else if (NetEEvent*evt = dynamic_cast<NetEEvent*> (count)) {
		  cerr << evt->get_fileline() << ": error: An event '"
		       << evt->event()->name() << "' cannot be an enumeration "
		          "method argument." << endl;
		  des->errors += 1;
	    }
      }

      if (method_name == "name") {
	    // The "name()" method returns the name of the current enumeration
	    // value. The generated system task takes the enumeration
	    // definition and the enumeration value. The return value is the
	    // string name of the enumeration.
	    if (args.size() != 0) {
		  cerr << li->get_fileline() << ": error: enumeration "
		          "method " << use_path << ".name() does not "
		          "take an argument." << endl;
		  des->errors += 1;
	    }

	    // Generate the internal system function. Make sure the return
	    // value is "string" type.
	    sys_expr = new NetESFunc("$ivl_enum_method$name",
				     &netstring_t::type_string, 2);
	    NetENetenum* def = new NetENetenum(this);
	    def->set_line(*li);
	    sys_expr->parm(0, def);
	    sys_expr->parm(1, expr);

      } else if (method_name == "next") {
	    // The "next()" method returns the next enumeration value.
	    if (args.size() > 1) {
		  cerr << li->get_fileline() << ": error: enumeration "
		          "method " << use_path << ".next() take at "
		          "most one argument." << endl;
		  des->errors += 1;
	    }
	    sys_expr = new NetESFunc("$ivl_enum_method$next", this,
	                             2 + (args.size() != 0));
	    NetENetenum* def = new NetENetenum(this);
	    def->set_line(*li);
	    sys_expr->parm(0, def);
	    sys_expr->parm(1, expr);
	    if (args.size() != 0) sys_expr->parm(2, count);

      } else if (method_name == "prev") {
	    // The "prev()" method returns the previous enumeration value.
	    if (args.size() > 1) {
		  cerr << li->get_fileline() << ": error: enumeration "
		          "method " << use_path << ".prev() take at "
		          "most one argument." << endl;
		  des->errors += 1;
	    }
	    sys_expr = new NetESFunc("$ivl_enum_method$prev", this,
	                             2 + (args.size() != 0));
	    NetENetenum* def = new NetENetenum(this);
	    def->set_line(*li);
	    sys_expr->parm(0, def);
	    sys_expr->parm(1, expr);
	    if (args.size() != 0) sys_expr->parm(2, count);

      } else {
	    // This is an unknown enumeration method.
	    cerr << li->get_fileline() << ": error: Unknown enumeration "
	            "method " << use_path << "." << method_name << "()."
	         << endl;
	    des->errors += 1;
	    return expr;
      }

      sys_expr->set_line(*li);

      if (debug_elaborate) {
	    cerr << li->get_fileline() << ": " << __func__ << ": Generate "
	         << sys_expr->name() << "(" << use_path << ")" << endl;
      }

      return sys_expr;
}
