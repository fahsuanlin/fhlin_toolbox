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

#ifndef __datenummx_mex_interface_h
#define __datenummx_mex_interface_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_datenummx_mex_interface(void);
extern void TerminateModule_datenummx_mex_interface(void);
extern _mexLocalFunctionTable _local_function_table_datenummx;

extern mxArray * mlfNDatenummx(int nargout, mlfVarargoutList * varargout, ...);
extern mxArray * mlfDatenummx(mlfVarargoutList * varargout, ...);
extern void mlfVDatenummx(mxArray * synthetic_varargin_argument, ...);
extern void mlxDatenummx(int nlhs,
                         mxArray * plhs[],
                         int nrhs,
                         mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
