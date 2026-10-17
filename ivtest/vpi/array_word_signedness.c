/* Compare discovered array words with an ordinary integral value. */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <vpi_user.h>

static PLI_INT32 check_word(PLI_BYTE8*unused)
{
      vpiHandle call = vpi_handle(vpiSysTfCall, 0);
      vpiHandle args = vpi_iterate(vpiArgument, call);
      s_vpi_value value;
      PLI_INT32 passed = 1;
      (void)unused;

      value.format = vpiStringVal;
      vpi_get_value(vpi_scan(args), &value);
      vpiHandle array = vpi_handle_by_name(value.value.str, 0);
      assert(array);

      value.format = vpiIntVal;
      vpi_get_value(vpi_scan(args), &value);
      PLI_INT32 index = value.value.integer;
      vpiHandle word = vpi_handle_by_index(array, index);
      assert(word);
      vpiHandle reference = vpi_scan(args);
      vpi_free_object(args);

      vpi_get_value(reference, &value);
      PLI_INT32 expected_int = value.value.integer;
      vpi_get_value(word, &value);
      if (value.value.integer != expected_int) {
	    vpi_printf("FAILED: %s[%d] integer expected %d, got %d\n",
	               vpi_get_str(vpiFullName, array), index,
	               expected_int, value.value.integer);
	    passed = 0;
      }

      value.format = vpiDecStrVal;
      vpi_get_value(reference, &value);
      char*expected_dec = malloc(strlen(value.value.str) + 1);
      assert(expected_dec);
      strcpy(expected_dec, value.value.str);
      vpi_get_value(word, &value);
      if (strcmp(value.value.str, expected_dec) != 0) {
	    vpi_printf("FAILED: %s[%d] decimal expected %s, got %s\n",
	               vpi_get_str(vpiFullName, array), index,
	               expected_dec, value.value.str);
	    passed = 0;
      }
      free(expected_dec);

      value.format = vpiIntVal;
      value.value.integer = passed;
      vpi_put_value(call, &value, 0, vpiNoDelay);
      return 0;
}

static void register_function(void)
{
      s_vpi_systf_data tf = {0};
      tf.type = vpiSysFunc;
      tf.sysfunctype = vpiIntFunc;
      tf.tfname = "$check_array_word";
      tf.calltf = check_word;
      vpi_register_systf(&tf);
}

void (*vlog_startup_routines[])(void) = {register_function, 0};
