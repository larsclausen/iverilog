/* Read signedness from argument and discovered array-word handles. */

#include <assert.h>
#include <vpi_user.h>

static PLI_INT32 get_signed(PLI_BYTE8*lookup)
{
      vpiHandle call = vpi_handle(vpiSysTfCall, 0);
      vpiHandle args = vpi_iterate(vpiArgument, call);
      vpiHandle obj = vpi_scan(args);
      s_vpi_value value;

      if (lookup) {
	    value.format = vpiStringVal;
	    vpi_get_value(obj, &value);
	    vpiHandle array = vpi_handle_by_name(value.value.str, 0);
	    assert(array);
	    value.format = vpiIntVal;
	    vpi_get_value(vpi_scan(args), &value);
	    obj = vpi_handle_by_index(array, value.value.integer);
      }
      assert(obj);
      vpi_free_object(args);

      value.format = vpiIntVal;
      value.value.integer = vpi_get(vpiSigned, obj);
      vpi_put_value(call, &value, 0, vpiNoDelay);
      return 0;
}

static void register_functions(void)
{
      s_vpi_systf_data tf = {0};
      tf.type = vpiSysFunc;
      tf.sysfunctype = vpiIntFunc;
      tf.calltf = get_signed;
      tf.tfname = "$vpi_signed";
      vpi_register_systf(&tf);

      tf.tfname = "$vpi_word_signed";
      tf.user_data = (PLI_BYTE8*)"lookup";
      vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_functions, 0};
