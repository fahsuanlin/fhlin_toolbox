/*
 * MATLAB Compiler: 2.2
 * Date: Sat Nov 30 14:13:31 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "simplex1" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#include "libmatlb.h"
#include "simplex1.h"
#include "pivottableau.h"
#include "rank.h"
#include "reducefree.h"
#include "restorefree.h"
#include "realmax.h"

static mexFunctionTableEntry function_table[6]
  = { { "simplex1", mlxSimplex1, -5, 3, &_local_function_table_simplex1 },
      { "pivottableau", mlxPivottableau, -3, 3,
        &_local_function_table_pivottableau },
      { "rank", mlxRank, 2, 1, &_local_function_table_rank },
      { "reducefree", mlxReducefree, 4, 6, &_local_function_table_reducefree },
      { "restorefree", mlxRestorefree, 3, 1,
        &_local_function_table_restorefree },
      { "realmax", mlxRealmax, 0, 1, &_local_function_table_realmax } };

static _mexInitTermTableEntry init_term_table[6]
  = { { InitializeModule_simplex1, TerminateModule_simplex1 },
      { InitializeModule_pivottableau, TerminateModule_pivottableau },
      { InitializeModule_rank, TerminateModule_rank },
      { InitializeModule_reducefree, TerminateModule_reducefree },
      { InitializeModule_restorefree, TerminateModule_restorefree },
      { InitializeModule_realmax, TerminateModule_realmax } };

static _mex_information _mex_info
  = { 1, 6, function_table, 0, NULL, 0, NULL, 6, init_term_table };

/*
 * The function "mexLibrary" is a Compiler-generated mex wrapper, suitable for
 * building a MEX-function. It initializes any persistent variables as well as
 * a function table for use by the feval function. It then calls the function
 * "mlxSimplex1". Finally, it clears the feval table and exits.
 */
mex_information mexLibrary(void) {
    mclMexLibraryInit();
    return &_mex_info;
}
