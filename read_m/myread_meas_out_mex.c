/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#include "libmatlb.h"
#include "myread_meas_out.h"
#include "angle.h"
#include "fftshift.h"
#include "fliplr.h"
#include "read_mdh_adc.h"
#include "tic.h"
#include "toc.h"
#include "repmat.h"
#include "complex_mex_interface.h"
#include "etime.h"
#include "datenummx_mex_interface.h"

mxArray * TICTOC = NULL;

static mexGlobalTableEntry global_table[1] = { { "TICTOC", &TICTOC } };

static mexFunctionTableEntry function_table[11]
  = { { "myread_meas_out", mlxMyread_meas_out, -1, 3,
        &_local_function_table_myread_meas_out },
      { "angle", mlxAngle, 1, 1, &_local_function_table_angle },
      { "fftshift", mlxFftshift, 2, 1, &_local_function_table_fftshift },
      { "fliplr", mlxFliplr, 1, 1, &_local_function_table_fliplr },
      { "read_mdh_adc", mlxRead_mdh_adc, 1, 2,
        &_local_function_table_read_mdh_adc },
      { "tic", mlxTic, 0, 0, &_local_function_table_tic },
      { "toc", mlxToc, 0, 1, &_local_function_table_toc },
      { "repmat", mlxRepmat, 3, 1, &_local_function_table_repmat },
      { "complex", mlxComplex, -1, -1, &_local_function_table_complex },
      { "etime", mlxEtime, 2, 1, &_local_function_table_etime },
      { "datenummx", mlxDatenummx, -1, -1,
        &_local_function_table_datenummx } };

static const char * path_list_[2]
  = { "/.automount/lyon/local_mount/space/lyon/9/pub"
      "sw/common/matlab/6.1/toolbox/matlab/timefun",
      "/.automount/lyon/local_mount/space/lyon/9/pub"
      "sw/common/matlab/6.1/toolbox/matlab/elfun" };

static _mexInitTermTableEntry init_term_table[11]
  = { { InitializeModule_myread_meas_out, TerminateModule_myread_meas_out },
      { InitializeModule_angle, TerminateModule_angle },
      { InitializeModule_fftshift, TerminateModule_fftshift },
      { InitializeModule_fliplr, TerminateModule_fliplr },
      { InitializeModule_read_mdh_adc, TerminateModule_read_mdh_adc },
      { InitializeModule_tic, TerminateModule_tic },
      { InitializeModule_toc, TerminateModule_toc },
      { InitializeModule_repmat, TerminateModule_repmat },
      { InitializeModule_complex_mex_interface,
        TerminateModule_complex_mex_interface },
      { InitializeModule_etime, TerminateModule_etime },
      { InitializeModule_datenummx_mex_interface,
        TerminateModule_datenummx_mex_interface } };

static _mex_information _mex_info
  = { 1, 11, function_table, 1, global_table, 2,
      path_list_, 11, init_term_table };

/*
 * The function "mexLibrary" is a Compiler-generated mex wrapper, suitable for
 * building a MEX-function. It initializes any persistent variables as well as
 * a function table for use by the feval function. It then calls the function
 * "mlxMyread_meas_out". Finally, it clears the feval table and exits.
 */
mex_information mexLibrary(void) {
    mclMexLibraryInit();
    return &_mex_info;
}
