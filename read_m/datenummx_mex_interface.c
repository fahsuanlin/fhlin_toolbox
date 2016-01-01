/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "datenummx_mex_interface.h"

void InitializeModule_datenummx_mex_interface(void) {
}

void TerminateModule_datenummx_mex_interface(void) {
}

static mxArray * Mdatenummx(int nargout_, mxArray * varargin);

_mexLocalFunctionTable _local_function_table_datenummx
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfNDatenummx" contains the nargout interface for the
 * "datenummx" M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/datenummx.mexglx" (lines 0-0). This interface is only produced
 * if the M-function uses the special variable "nargout". The nargout interface
 * allows the number of requested outputs to be specified via the nargout
 * argument, as opposed to the normal interface which dynamically calculates
 * the number of outputs based on the number of non-NULL inputs it receives.
 * This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
mxArray * mlfNDatenummx(int nargout, mlfVarargoutList * varargout, ...) {
    mxArray * varargin = NULL;
    mlfVarargin(&varargin, varargout, 0);
    mlfEnterNewContext(0, -1, varargin);
    nargout += mclNargout(varargout);
    *mlfGetVarargoutCellPtr(varargout) = Mdatenummx(nargout, varargin);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
    return mlfAssignOutputs(varargout);
}

/*
 * The function "mlfDatenummx" contains the normal interface for the
 * "datenummx" M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/datenummx.mexglx" (lines 0-0). This function processes any
 * input arguments and passes them to the implementation version of the
 * function, appearing above.
 */
mxArray * mlfDatenummx(mlfVarargoutList * varargout, ...) {
    mxArray * varargin = NULL;
    int nargout = 0;
    mlfVarargin(&varargin, varargout, 0);
    mlfEnterNewContext(0, -1, varargin);
    nargout += mclNargout(varargout);
    *mlfGetVarargoutCellPtr(varargout) = Mdatenummx(nargout, varargin);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
    return mlfAssignOutputs(varargout);
}

/*
 * The function "mlfVDatenummx" contains the void interface for the "datenummx"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/datenummx.mexglx" (lines 0-0). The void interface is only
 * produced if the M-function uses the special variable "nargout", and has at
 * least one output. The void interface function specifies zero output
 * arguments to the implementation version of the function, and in the event
 * that the implementation version still returns an output (which, in MATLAB,
 * would be assigned to the "ans" variable), it deallocates the output. This
 * function processes any input arguments and passes them to the implementation
 * version of the function, appearing above.
 */
void mlfVDatenummx(mxArray * synthetic_varargin_argument, ...) {
    mxArray * varargin = NULL;
    mxArray * varargout = NULL;
    mlfVarargin(&varargin, synthetic_varargin_argument, 1);
    mlfEnterNewContext(0, -1, varargin);
    varargout = Mdatenummx(0, synthetic_varargin_argument);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
}

/*
 * The function "mlxDatenummx" contains the feval interface for the "datenummx"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/datenummx.mexglx" (lines 0-0). The feval function calls the
 * implementation version of datenummx through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxDatenummx(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[1];
    mxArray * mplhs[1];
    int i;
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    mlfEnterNewContext(0, 0);
    mprhs[0] = NULL;
    mlfAssign(&mprhs[0], mclCreateVararginCell(nrhs, prhs));
    mplhs[0] = Mdatenummx(nlhs, mprhs[0]);
    mclAssignVarargoutCell(0, nlhs, plhs, mplhs[0]);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(mprhs[0]);
}

/*
 * The function "Mdatenummx" is the implementation version of the "datenummx"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/datenummx.mexglx" (lines 1-1). It contains the actual compiled
 * code for that M-function. It is a static function and must only be called
 * from one of the interface functions, appearing below.
 */
static mxArray * Mdatenummx(int nargout_, mxArray * varargin) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_datenummx);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return mclCExecMexFunction("datenummx", nargout_, varargin);
}
