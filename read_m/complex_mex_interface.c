/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "complex_mex_interface.h"

void InitializeModule_complex_mex_interface(void) {
}

void TerminateModule_complex_mex_interface(void) {
}

static mxArray * Mcomplex(int nargout_, mxArray * varargin);

_mexLocalFunctionTable _local_function_table_complex
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfNComplex" contains the nargout interface for the "complex"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elfun/complex.mexglx" (lines 0-0). This interface is only produced if
 * the M-function uses the special variable "nargout". The nargout interface
 * allows the number of requested outputs to be specified via the nargout
 * argument, as opposed to the normal interface which dynamically calculates
 * the number of outputs based on the number of non-NULL inputs it receives.
 * This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
mxArray * mlfNComplex(int nargout, mlfVarargoutList * varargout, ...) {
    mxArray * varargin = NULL;
    mlfVarargin(&varargin, varargout, 0);
    mlfEnterNewContext(0, -1, varargin);
    nargout += mclNargout(varargout);
    *mlfGetVarargoutCellPtr(varargout) = Mcomplex(nargout, varargin);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
    return mlfAssignOutputs(varargout);
}

/*
 * The function "mlfComplex" contains the normal interface for the "complex"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elfun/complex.mexglx" (lines 0-0). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfComplex(mlfVarargoutList * varargout, ...) {
    mxArray * varargin = NULL;
    int nargout = 0;
    mlfVarargin(&varargin, varargout, 0);
    mlfEnterNewContext(0, -1, varargin);
    nargout += mclNargout(varargout);
    *mlfGetVarargoutCellPtr(varargout) = Mcomplex(nargout, varargin);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
    return mlfAssignOutputs(varargout);
}

/*
 * The function "mlfVComplex" contains the void interface for the "complex"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elfun/complex.mexglx" (lines 0-0). The void interface is only produced
 * if the M-function uses the special variable "nargout", and has at least one
 * output. The void interface function specifies zero output arguments to the
 * implementation version of the function, and in the event that the
 * implementation version still returns an output (which, in MATLAB, would be
 * assigned to the "ans" variable), it deallocates the output. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlfVComplex(mxArray * synthetic_varargin_argument, ...) {
    mxArray * varargin = NULL;
    mxArray * varargout = NULL;
    mlfVarargin(&varargin, synthetic_varargin_argument, 1);
    mlfEnterNewContext(0, -1, varargin);
    varargout = Mcomplex(0, synthetic_varargin_argument);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
}

/*
 * The function "mlxComplex" contains the feval interface for the "complex"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elfun/complex.mexglx" (lines 0-0). The feval function calls the
 * implementation version of complex through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxComplex(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[1];
    mxArray * mplhs[1];
    int i;
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    mlfEnterNewContext(0, 0);
    mprhs[0] = NULL;
    mlfAssign(&mprhs[0], mclCreateVararginCell(nrhs, prhs));
    mplhs[0] = Mcomplex(nlhs, mprhs[0]);
    mclAssignVarargoutCell(0, nlhs, plhs, mplhs[0]);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(mprhs[0]);
}

/*
 * The function "Mcomplex" is the implementation version of the "complex"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elfun/complex.mexglx" (lines 1-1). It contains the actual compiled code
 * for that M-function. It is a static function and must only be called from
 * one of the interface functions, appearing below.
 */
static mxArray * Mcomplex(int nargout_, mxArray * varargin) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_complex);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return mclCExecMexFunction("complex", nargout_, varargin);
}
