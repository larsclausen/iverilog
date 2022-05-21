/*
 * Copyright (c) 2012 Picture Elements, Inc.
 *    Stephen Williams (steve@icarus.com)
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

# include  "netparray.h"

using namespace std;

netsarray_t::~netsarray_t()
{
}

netparray_t::~netparray_t()
{
}

/*
 * The packed width of a packed array is the packed width of the
 * element times the dimension width of the array itself.
 */

bool netparray_t::packed(void) const
{
      return true;
}

unsigned long netparray_t::packed_width() const
{
      return netrange_width(static_dimensions(),
			   element_type->packed_width());
}

netranges_t netparray_t::slice_dimensions() const
{
      const netranges_t &elem_dims = element_type()->slice_dimensions();

      netranges_t res = static_dimensions();
      res.insert(res.end(), elem_dims.begin(), elem_dims.end());

      return res;
}

netuarray_t::~netuarray_t()
{
}

netranges_t netuarray_t::slice_dimensions() const
{
      return static_dimensions();
}
