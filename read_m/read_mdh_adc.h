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

#ifndef __read_mdh_adc_h
#define __read_mdh_adc_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_read_mdh_adc(void);
extern void TerminateModule_read_mdh_adc(void);
extern _mexLocalFunctionTable _local_function_table_read_mdh_adc;

extern mxArray * mlfRead_mdh_adc(mxArray * * mdh, mxArray * fid);
extern void mlxRead_mdh_adc(int nlhs,
                            mxArray * plhs[],
                            int nrhs,
                            mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
