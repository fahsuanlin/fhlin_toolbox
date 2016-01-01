/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "fftshift.h"
#include "libmatlbm.h"
#include "repmat.h"

static mxChar _array1_[134] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'f', 'f', 't', 's', 'h',
                                'i', 'f', 't', ' ', 'L', 'i', 'n', 'e', ':',
                                ' ', '1', ' ', 'C', 'o', 'l', 'u', 'm', 'n',
                                ':', ' ', '1', ' ', 'T', 'h', 'e', ' ', 'f',
                                'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', '"',
                                'f', 'f', 't', 's', 'h', 'i', 'f', 't', '"',
                                ' ', 'w', 'a', 's', ' ', 'c', 'a', 'l', 'l',
                                'e', 'd', ' ', 'w', 'i', 't', 'h', ' ', 'm',
                                'o', 'r', 'e', ' ', 't', 'h', 'a', 'n', ' ',
                                't', 'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a',
                                'r', 'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e',
                                'r', ' ', 'o', 'f', ' ', 'o', 'u', 't', 'p',
                                'u', 't', 's', ' ', '(', '1', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[133] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'f', 'f', 't', 's', 'h',
                                'i', 'f', 't', ' ', 'L', 'i', 'n', 'e', ':',
                                ' ', '1', ' ', 'C', 'o', 'l', 'u', 'm', 'n',
                                ':', ' ', '1', ' ', 'T', 'h', 'e', ' ', 'f',
                                'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', '"',
                                'f', 'f', 't', 's', 'h', 'i', 'f', 't', '"',
                                ' ', 'w', 'a', 's', ' ', 'c', 'a', 'l', 'l',
                                'e', 'd', ' ', 'w', 'i', 't', 'h', ' ', 'm',
                                'o', 'r', 'e', ' ', 't', 'h', 'a', 'n', ' ',
                                't', 'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a',
                                'r', 'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e',
                                'r', ' ', 'o', 'f', ' ', 'i', 'n', 'p', 'u',
                                't', 's', ' ', '(', '2', ')', '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;

static mxChar _array6_[31] = { 'D', 'I', 'M', ' ', 'm', 'u', 's', 't',
                               ' ', 'b', 'e', ' ', 'a', ' ', 'p', 'o',
                               's', 'i', 't', 'i', 'v', 'e', ' ', 'i',
                               'n', 't', 'e', 'g', 'e', 'r', '.' };
static mxArray * _mxarray5_;

static mxChar _array9_[1] = { ':' };
static mxArray * _mxarray8_;
static mxArray * _mxarray7_;
static mxArray * _mxarray10_;
static mxArray * _mxarray11_;

void InitializeModule_fftshift(void) {
    _mxarray0_ = mclInitializeString(134, _array1_);
    _mxarray2_ = mclInitializeString(133, _array3_);
    _mxarray4_ = mclInitializeDouble(1.0);
    _mxarray5_ = mclInitializeString(31, _array6_);
    _mxarray8_ = mclInitializeString(1, _array9_);
    _mxarray7_ = mclInitializeCell(_mxarray8_);
    _mxarray10_ = mclInitializeDouble(2.0);
    _mxarray11_ = mclInitializeDoubleVector(0, 0, (double *)NULL);
}

void TerminateModule_fftshift(void) {
    mxDestroyArray(_mxarray11_);
    mxDestroyArray(_mxarray10_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray8_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mfftshift(int nargout_, mxArray * x, mxArray * dim);

_mexLocalFunctionTable _local_function_table_fftshift
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfFftshift" contains the normal interface for the "fftshift"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/datafun/fftshift.m" (lines 1-40). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfFftshift(mxArray * x, mxArray * dim) {
    int nargout = 1;
    mxArray * y = mclGetUninitializedArray();
    mlfEnterNewContext(0, 2, x, dim);
    y = Mfftshift(nargout, x, dim);
    mlfRestorePreviousContext(0, 2, x, dim);
    return mlfReturnValue(y);
}

/*
 * The function "mlxFftshift" contains the feval interface for the "fftshift"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/datafun/fftshift.m" (lines 1-40). The feval function calls the
 * implementation version of fftshift through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxFftshift(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
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
    mplhs[0] = Mfftshift(nlhs, mprhs[0], mprhs[1]);
    mlfRestorePreviousContext(0, 2, mprhs[0], mprhs[1]);
    plhs[0] = mplhs[0];
}

/*
 * The function "Mfftshift" is the implementation version of the "fftshift"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/datafun/fftshift.m" (lines 1-40). It contains the actual compiled code
 * for that M-function. It is a static function and must only be called from
 * one of the interface functions, appearing below.
 */
/*
 * function y = fftshift(x,dim)
 */
static mxArray * Mfftshift(int nargout_, mxArray * x, mxArray * dim) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_fftshift);
    int nargin_ = mclNargin(2, x, dim, NULL);
    mxArray * y = mclGetUninitializedArray();
    mxArray * k = mclGetUninitializedArray();
    mxArray * numDims = mclGetUninitializedArray();
    mxArray * p = mclGetUninitializedArray();
    mxArray * m = mclGetUninitializedArray();
    mxArray * idx = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    mclCopyArray(&x);
    mclCopyArray(&dim);
    /*
     * %FFTSHIFT Shift zero-frequency component to center of spectrum.
     * %   For vectors, FFTSHIFT(X) swaps the left and right halves of
     * %   X.  For matrices, FFTSHIFT(X) swaps the first and third
     * %   quadrants and the second and fourth quadrants.  For N-D
     * %   arrays, FFTSHIFT(X) swaps "half-spaces" of X along each
     * %   dimension.
     * %
     * %   FFTSHIFT(X,DIM) applies the FFTSHIFT operation along the 
     * %   dimension DIM.
     * %
     * %   FFTSHIFT is useful for visualizing the Fourier transform with
     * %   the zero-frequency component in the middle of the spectrum.
     * %
     * %   See also IFFTSHIFT, FFT, FFT2, FFTN.
     * 
     * %   Copyright 1984-2001 The MathWorks, Inc.
     * %   $Revision: 5.9 $  $Date: 2001/04/15 12:01:25 $
     * 
     * if nargin > 1
     */
    if (nargin_ > 1) {
        /*
         * if (prod(size(dim)) ~= 1) | floor(dim) ~= dim | dim < 1
         */
        mxArray * a_
          = mclInitialize(
              mclNe(
                mclVe(
                  mlfProd(
                    mclVe(
                      mlfSize(mclValueVarargout(), mclVa(dim, "dim"), NULL)),
                    NULL)),
                _mxarray4_));
        if (mlfTobool(a_)) {
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNe(mclVe(mlfFloor(mclVa(dim, "dim"))), mclVa(dim, "dim"))));
        }
        if (mlfTobool(a_)
            || mlfTobool(mclOr(a_, mclLt(mclVa(dim, "dim"), _mxarray4_)))) {
            mxDestroyArray(a_);
            /*
             * error('DIM must be a positive integer.')
             */
            mlfError(_mxarray5_);
        } else {
            mxDestroyArray(a_);
        }
        /*
         * end
         * idx = repmat({':'}, 1, max(ndims(x),dim));
         */
        mlfAssign(
          &idx,
          mlfRepmat(
            _mxarray7_,
            _mxarray4_,
            mclVe(
              mlfMax(
                NULL,
                mclVe(mlfNdims(mclVa(x, "x"))),
                mclVa(dim, "dim"),
                NULL))));
        /*
         * m = size(x, dim);
         */
        mlfAssign(
          &m, mlfSize(mclValueVarargout(), mclVa(x, "x"), mclVa(dim, "dim")));
        /*
         * p = ceil(m/2);
         */
        mlfAssign(&p, mlfCeil(mclMrdivide(mclVv(m, "m"), _mxarray10_)));
        /*
         * idx{dim} = [p+1:m 1:p];
         */
        mlfIndexAssign(
          &idx,
          "{?}",
          mclVsa(dim, "dim"),
          mlfHorzcat(
            mlfColon(mclPlus(mclVv(p, "p"), _mxarray4_), mclVv(m, "m"), NULL),
            mlfColon(_mxarray4_, mclVv(p, "p"), NULL),
            NULL));
    /*
     * else
     */
    } else {
        /*
         * numDims = ndims(x);
         */
        mlfAssign(&numDims, mlfNdims(mclVa(x, "x")));
        /*
         * idx = cell(1, numDims);
         */
        mlfAssign(&idx, mlfCell(_mxarray4_, mclVv(numDims, "numDims"), NULL));
        /*
         * for k = 1:numDims
         */
        {
            int v_ = mclForIntStart(1);
            int e_ = mclForIntEnd(mclVv(numDims, "numDims"));
            if (v_ > e_) {
                mlfAssign(&k, _mxarray11_);
            } else {
                /*
                 * m = size(x, k);
                 * p = ceil(m/2);
                 * idx{k} = [p+1:m 1:p];
                 * end
                 */
                for (; ; ) {
                    mlfAssign(
                      &m,
                      mlfSize(
                        mclValueVarargout(), mclVa(x, "x"), mlfScalar(v_)));
                    mlfAssign(
                      &p, mlfCeil(mclMrdivide(mclVv(m, "m"), _mxarray10_)));
                    mlfIndexAssign(
                      &idx,
                      "{?}",
                      mlfScalar(v_),
                      mlfHorzcat(
                        mlfColon(
                          mclPlus(mclVv(p, "p"), _mxarray4_),
                          mclVv(m, "m"),
                          NULL),
                        mlfColon(_mxarray4_, mclVv(p, "p"), NULL),
                        NULL));
                    if (v_ == e_) {
                        break;
                    }
                    ++v_;
                }
                mlfAssign(&k, mlfScalar(v_));
            }
        }
    /*
     * end
     */
    }
    /*
     * 
     * % Use comma-separated list syntax for N-D indexing.
     * y = x(idx{:});
     */
    mlfAssign(
      &y,
      mclArrayRef1(
        mclVsa(x, "x"),
        mlfIndexRef(mclVsv(idx, "idx"), "{?}", mlfCreateColonIndex())));
    mclValidateOutput(y, 1, nargout_, "y", "fftshift");
    mxDestroyArray(ans);
    mxDestroyArray(idx);
    mxDestroyArray(m);
    mxDestroyArray(p);
    mxDestroyArray(numDims);
    mxDestroyArray(k);
    mxDestroyArray(dim);
    mxDestroyArray(x);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return y;
}
