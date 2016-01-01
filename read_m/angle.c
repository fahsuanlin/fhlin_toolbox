/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "angle.h"
#include "libmatlbm.h"

static mxChar _array1_[128] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'a', 'n', 'g', 'l', 'e',
                                ' ', 'L', 'i', 'n', 'e', ':', ' ', '1', ' ',
                                'C', 'o', 'l', 'u', 'm', 'n', ':', ' ', '1',
                                ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n', 'c',
                                't', 'i', 'o', 'n', ' ', '"', 'a', 'n', 'g',
                                'l', 'e', '"', ' ', 'w', 'a', 's', ' ', 'c',
                                'a', 'l', 'l', 'e', 'd', ' ', 'w', 'i', 't',
                                'h', ' ', 'm', 'o', 'r', 'e', ' ', 't', 'h',
                                'a', 'n', ' ', 't', 'h', 'e', ' ', 'd', 'e',
                                'c', 'l', 'a', 'r', 'e', 'd', ' ', 'n', 'u',
                                'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'o',
                                'u', 't', 'p', 'u', 't', 's', ' ', '(', '1',
                                ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[127] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'a', 'n', 'g', 'l', 'e',
                                ' ', 'L', 'i', 'n', 'e', ':', ' ', '1', ' ',
                                'C', 'o', 'l', 'u', 'm', 'n', ':', ' ', '1',
                                ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n', 'c',
                                't', 'i', 'o', 'n', ' ', '"', 'a', 'n', 'g',
                                'l', 'e', '"', ' ', 'w', 'a', 's', ' ', 'c',
                                'a', 'l', 'l', 'e', 'd', ' ', 'w', 'i', 't',
                                'h', ' ', 'm', 'o', 'r', 'e', ' ', 't', 'h',
                                'a', 'n', ' ', 't', 'h', 'e', ' ', 'd', 'e',
                                'c', 'l', 'a', 'r', 'e', 'd', ' ', 'n', 'u',
                                'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'i',
                                'n', 'p', 'u', 't', 's', ' ', '(', '1', ')',
                                '.' };
static mxArray * _mxarray2_;

void InitializeModule_angle(void) {
    _mxarray0_ = mclInitializeString(128, _array1_);
    _mxarray2_ = mclInitializeString(127, _array3_);
}

void TerminateModule_angle(void) {
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mangle(int nargout_, mxArray * h);

_mexLocalFunctionTable _local_function_table_angle
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfAngle" contains the normal interface for the "angle"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elfun/angle.m" (lines 1-17). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfAngle(mxArray * h) {
    int nargout = 1;
    mxArray * p = mclGetUninitializedArray();
    mlfEnterNewContext(0, 1, h);
    p = Mangle(nargout, h);
    mlfRestorePreviousContext(0, 1, h);
    return mlfReturnValue(p);
}

/*
 * The function "mlxAngle" contains the feval interface for the "angle"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elfun/angle.m" (lines 1-17). The feval function calls the
 * implementation version of angle through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxAngle(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[1];
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 1) {
        mlfError(_mxarray2_);
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 1 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 1; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 1, mprhs[0]);
    mplhs[0] = Mangle(nlhs, mprhs[0]);
    mlfRestorePreviousContext(0, 1, mprhs[0]);
    plhs[0] = mplhs[0];
}

/*
 * The function "Mangle" is the implementation version of the "angle"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elfun/angle.m" (lines 1-17). It contains the actual compiled code for
 * that M-function. It is a static function and must only be called from one of
 * the interface functions, appearing below.
 */
/*
 * function p = angle(h)
 */
static mxArray * Mangle(int nargout_, mxArray * h) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_angle);
    mxArray * p = mclGetUninitializedArray();
    mclCopyArray(&h);
    /*
     * %ANGLE  Phase angle.
     * %   ANGLE(H) returns the phase angles, in radians, of a matrix with
     * %   complex elements.  
     * %
     * %   See also ABS, UNWRAP.
     * 
     * %   Copyright 1984-2001 The MathWorks, Inc. 
     * %   $Revision: 5.6 $  $Date: 2001/04/15 12:02:45 $
     * 
     * % Clever way:
     * % p = imag(log(h));
     * 
     * % Way we'll do it:
     * p = atan2(imag(h), real(h));
     */
    mlfAssign(
      &p,
      mlfAtan2(mclVe(mlfImag(mclVa(h, "h"))), mclVe(mlfReal(mclVa(h, "h")))));
    mclValidateOutput(p, 1, nargout_, "p", "angle");
    mxDestroyArray(h);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return p;
    /*
     * 
     */
}
