/*
 * MATLAB Compiler: 2.2
 * Date: Sat Nov 30 14:13:31 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "simplex1" 
 */
#include "realmax.h"
#include "libmatlbm.h"

static mxChar _array1_[132] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 'a', 'l', 'm',
                                'a', 'x', ' ', 'L', 'i', 'n', 'e', ':', ' ',
                                '1', ' ', 'C', 'o', 'l', 'u', 'm', 'n', ':',
                                ' ', '1', ' ', 'T', 'h', 'e', ' ', 'f', 'u',
                                'n', 'c', 't', 'i', 'o', 'n', ' ', '"', 'r',
                                'e', 'a', 'l', 'm', 'a', 'x', '"', ' ', 'w',
                                'a', 's', ' ', 'c', 'a', 'l', 'l', 'e', 'd',
                                ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o', 'r',
                                'e', ' ', 't', 'h', 'a', 'n', ' ', 't', 'h',
                                'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r', 'e',
                                'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ',
                                'o', 'f', ' ', 'o', 'u', 't', 'p', 'u', 't',
                                's', ' ', '(', '1', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[131] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 'a', 'l', 'm',
                                'a', 'x', ' ', 'L', 'i', 'n', 'e', ':', ' ',
                                '1', ' ', 'C', 'o', 'l', 'u', 'm', 'n', ':',
                                ' ', '1', ' ', 'T', 'h', 'e', ' ', 'f', 'u',
                                'n', 'c', 't', 'i', 'o', 'n', ' ', '"', 'r',
                                'e', 'a', 'l', 'm', 'a', 'x', '"', ' ', 'w',
                                'a', 's', ' ', 'c', 'a', 'l', 'l', 'e', 'd',
                                ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o', 'r',
                                'e', ' ', 't', 'h', 'a', 'n', ' ', 't', 'h',
                                'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r', 'e',
                                'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ',
                                'o', 'f', ' ', 'i', 'n', 'p', 'u', 't', 's',
                                ' ', '(', '0', ')', '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;
static mxArray * _mxarray5_;

void InitializeModule_realmax(void) {
    _mxarray0_ = mclInitializeString(132, _array1_);
    _mxarray2_ = mclInitializeString(131, _array3_);
    _mxarray4_ = mclInitializeDouble(1.9999999999999998);
    _mxarray5_ = mclInitializeDouble(1023.0);
}

void TerminateModule_realmax(void) {
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mrealmax(int nargout_);

_mexLocalFunctionTable _local_function_table_realmax
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfRealmax" contains the normal interface for the "realmax"
 * M-function from file
 * "/space/lyon/9/pubsw/common/matlab/6.1/toolbox/matlab/elmat/realmax.m"
 * (lines 1-19). This function processes any input arguments and passes them to
 * the implementation version of the function, appearing above.
 */
mxArray * mlfRealmax(void) {
    int nargout = 1;
    mxArray * rmax = mclGetUninitializedArray();
    mlfEnterNewContext(0, 0);
    rmax = Mrealmax(nargout);
    mlfRestorePreviousContext(0, 0);
    return mlfReturnValue(rmax);
}

/*
 * The function "mlxRealmax" contains the feval interface for the "realmax"
 * M-function from file
 * "/space/lyon/9/pubsw/common/matlab/6.1/toolbox/matlab/elmat/realmax.m"
 * (lines 1-19). The feval function calls the implementation version of realmax
 * through this function. This function processes any input arguments and
 * passes them to the implementation version of the function, appearing above.
 */
void mlxRealmax(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 0) {
        mlfError(_mxarray2_);
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    mlfEnterNewContext(0, 0);
    mplhs[0] = Mrealmax(nlhs);
    mlfRestorePreviousContext(0, 0);
    plhs[0] = mplhs[0];
}

/*
 * The function "Mrealmax" is the implementation version of the "realmax"
 * M-function from file
 * "/space/lyon/9/pubsw/common/matlab/6.1/toolbox/matlab/elmat/realmax.m"
 * (lines 1-19). It contains the actual compiled code for that M-function. It
 * is a static function and must only be called from one of the interface
 * functions, appearing below.
 */
/*
 * function rmax = realmax
 */
static mxArray * Mrealmax(int nargout_) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_realmax);
    mxArray * rmax = mclGetUninitializedArray();
    mxArray * maxexp = mclGetUninitializedArray();
    mxArray * f = mclGetUninitializedArray();
    /*
     * %REALMAX Largest positive floating point number.
     * %   x = realmax is the largest floating point number representable
     * %   on this computer.  Anything larger overflows.
     * %
     * %   See also EPS, REALMIN.
     * 
     * %   C. Moler, 7-26-91, 6-10-92, 8-27-93.
     * %   Copyright 1984-2001 The MathWorks, Inc. 
     * %   $Revision: 5.8 $  $Date: 2001/04/15 12:02:41 $
     * 
     * % 2-eps is the largest floating point number smaller than 2.
     * f = 2-eps;
     */
    mlfAssign(&f, _mxarray4_);
    /*
     * maxexp = 1023;
     */
    mlfAssign(&maxexp, _mxarray5_);
    /*
     * 
     * % pow2(f,e) is f*2^e, computed by adding e to the exponent of f.
     * 
     * rmax = pow2(f,maxexp);
     */
    mlfAssign(&rmax, mlfPow2(mclVv(f, "f"), mclVv(maxexp, "maxexp")));
    mclValidateOutput(rmax, 1, nargout_, "rmax", "realmax");
    mxDestroyArray(f);
    mxDestroyArray(maxexp);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return rmax;
}
