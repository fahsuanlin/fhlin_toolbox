/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "repmat.h"
#include "libmatlbm.h"

static mxChar _array1_[130] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 'p', 'm', 'a',
                                't', ' ', 'L', 'i', 'n', 'e', ':', ' ', '1',
                                ' ', 'C', 'o', 'l', 'u', 'm', 'n', ':', ' ',
                                '1', ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n',
                                'c', 't', 'i', 'o', 'n', ' ', '"', 'r', 'e',
                                'p', 'm', 'a', 't', '"', ' ', 'w', 'a', 's',
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
                                'l', 'e', ':', ' ', 'r', 'e', 'p', 'm', 'a',
                                't', ' ', 'L', 'i', 'n', 'e', ':', ' ', '1',
                                ' ', 'C', 'o', 'l', 'u', 'm', 'n', ':', ' ',
                                '1', ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n',
                                'c', 't', 'i', 'o', 'n', ' ', '"', 'r', 'e',
                                'p', 'm', 'a', 't', '"', ' ', 'w', 'a', 's',
                                ' ', 'c', 'a', 'l', 'l', 'e', 'd', ' ', 'w',
                                'i', 't', 'h', ' ', 'm', 'o', 'r', 'e', ' ',
                                't', 'h', 'a', 'n', ' ', 't', 'h', 'e', ' ',
                                'd', 'e', 'c', 'l', 'a', 'r', 'e', 'd', ' ',
                                'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f',
                                ' ', 'i', 'n', 'p', 'u', 't', 's', ' ', '(',
                                '3', ')', '.' };
static mxArray * _mxarray2_;

static mxChar _array5_[27] = { 'R', 'e', 'q', 'u', 'i', 'r', 'e', 's', ' ',
                               'a', 't', ' ', 'l', 'e', 'a', 's', 't', ' ',
                               '2', ' ', 'i', 'n', 'p', 'u', 't', 's', '.' };
static mxArray * _mxarray4_;
static mxArray * _mxarray6_;
static mxArray * _mxarray7_;
static mxArray * _mxarray8_;
static mxArray * _mxarray9_;

void InitializeModule_repmat(void) {
    _mxarray0_ = mclInitializeString(130, _array1_);
    _mxarray2_ = mclInitializeString(129, _array3_);
    _mxarray4_ = mclInitializeString(27, _array5_);
    _mxarray6_ = mclInitializeDouble(0.0);
    _mxarray7_ = mclInitializeDouble(1.0);
    _mxarray8_ = mclInitializeDouble(-1.0);
    _mxarray9_ = mclInitializeDouble(2.0);
}

void TerminateModule_repmat(void) {
    mxDestroyArray(_mxarray9_);
    mxDestroyArray(_mxarray8_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray6_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mrepmat(int nargout_, mxArray * A, mxArray * M, mxArray * N);

_mexLocalFunctionTable _local_function_table_repmat
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfRepmat" contains the normal interface for the "repmat"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elmat/repmat.m" (lines 1-65). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfRepmat(mxArray * A, mxArray * M, mxArray * N) {
    int nargout = 1;
    mxArray * B = mclGetUninitializedArray();
    mlfEnterNewContext(0, 3, A, M, N);
    B = Mrepmat(nargout, A, M, N);
    mlfRestorePreviousContext(0, 3, A, M, N);
    return mlfReturnValue(B);
}

/*
 * The function "mlxRepmat" contains the feval interface for the "repmat"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elmat/repmat.m" (lines 1-65). The feval function calls the
 * implementation version of repmat through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxRepmat(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[3];
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 3) {
        mlfError(_mxarray2_);
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 3 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 3; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 3, mprhs[0], mprhs[1], mprhs[2]);
    mplhs[0] = Mrepmat(nlhs, mprhs[0], mprhs[1], mprhs[2]);
    mlfRestorePreviousContext(0, 3, mprhs[0], mprhs[1], mprhs[2]);
    plhs[0] = mplhs[0];
}

/*
 * The function "Mrepmat" is the implementation version of the "repmat"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/elmat/repmat.m" (lines 1-65). It contains the actual compiled code for
 * that M-function. It is a static function and must only be called from one of
 * the interface functions, appearing below.
 */
/*
 * function B = repmat(A,M,N)
 */
static mxArray * Mrepmat(int nargout_, mxArray * A, mxArray * M, mxArray * N) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_repmat);
    int nargin_ = mclNargin(3, A, M, N, NULL);
    mxArray * B = mclGetUninitializedArray();
    mxArray * subs = mclGetUninitializedArray();
    mxArray * ind = mclGetUninitializedArray();
    mxArray * i = mclGetUninitializedArray();
    mxArray * Asiz = mclGetUninitializedArray();
    mxArray * nind = mclGetUninitializedArray();
    mxArray * mind = mclGetUninitializedArray();
    mxArray * n = mclGetUninitializedArray();
    mxArray * m = mclGetUninitializedArray();
    mxArray * nelems = mclGetUninitializedArray();
    mxArray * siz = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    mclCopyArray(&A);
    mclCopyArray(&M);
    mclCopyArray(&N);
    /*
     * %REPMAT Replicate and tile an array.
     * %   B = repmat(A,M,N) creates a large matrix B consisting of an M-by-N
     * %   tiling of copies of A.
     * %   
     * %   B = REPMAT(A,[M N]) accomplishes the same result as repmat(A,M,N).
     * %
     * %   B = REPMAT(A,[M N P ...]) tiles the array A to produce a
     * %   M-by-N-by-P-by-... block array.  A can be N-D.
     * %
     * %   REPMAT(A,M,N) when A is a scalar is commonly used to produce
     * %   an M-by-N matrix filled with A's value.  This can be much faster
     * %   than A*ONES(M,N) when M and/or N are large.
     * %   
     * %   Example:
     * %       repmat(magic(2),2,3)
     * %       repmat(NaN,2,3)
     * %
     * %   See also MESHGRID.
     * 
     * %   Copyright 1984-2001 The MathWorks, Inc. 
     * %   $Revision: 1.16 $  $Date: 2001/04/15 12:02:28 $
     * 
     * if nargin < 2
     */
    if (nargin_ < 2) {
        /*
         * error('Requires at least 2 inputs.')
         */
        mlfError(_mxarray4_);
    /*
     * elseif nargin == 2
     */
    } else if (nargin_ == 2) {
        /*
         * if length(M)==1
         */
        if (mclLengthInt(mclVa(M, "M")) == 1) {
            /*
             * siz = [M M];
             */
            mlfAssign(&siz, mlfHorzcat(mclVa(M, "M"), mclVa(M, "M"), NULL));
        /*
         * else
         */
        } else {
            /*
             * siz = M;
             */
            mlfAssign(&siz, mclVsa(M, "M"));
        /*
         * end
         */
        }
    /*
     * else
     */
    } else {
        /*
         * siz = [M N];
         */
        mlfAssign(&siz, mlfHorzcat(mclVa(M, "M"), mclVa(N, "N"), NULL));
    /*
     * end
     */
    }
    /*
     * 
     * if length(A)==1
     */
    if (mclLengthInt(mclVa(A, "A")) == 1) {
        /*
         * nelems = prod(siz);
         */
        mlfAssign(&nelems, mlfProd(mclVv(siz, "siz"), NULL));
        /*
         * if nelems>0
         */
        if (mclGtBool(mclVv(nelems, "nelems"), _mxarray6_)) {
            /*
             * % Since B doesn't exist, the first statement creates a B with
             * % the right size and type.  Then use scalar expansion to
             * % fill the array.. Finally reshape to the specified size.
             * B(nelems) = A; 
             */
            mclArrayAssign1(&B, mclVsa(A, "A"), mclVsv(nelems, "nelems"));
            /*
             * B(:) = A;
             */
            mclArrayAssign1(&B, mclVsa(A, "A"), mlfCreateColonIndex());
            /*
             * B = reshape(B,siz);
             */
            mlfAssign(&B, mlfReshape(mclVv(B, "B"), mclVv(siz, "siz"), NULL));
        /*
         * else
         */
        } else {
            /*
             * B = A(ones(siz));
             */
            mlfAssign(
              &B,
              mclArrayRef1(mclVsa(A, "A"), mlfOnes(mclVv(siz, "siz"), NULL)));
        /*
         * end
         */
        }
    /*
     * elseif ndims(A)==2 & length(siz)==2
     */
    } else {
        mxArray * a_
          = mclInitialize(mclEq(mclVe(mlfNdims(mclVa(A, "A"))), _mxarray9_));
        if (mlfTobool(a_)
            && mlfTobool(
                 mclAnd(
                   a_,
                   mclBoolToArray(mclLengthInt(mclVv(siz, "siz")) == 2)))) {
            mxDestroyArray(a_);
            /*
             * [m,n] = size(A);
             */
            mlfSize(mlfVarargout(&m, &n, NULL), mclVa(A, "A"), NULL);
            /*
             * mind = (1:m)';
             */
            mlfAssign(
              &mind, mlfCtranspose(mlfColon(_mxarray7_, mclVv(m, "m"), NULL)));
            /*
             * nind = (1:n)';
             */
            mlfAssign(
              &nind, mlfCtranspose(mlfColon(_mxarray7_, mclVv(n, "n"), NULL)));
            /*
             * mind = mind(:,ones(1,siz(1)));
             */
            mlfAssign(
              &mind,
              mclArrayRef2(
                mclVsv(mind, "mind"),
                mlfCreateColonIndex(),
                mlfOnes(
                  _mxarray7_,
                  mclVe(mclIntArrayRef1(mclVsv(siz, "siz"), 1)),
                  NULL)));
            /*
             * nind = nind(:,ones(1,siz(2)));
             */
            mlfAssign(
              &nind,
              mclArrayRef2(
                mclVsv(nind, "nind"),
                mlfCreateColonIndex(),
                mlfOnes(
                  _mxarray7_,
                  mclVe(mclIntArrayRef1(mclVsv(siz, "siz"), 2)),
                  NULL)));
            /*
             * B = A(mind,nind);
             */
            mlfAssign(
              &B,
              mclArrayRef2(
                mclVsa(A, "A"), mclVsv(mind, "mind"), mclVsv(nind, "nind")));
        /*
         * else
         */
        } else {
            mxDestroyArray(a_);
            /*
             * Asiz = size(A);
             */
            mlfAssign(&Asiz, mlfSize(mclValueVarargout(), mclVa(A, "A"), NULL));
            /*
             * Asiz = [Asiz ones(1,length(siz)-length(Asiz))];
             */
            mlfAssign(
              &Asiz,
              mlfHorzcat(
                mclVv(Asiz, "Asiz"),
                mclVe(
                  mlfOnes(
                    _mxarray7_,
                    mlfScalar(
                      mclLengthInt(mclVv(siz, "siz"))
                      - mclLengthInt(mclVv(Asiz, "Asiz"))),
                    NULL)),
                NULL));
            /*
             * siz = [siz ones(1,length(Asiz)-length(siz))];
             */
            mlfAssign(
              &siz,
              mlfHorzcat(
                mclVv(siz, "siz"),
                mclVe(
                  mlfOnes(
                    _mxarray7_,
                    mlfScalar(
                      mclLengthInt(mclVv(Asiz, "Asiz"))
                      - mclLengthInt(mclVv(siz, "siz"))),
                    NULL)),
                NULL));
            /*
             * for i=length(Asiz):-1:1
             */
            {
                mclForLoopIterator viter__;
                for (mclForStart(
                       &viter__,
                       mlfScalar(mclLengthInt(mclVv(Asiz, "Asiz"))),
                       _mxarray8_,
                       _mxarray7_);
                     mclForNext(&viter__, &i);
                     ) {
                    /*
                     * ind = (1:Asiz(i))';
                     */
                    mlfAssign(
                      &ind,
                      mlfCtranspose(
                        mlfColon(
                          _mxarray7_,
                          mclVe(
                            mclArrayRef1(mclVsv(Asiz, "Asiz"), mclVsv(i, "i"))),
                          NULL)));
                    /*
                     * subs{i} = ind(:,ones(1,siz(i)));
                     */
                    mlfIndexAssign(
                      &subs,
                      "{?}",
                      mclVsv(i, "i"),
                      mclArrayRef2(
                        mclVsv(ind, "ind"),
                        mlfCreateColonIndex(),
                        mlfOnes(
                          _mxarray7_,
                          mclVe(
                            mclArrayRef1(mclVsv(siz, "siz"), mclVsv(i, "i"))),
                          NULL)));
                /*
                 * end
                 */
                }
                mclDestroyForLoopIterator(viter__);
            }
            /*
             * B = A(subs{:});
             */
            mlfAssign(
              &B,
              mclArrayRef1(
                mclVsa(A, "A"),
                mlfIndexRef(
                  mclVsv(subs, "subs"), "{?}", mlfCreateColonIndex())));
        }
    /*
     * end
     */
    }
    mclValidateOutput(B, 1, nargout_, "B", "repmat");
    mxDestroyArray(ans);
    mxDestroyArray(siz);
    mxDestroyArray(nelems);
    mxDestroyArray(m);
    mxDestroyArray(n);
    mxDestroyArray(mind);
    mxDestroyArray(nind);
    mxDestroyArray(Asiz);
    mxDestroyArray(i);
    mxDestroyArray(ind);
    mxDestroyArray(subs);
    mxDestroyArray(N);
    mxDestroyArray(M);
    mxDestroyArray(A);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return B;
}
