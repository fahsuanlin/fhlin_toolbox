/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "fliplr.h"
#include "libmatlbm.h"

static mxChar _array1_[130] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'f', 'l', 'i', 'p', 'l',
                                'r', ' ', 'L', 'i', 'n', 'e', ':', ' ', '1',
                                ' ', 'C', 'o', 'l', 'u', 'm', 'n', ':', ' ',
                                '1', ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n',
                                'c', 't', 'i', 'o', 'n', ' ', '"', 'f', 'l',
                                'i', 'p', 'l', 'r', '"', ' ', 'w', 'a', 's',
                                ' ', 'c', 'a', 'l', 'l', 'e', 'd', ' ', 'w',
                                'i', 't', 'h', ' ', 'm', 'o', 'r', 'e', ' ',
                                't', 'h', 'a', 'n', ' ', 't', 'h', 'e', ' ',
                                'd', 'e', 'c', 'l', 'a', 'r', 'e', 'd', ' ',
                                'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f',
                                ' ', 'o', 'u', 't', 'p', 'u', 't', 's', ' ',
                                '(', '1', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[129] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'f', 'l', 'i', 'p', 'l',
                                'r', ' ', 'L', 'i', 'n', 'e', ':', ' ', '1',
                                ' ', 'C', 'o', 'l', 'u', 'm', 'n', ':', ' ',
                                '1', ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n',
                                'c', 't', 'i', 'o', 'n', ' ', '"', 'f', 'l',
                                'i', 'p', 'l', 'r', '"', ' ', 'w', 'a', 's',
                                ' ', 'c', 'a', 'l', 'l', 'e', 'd', ' ', 'w',
                                'i', 't', 'h', ' ', 'm', 'o', 'r', 'e', ' ',
                                't', 'h', 'a', 'n', ' ', 't', 'h', 'e', ' ',
                                'd', 'e', 'c', 'l', 'a', 'r', 'e', 'd', ' ',
                                'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f',
                                ' ', 'i', 'n', 'p', 'u', 't', 's', ' ', '(',
                                '1', ')', '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;

static mxChar _array6_[23] = { 'X', ' ', 'm', 'u', 's', 't', ' ', 'b',
                               'e', ' ', 'a', ' ', '2', '-', 'D', ' ',
                               'm', 'a', 't', 'r', 'i', 'x', '.' };
static mxArray * _mxarray5_;
static mxArray * _mxarray7_;
static mxArray * _mxarray8_;

void InitializeModule_fliplr(void) {
    _mxarray0_ = mclInitializeString(130, _array1_);
    _mxarray2_ = mclInitializeString(129, _array3_);
    _mxarray4_ = mclInitializeDouble(2.0);
    _mxarray5_ = mclInitializeString(23, _array6_);
    _mxarray7_ = mclInitializeDouble(-1.0);
    _mxarray8_ = mclInitializeDouble(1.0);
}

void TerminateModule_fliplr(void) {
    mxDestroyArray(_mxarray8_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mfliplr(int nargout_, mxArray * x);

_mexLocalFunctionTable _local_function_table_fliplr
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfFliplr" contains the normal interface for the "fliplr"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elmat/fliplr.m" (lines 1-17). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfFliplr(mxArray * x) {
    int nargout = 1;
    mxArray * y = mclGetUninitializedArray();
    mlfEnterNewContext(0, 1, x);
    y = Mfliplr(nargout, x);
    mlfRestorePreviousContext(0, 1, x);
    return mlfReturnValue(y);
}

/*
 * The function "mlxFliplr" contains the feval interface for the "fliplr"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elmat/fliplr.m" (lines 1-17). The feval function calls the
 * implementation version of fliplr through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxFliplr(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
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
    mplhs[0] = Mfliplr(nlhs, mprhs[0]);
    mlfRestorePreviousContext(0, 1, mprhs[0]);
    plhs[0] = mplhs[0];
}

/*
 * The function "Mfliplr" is the implementation version of the "fliplr"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elmat/fliplr.m" (lines 1-17). It contains the actual compiled code for
 * that M-function. It is a static function and must only be called from one of
 * the interface functions, appearing below.
 */
/*
 * function y = fliplr(x)
 */
static mxArray * Mfliplr(int nargout_, mxArray * x) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_fliplr);
    mxArray * y = mclGetUninitializedArray();
    mxArray * n = mclGetUninitializedArray();
    mxArray * m = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    mclCopyArray(&x);
    /*
     * %FLIPLR Flip matrix in left/right direction.
     * %   FLIPLR(X) returns X with row preserved and columns flipped
     * %   in the left/right direction.
     * %   
     * %   X = 1 2 3     becomes  3 2 1
     * %       4 5 6              6 5 4
     * %
     * %   See also FLIPUD, ROT90, FLIPDIM.
     * 
     * %   Copyright 1984-2001 The MathWorks, Inc.
     * %   $Revision: 5.8 $  $Date: 2001/04/15 12:02:39 $
     * 
     * if ndims(x)~=2, error('X must be a 2-D matrix.'); end
     */
    if (mclNeBool(mclVe(mlfNdims(mclVa(x, "x"))), _mxarray4_)) {
        mlfError(_mxarray5_);
    }
    /*
     * [m,n] = size(x);
     */
    mlfSize(mlfVarargout(&m, &n, NULL), mclVa(x, "x"), NULL);
    /*
     * y = x(:,n:-1:1);
     */
    mlfAssign(
      &y,
      mclArrayRef2(
        mclVsa(x, "x"),
        mlfCreateColonIndex(),
        mlfColon(mclVv(n, "n"), _mxarray7_, _mxarray8_)));
    mclValidateOutput(y, 1, nargout_, "y", "fliplr");
    mxDestroyArray(ans);
    mxDestroyArray(m);
    mxDestroyArray(n);
    mxDestroyArray(x);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return y;
}
