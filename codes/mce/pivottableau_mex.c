/*
 * MATLAB Compiler: 2.2
 * Date: Thu Nov 28 17:35:53 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "pivottableau" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#include "libmatlb.h"
#include "pivottableau.h"
#include "realmax.h"

static mexFunctionTableEntry function_table[2]
  = { { "pivottableau", mlxPivottableau, 2, 2,
        &_local_function_table_pivottableau },
      { "realmax", mlxRealmax, 0, 1, &_local_function_table_realmax } };

static _mexInitTermTableEntry init_term_table[2]
  = { { InitializeModule_pivottableau, TerminateModule_pivottableau },
      { InitializeModule_realmax, TerminateModule_realmax } };

static _mex_information _mex_info
  = { 1, 2, function_table, 0, NULL, 0, NULL, 2, init_term_table };

/*
 * The function "mexLibrary" is a Compiler-generated mex wrapper, suitable for
 * building a MEX-function. It initializes any persistent variables as well as
 * a function table for use by the feval function. It then calls the function
 * "mlxPivottableau". Finally, it clears the feval table and exits.
 */
mex_information mexLibrary(void) {
    mclMexLibraryInit();
    return &_mex_info;
}
