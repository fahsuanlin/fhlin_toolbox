/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:13 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "read_mdh_adc" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#include "libmatlb.h"
#include "read_mdh_adc.h"
#include "complex_mex_interface.h"

static mexFunctionTableEntry function_table[2]
  = { { "read_mdh_adc", mlxRead_mdh_adc, 1, 2,
        &_local_function_table_read_mdh_adc },
      { "complex", mlxComplex, -1, -1, &_local_function_table_complex } };

static const char * path_list_[1]
  = { "/.automount/lyon/local_mount/space/lyon/9/pub"
      "sw/common/matlab/6.1/toolbox/matlab/elfun" };

static _mexInitTermTableEntry init_term_table[2]
  = { { InitializeModule_read_mdh_adc, TerminateModule_read_mdh_adc },
      { InitializeModule_complex_mex_interface,
        TerminateModule_complex_mex_interface } };

static _mex_information _mex_info
  = { 1, 2, function_table, 0, NULL, 1, path_list_, 2, init_term_table };

/*
 * The function "mexLibrary" is a Compiler-generated mex wrapper, suitable for
 * building a MEX-function. It initializes any persistent variables as well as
 * a function table for use by the feval function. It then calls the function
 * "mlxRead_mdh_adc". Finally, it clears the feval table and exits.
 */
mex_information mexLibrary(void) {
    mclMexLibraryInit();
    return &_mex_info;
}
