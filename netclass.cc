/*
 * Copyright (c) 2012-2017 Stephen Williams (steve@icarus.com)
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

# include  "netclass.h"
# include  "netlist.h"
# include  <iostream>

using namespace std;

netclass_t::netclass_t(perm_string name, const netclass_t*super)
: name_(name), super_(super), class_scope_(0), definition_scope_(0), virtual_class_(false)
{
}

netclass_t::~netclass_t()
{
}

bool netclass_t::reserve_property(perm_string pname)
{
      auto inserted = properties_.emplace(pname, property_table_.size());
      if (!inserted.second)
	    return false;

      prop_t tmp;
      tmp.name = pname;
      tmp.qual = property_qualifier_t::make_none();
      tmp.type = nullptr;
      tmp.initialized_flag = false;
      property_table_.push_back(tmp);
      return true;
}

void netclass_t::define_property(perm_string pname, property_qualifier_t qual,
				 ivl_type_t ptype)
{
      auto cur = properties_.find(pname);
      assert(cur != properties_.end());

      auto &property = property_table_[cur->second];
      assert(!property.visible);
      property.qual = qual;
      property.type = ptype;
      property.visible = true;
}

void netclass_t::set_class_scope(NetScope*class_scope__)
{
      assert(class_scope_ == 0);
      class_scope_ = class_scope__;
}

void netclass_t::set_definition_scope(NetScope*use_definition_scope)
{
      assert(definition_scope_ == 0);
      definition_scope_ = use_definition_scope;
}

ivl_variable_type_t netclass_t::base_type() const
{
      return IVL_VT_CLASS;
}

size_t netclass_t::get_properties(void) const
{
      size_t res = properties_.size();
      if (super_) res += super_->get_properties();
      return res;
}

int netclass_t::property_idx_from_name(perm_string pname) const
{
      auto cur = properties_.find(pname);
      if (cur != properties_.end()) {
	    // A later local declaration hides inherited properties, but is
	    // not itself visible until its type has been elaborated.
	    if (!property_table_[cur->second].visible)
		  return -1;

	    int pidx = cur->second;
	    if (super_) pidx += super_->get_properties();
	    return pidx;
      }

      if (super_)
	    return super_->property_idx_from_name(pname);

      return -1;
}

const char*netclass_t::get_prop_name(size_t idx) const
{
      size_t super_size = 0;
      if (super_) super_size = super_->get_properties();

      assert(idx < (super_size + property_table_.size()));
      if (idx < super_size)
	    return super_->get_prop_name(idx);
      else
	    return property_table_[idx-super_size].name;
}

property_qualifier_t netclass_t::get_prop_qual(size_t idx) const
{
      size_t super_size = 0;
      if (super_) super_size = super_->get_properties();

      assert(idx < (super_size+property_table_.size()));
      if (idx < super_size)
	    return super_->get_prop_qual(idx);
      else
	    return property_table_[idx-super_size].qual;
}

ivl_type_t netclass_t::get_prop_type(size_t idx) const
{
      size_t super_size = 0;
      if (super_) super_size = super_->get_properties();

      assert(idx < (super_size+property_table_.size()));
      if (idx < super_size)
	    return super_->get_prop_type(idx);
      else
	    return property_table_[idx-super_size].type;
}

bool netclass_t::get_prop_initialized(size_t idx) const
{
      size_t super_size = 0;
      if (super_) super_size = super_->get_properties();

      assert(idx < (super_size+property_table_.size()));
      if (idx < super_size)
	    return super_->get_prop_initialized(idx);
      else
	    return property_table_[idx].initialized_flag;
}

void netclass_t::set_prop_initialized(size_t idx) const
{
      size_t super_size = 0;
      if (super_) super_size = super_->get_properties();

      assert(idx >= super_size && idx < (super_size+property_table_.size()));
      idx -= super_size;

      assert(! property_table_[idx].initialized_flag);
      property_table_[idx].initialized_flag = true;
}

bool netclass_t::test_for_missing_initializers() const
{
      for (size_t idx = 0 ; idx < property_table_.size() ; idx += 1) {
	    if (property_table_[idx].initialized_flag)
		  continue;
	    if (property_table_[idx].qual.test_const())
		  return true;
      }

      return false;
}

NetScope*netclass_t::method_from_name(perm_string name) const
{
      NetScope*task = class_scope_->child( hname_t(name) );
      if ((task == 0) && super_)
	    task = super_->method_from_name(name);
      return task;

}

NetScope* netclass_t::get_constructor() const
{
      auto task = class_scope_->child(hname_t(perm_string::literal("new")));
      if (task)
	    return task;

      task = class_scope_->child(hname_t(perm_string::literal("new@")));
      if (task)
	    return task;

      if (super_)
	    return super_->get_constructor();

      return nullptr;
}

NetNet* netclass_t::find_static_property(perm_string name) const
{
      NetNet *net = class_scope_->find_signal(name);
      if (net)
	    return net;

      if (super_)
	    return super_->find_static_property(name);

      return nullptr;
}

bool netclass_t::test_scope_is_method(const NetScope*scope) const
{
      while (scope && scope != class_scope_) {
	    scope = scope->parent();
      }

      if (scope == 0)
	    return false;
      else
	    return true;
}

const NetExpr* netclass_t::get_parameter(Design *des, perm_string name,
					 ivl_type_t &par_type) const
{
      return class_scope_->get_parameter(des, name, par_type);
}

bool netclass_t::test_compatibility(ivl_type_t that) const
{
      for (const netclass_t *class_type = dynamic_cast<const netclass_t *>(that);
	    class_type; class_type = class_type->get_super()) {
	    if (class_type == this)
		  return true;
      }

      return false;
}
