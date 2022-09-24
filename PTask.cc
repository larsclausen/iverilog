/*
 * Copyright (c) 1999-2021 Stephen Williams (steve@icarus.com)
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
# include  "PTask.h"
# include  "netlist.h"
# include  "PWire.h"
# include  <cassert>

using namespace std;

PTaskFunc::PTaskFunc(perm_string n, LexicalScope*p)
: PScope(n,p), this_type_(0), ports_(0)
{
}

PTaskFunc::~PTaskFunc()
{
}

bool PTaskFunc::var_init_needs_explicit_lifetime() const
{
      return default_lifetime == STATIC;
}

void PTaskFunc::set_ports(vector<pform_tf_port_t>*p)
{
      assert(ports_ == 0);
      ports_ = p;
}

void PTaskFunc::set_this(class_type_t*type)
{
      assert(this_type_ == 0);
      this_type_ = type;

      perm_string this_name = perm_string::literal(THIS_TOKEN);

      PWire *wire = new PWire(this_name, NetNet::REG, NetNet::PINPUT,
			      IVL_VT_NO_TYPE, SR_BOTH);
      wire->set_data_type(type);
      //FILE_NAME(wire, *this);

      wires[this_name] = wire;

	// Push a synthesis argument that is the "this" value.
      if (ports_==0)
	    ports_ = new vector<pform_tf_port_t>;
      
      ports_->insert(ports_->begin(), pform_tf_port_t(wire));
}

PTask::PTask(perm_string name, LexicalScope*parent, bool is_auto__)
: PTaskFunc(name, parent), statement_(0)
{
      is_auto_ = is_auto__;
}

PTask::~PTask()
{
}

void PTask::set_statement(Statement*s)
{
      assert(statement_ == 0);
      statement_ = s;
}

PNamedItem::SymbolType PTask::symbol_type() const
{
      return TASK;
}
