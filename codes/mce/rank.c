/*
 * MATLAB Compiler: 2.2
 * Date: Sat Nov 30 14:13:31 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "simplex1" 
 */
#include "rank.h"
#include "libmatlbm.h"

static mxChar _array1_[126] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'a', 'n', 'k', ' ',
                                'L', 'i', 'n', 'e', ':', ' ', '1', ' ', 'C',
                                'o', 'l', 'u', 'm', 'n', ':', ' ', '1', ' ',
                                'T', 'h', 'e', ' ', 'f', 'u', 'n', 'c', 't',
                                'i', 'o', 'n', ' ', '"', 'r', 'a', 'n', 'k',
                                '"', ' ', 'w', 'a', 's', ' ', 'c', 'a', 'l',
                                'l', 'e', 'd', ' ', 'w', 'i', 't', 'h', ' ',
                                'm', 'o', 'r', 'e', ' ', 't', 'h', 'a', 'n',
                                ' ', 't', 'h', 'e', ' ', 'd', 'e', 'c', 'l',
                                'a', 'r', 'e', 'd', ' ', 'n', 'u', 'm', 'b',
                                'e', 'r', ' ', 'o', 'f', ' ', 'o', 'u', 't',
                                'p', 'u', 't', 's', ' ', '(', '1', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[125] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'a', 'n', 'k', ' ',
                                'L', 'i', 'n', 'e', ':', ' ', '1', ' ', 'C',
                                'o', 'l', 'u', 'm', 'n', ':', ' ', '1', ' ',
                                'T', 'h', 'e', ' ', 'f', 'u', 'n', 'c', 't',
                                'i', 'o', 'n', ' ', '"', 'r', 'a', 'n', 'k',
                                '"', ' ', 'w', 'a', 's', ' ', 'c', 'a', 'l',
                                'l', 'e', 'd', ' ', 'w', 'i', 't', 'h', ' ',
                                'm', 'o', 'r', 'e', ' ', 't', 'h', 'a', 'n',
                                ' ', 't', 'h', 'e', ' ', 'd', 'e', 'c', 'l',
                                'a', 'r', 'e', 'd', ' ', 'n', 'u', 'm', 'b',
                                'e', 'r', ' ', 'o', 'f', ' ', 'i', 'n', 'p',
                                'u', 't', 's', ' ', '(', '2', ')', '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;

void InitializeModule_rank(void) {
    _mxarray0_ = mclInitializeString(126, _array1_);
    _mxarray2_ = mclInitializeString(125, _array3_);
    _mxarray4_ = mclInitializeDouble(2.220446049250313e-16);
}

void TerminateModule_rank(void) {
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mrank(int nargout_, mxArray * A, mxArray * tol);

_mexLocalFunctionTable _local_function_table_rank
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfRank" contains the normal interface for the "rank"
 * M-function from file
 * "/space/lyon/9/pubsw/common/matlab/6.1/toolbox/matlab/matfun/rank.m" (lines
 * 1-17). This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
mxArray * mlfRank(mxArray * A, mxArray * tol) {
    int nargout = 1;
    mxArray * r = mclGetUninitializedArray();
    mlfEnterNewContext(0, 2, A, tol);
    r = Mrank(nargout, A, tol);
    mlfRestorePreviousContext(0, 2, A, tol);
    return mlfReturnValue(r);
}

/*
 * The function "mlxRank" contains the feval interface for the "rank"
 * M-function from file
 * "/space/lyon/9/pubsw/common/matlab/6.1/toolbox/matlab/matfun/rank.m" (lines
 * 1-17). The feval function calls the implementation version of rank through
 * this function. This function processes any input arguments and passes them
 * to the implementation version of the function, appearing above.
 */
void mlxRank(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[2];
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 2) {
        mlfError(_mxarray2_);
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 2 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 2; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 2, mprhs[0], mprhs[1]);
    mplhs[0] = Mrank(nlhs, mprhs[0], mprhs[1]);
    mlfRestorePreviousContext(0, 2, mprhs[0], mprhs[1]);
    plhs[0] = mplhs[0];
}

/*
 * The function "Mrank" is the implementation version of the "rank" M-function
 * from file
 * "/space/lyon/9/pubsw/common/matlab/6.1/toolbox/matlab/matfun/rank.m" (lines
 * 1-17). It contains the actual compiled code for that M-function. It is a
 * static function and must only be called from one of the interface functions,
 * appearing below.
 */
/*
 * function r = rank(A,tol)
 */
static mxArray * Mrank(int nargout_, mxArray * A, mxArray * tol) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_rank);
    int nargin_ = mclNargin(2, A, tol, NULL);
    mxArray * r = mclGetUninitializedArray();
    mxArray * s = mclGetUninitializedArray();
    mclCopyArray(&A);
    mclCopyArray(&tol);
    /*
     * %RANK   Matrix rank.
     * %   RANK(A) provides an estimate of the number of linearly
     * %   independent rows or columns of a matrix A.
     * %   RANK(A,tol) is the number of singular values of A
     * %   that are larger than tol.
     * %   RANK(A) uses the default tol = max(size(A)) * norm(A) * eps.
     * 
     * %   Copyright 1984-2001 The MathWorks, Inc. 
     * %   $Revision: 5.10 $  $Date: 2001/04/15 12:01:33 $
     * 
     * s = svd(A);
     */
    mlfAssign(&s, mlfSvd(NULL, NULL, mclVa(A, "A"), NULL));
    /*
     * if nargin==1
     */
    if (nargin_ == 1) {
        /*
         * tol = max(size(A)') * max(s) * eps;
         */
        mlfAssign(
          &tol,
          mclMtimes(
            mclMtimes(
              mclVe(
                mlfMax(
                  NULL,
                  mlfCtranspose(
                    mclVe(mlfSize(mclValueVarargout(), mclVa(A, "A"), NULL))),
                  NULL,
                  NULL)),
              mclVe(mlfMax(NULL, mclVv(s, "s"), NULL, NULL))),
            _mxarray4_));
    /*
     * end
     */
    }
    /*
     * r = sum(s > tol);
     */
    mlfAssign(&r, mlfSum(mclGt(mclVv(s, "s"), mclVa(tol, "tol")), NULL));
    mclValidateOutput(r, 1, nargout_, "r", "rank");
    mxDestroyArray(s);
    mxDestroyArray(tol);
    mxDestroyArray(A);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return r;
}
