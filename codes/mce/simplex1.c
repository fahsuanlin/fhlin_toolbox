/*
 * MATLAB Compiler: 2.2
 * Date: Sat Nov 30 14:13:31 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "simplex1" 
 */
#include "simplex1.h"
#include "libmatlbm.h"
#include "pivottableau.h"
#include "rank.h"
#include "reducefree.h"
#include "restorefree.h"

static mxChar _array1_[134] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 's', 'i', 'm', 'p', 'l',
                                'e', 'x', '1', ' ', 'L', 'i', 'n', 'e', ':',
                                ' ', '1', ' ', 'C', 'o', 'l', 'u', 'm', 'n',
                                ':', ' ', '1', ' ', 'T', 'h', 'e', ' ', 'f',
                                'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', '"',
                                's', 'i', 'm', 'p', 'l', 'e', 'x', '1', '"',
                                ' ', 'w', 'a', 's', ' ', 'c', 'a', 'l', 'l',
                                'e', 'd', ' ', 'w', 'i', 't', 'h', ' ', 'm',
                                'o', 'r', 'e', ' ', 't', 'h', 'a', 'n', ' ',
                                't', 'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a',
                                'r', 'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e',
                                'r', ' ', 'o', 'f', ' ', 'o', 'u', 't', 'p',
                                'u', 't', 's', ' ', '(', '3', ')', '.' };
static mxArray * _mxarray0_;
static mxArray * _mxarray2_;
static mxArray * _mxarray3_;
static mxArray * _mxarray4_;
static mxArray * _mxarray5_;

static mxChar _array7_[12] = { 'f', 'l', 'a', 'g', '_', 'd',
                               'i', 's', 'p', 'l', 'a', 'y' };
static mxArray * _mxarray6_;

static mxChar _array9_[19] = { 'u', 'n', 'k', 'n', 'o', 'w', 'n', ' ', 'o', 'p',
                               't', 'i', 'o', 'n', ' ', '[', '%', 's', ']' };
static mxArray * _mxarray8_;

static mxChar _array11_[8] = { 'e', 'r', 'r', 'o', 'r', '!', 0x005c, 'n' };
static mxArray * _mxarray10_;

static mxChar _array13_[41] = { 'm', 'u', 's', 't', ' ', 'h', 'a', 'v', 'e',
                                ' ', 'm', 'o', 'r', 'e', ' ', 'v', 'a', 'r',
                                'i', 'a', 'b', 'l', 'e', 's', ' ', 't', 'h',
                                'a', 'n', ' ', 'c', 'o', 'n', 's', 't', 'r',
                                'a', 'i', 'n', 't', 's' };
static mxArray * _mxarray12_;

static mxChar _array15_[17] = { 'd', 'e', 'g', 'e', 'n', 'e', 'r', 'a', 't',
                                'e', ' ', 'm', 'a', 't', 'r', 'i', 'x' };
static mxArray * _mxarray14_;

static mxChar _array17_[44] = { 's', 'i', 'm', 'p', 'l', 'e', 'x', ' ', 'p',
                                'h', 'a', 's', 'e', ' ', '1', ':', ' ', 's',
                                'o', 'l', 'v', 'i', 'n', 'g', ' ', 'i', 'n',
                                'i', 't', '.', ' ', 's', 'o', 'l', 'u', 't',
                                'i', 'o', 'n', '.', '.', '.', 0x005c, 'n' };
static mxArray * _mxarray16_;

static mxChar _array19_[45] = { 's', 'i', 'm', 'p', 'l', 'e', 'x', ' ',
                                'p', 'h', 'a', 's', 'e', ' ', '2', ':',
                                ' ', 's', 'e', 'a', 'r', 'c', 'h', 'i',
                                'n', 'g', ' ', 'o', 'p', 't', '.', ' ',
                                's', 'o', 'l', 'u', 't', 'i', 'o', 'n',
                                '.', '.', '.', 0x005c, 'n' };
static mxArray * _mxarray18_;

static mxChar _array21_[36] = { 'C', 'a', 'n', 'n', 'o', 't', ' ', 'f', 'i',
                                'n', 'd', ' ', 'd', 'u', 'a', 'l', ' ', 'w',
                                'i', 't', 'h', ' ', 'f', 'r', 'e', 'e', ' ',
                                'v', 'a', 'r', 'i', 'a', 'b', 'l', 'e', 's' };
static mxArray * _mxarray20_;

void InitializeModule_simplex1(void) {
    _mxarray0_ = mclInitializeString(134, _array1_);
    _mxarray2_ = mclInitializeDouble(0.0);
    _mxarray3_ = mclInitializeDoubleVector(0, 0, (double *)NULL);
    _mxarray4_ = mclInitializeDouble(2.0);
    _mxarray5_ = mclInitializeDouble(1.0);
    _mxarray6_ = mclInitializeString(12, _array7_);
    _mxarray8_ = mclInitializeString(19, _array9_);
    _mxarray10_ = mclInitializeString(8, _array11_);
    _mxarray12_ = mclInitializeString(41, _array13_);
    _mxarray14_ = mclInitializeString(17, _array15_);
    _mxarray16_ = mclInitializeString(44, _array17_);
    _mxarray18_ = mclInitializeString(45, _array19_);
    _mxarray20_ = mclInitializeString(36, _array21_);
}

void TerminateModule_simplex1(void) {
    mxDestroyArray(_mxarray20_);
    mxDestroyArray(_mxarray18_);
    mxDestroyArray(_mxarray16_);
    mxDestroyArray(_mxarray14_);
    mxDestroyArray(_mxarray12_);
    mxDestroyArray(_mxarray10_);
    mxDestroyArray(_mxarray8_);
    mxDestroyArray(_mxarray6_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray3_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Msimplex1(mxArray * * value,
                           mxArray * * w,
                           int nargout_,
                           mxArray * A,
                           mxArray * b,
                           mxArray * c,
                           mxArray * freevars,
                           mxArray * varargin);

_mexLocalFunctionTable _local_function_table_simplex1
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfNSimplex1" contains the nargout interface for the
 * "simplex1" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/simplex1.
 * m" (lines 1-92). This interface is only produced if the M-function uses the
 * special variable "nargout". The nargout interface allows the number of
 * requested outputs to be specified via the nargout argument, as opposed to
 * the normal interface which dynamically calculates the number of outputs
 * based on the number of non-NULL inputs it receives. This function processes
 * any input arguments and passes them to the implementation version of the
 * function, appearing above.
 */
mxArray * mlfNSimplex1(int nargout,
                       mxArray * * value,
                       mxArray * * w,
                       mxArray * A,
                       mxArray * b,
                       mxArray * c,
                       mxArray * freevars,
                       ...) {
    mxArray * varargin = NULL;
    mxArray * x = mclGetUninitializedArray();
    mxArray * value__ = mclGetUninitializedArray();
    mxArray * w__ = mclGetUninitializedArray();
    mlfVarargin(&varargin, freevars, 0);
    mlfEnterNewContext(2, -5, value, w, A, b, c, freevars, varargin);
    x = Msimplex1(&value__, &w__, nargout, A, b, c, freevars, varargin);
    mlfRestorePreviousContext(2, 4, value, w, A, b, c, freevars);
    mxDestroyArray(varargin);
    if (value != NULL) {
        mclCopyOutputArg(value, value__);
    } else {
        mxDestroyArray(value__);
    }
    if (w != NULL) {
        mclCopyOutputArg(w, w__);
    } else {
        mxDestroyArray(w__);
    }
    return mlfReturnValue(x);
}

/*
 * The function "mlfSimplex1" contains the normal interface for the "simplex1"
 * M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/simplex1.
 * m" (lines 1-92). This function processes any input arguments and passes them
 * to the implementation version of the function, appearing above.
 */
mxArray * mlfSimplex1(mxArray * * value,
                      mxArray * * w,
                      mxArray * A,
                      mxArray * b,
                      mxArray * c,
                      mxArray * freevars,
                      ...) {
    mxArray * varargin = NULL;
    int nargout = 1;
    mxArray * x = mclGetUninitializedArray();
    mxArray * value__ = mclGetUninitializedArray();
    mxArray * w__ = mclGetUninitializedArray();
    mlfVarargin(&varargin, freevars, 0);
    mlfEnterNewContext(2, -5, value, w, A, b, c, freevars, varargin);
    if (value != NULL) {
        ++nargout;
    }
    if (w != NULL) {
        ++nargout;
    }
    x = Msimplex1(&value__, &w__, nargout, A, b, c, freevars, varargin);
    mlfRestorePreviousContext(2, 4, value, w, A, b, c, freevars);
    mxDestroyArray(varargin);
    if (value != NULL) {
        mclCopyOutputArg(value, value__);
    } else {
        mxDestroyArray(value__);
    }
    if (w != NULL) {
        mclCopyOutputArg(w, w__);
    } else {
        mxDestroyArray(w__);
    }
    return mlfReturnValue(x);
}

/*
 * The function "mlfVSimplex1" contains the void interface for the "simplex1"
 * M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/simplex1.
 * m" (lines 1-92). The void interface is only produced if the M-function uses
 * the special variable "nargout", and has at least one output. The void
 * interface function specifies zero output arguments to the implementation
 * version of the function, and in the event that the implementation version
 * still returns an output (which, in MATLAB, would be assigned to the "ans"
 * variable), it deallocates the output. This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
void mlfVSimplex1(mxArray * A,
                  mxArray * b,
                  mxArray * c,
                  mxArray * freevars,
                  ...) {
    mxArray * varargin = NULL;
    mxArray * x = NULL;
    mxArray * value = NULL;
    mxArray * w = NULL;
    mlfVarargin(&varargin, freevars, 0);
    mlfEnterNewContext(0, -5, A, b, c, freevars, varargin);
    x = Msimplex1(&value, &w, 0, A, b, c, freevars, varargin);
    mlfRestorePreviousContext(0, 4, A, b, c, freevars);
    mxDestroyArray(varargin);
    mxDestroyArray(x);
    mxDestroyArray(value);
}

/*
 * The function "mlxSimplex1" contains the feval interface for the "simplex1"
 * M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/simplex1.
 * m" (lines 1-92). The feval function calls the implementation version of
 * simplex1 through this function. This function processes any input arguments
 * and passes them to the implementation version of the function, appearing
 * above.
 */
void mlxSimplex1(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[5];
    mxArray * mplhs[3];
    int i;
    if (nlhs > 3) {
        mlfError(_mxarray0_);
    }
    for (i = 0; i < 3; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 4 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 4; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 4, mprhs[0], mprhs[1], mprhs[2], mprhs[3]);
    mprhs[4] = NULL;
    mlfAssign(&mprhs[4], mclCreateVararginCell(nrhs - 4, prhs + 4));
    mplhs[0]
      = Msimplex1(
          &mplhs[1],
          &mplhs[2],
          nlhs,
          mprhs[0],
          mprhs[1],
          mprhs[2],
          mprhs[3],
          mprhs[4]);
    mlfRestorePreviousContext(0, 4, mprhs[0], mprhs[1], mprhs[2], mprhs[3]);
    plhs[0] = mplhs[0];
    for (i = 1; i < 3 && i < nlhs; ++i) {
        plhs[i] = mplhs[i];
    }
    for (; i < 3; ++i) {
        mxDestroyArray(mplhs[i]);
    }
    mxDestroyArray(mprhs[4]);
}

/*
 * The function "Msimplex1" is the implementation version of the "simplex1"
 * M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/simplex1.
 * m" (lines 1-92). It contains the actual compiled code for that M-function.
 * It is a static function and must only be called from one of the interface
 * functions, appearing below.
 */
/*
 * function [x,value,w] = simplex1(A,b,c,freevars,varargin)
 */
static mxArray * Msimplex1(mxArray * * value,
                           mxArray * * w,
                           int nargout_,
                           mxArray * A,
                           mxArray * b,
                           mxArray * c,
                           mxArray * freevars,
                           mxArray * varargin) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_simplex1);
    int nargin_ = mclNargin(-5, A, b, c, freevars, varargin, NULL);
    mxArray * x = mclGetUninitializedArray();
    mxArray * cf = mclGetUninitializedArray();
    mxArray * ci = mclGetUninitializedArray();
    mxArray * B1i = mclGetUninitializedArray();
    mxArray * sbasicptr = mclGetUninitializedArray();
    mxArray * basicptr = mclGetUninitializedArray();
    mxArray * nn = mclGetUninitializedArray();
    mxArray * mn = mclGetUninitializedArray();
    mxArray * tableau = mclGetUninitializedArray();
    mxArray * idx = mclGetUninitializedArray();
    mxArray * savefree = mclGetUninitializedArray();
    mxArray * nfree = mclGetUninitializedArray();
    mxArray * nvars = mclGetUninitializedArray();
    mxArray * n = mclGetUninitializedArray();
    mxArray * m = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    mxArray * option_value = mclGetUninitializedArray();
    mxArray * option = mclGetUninitializedArray();
    mxArray * i = mclGetUninitializedArray();
    mxArray * flag_display = mclGetUninitializedArray();
    mclCopyArray(&A);
    mclCopyArray(&b);
    mclCopyArray(&c);
    mclCopyArray(&freevars);
    mclCopyArray(&varargin);
    /*
     * 
     * % 
     * 
     * % Find the solution of a linear programming problem in standard form
     * 
     * %  minimize c'x
     * 
     * %  subject to Ax=b
     * 
     * %             x >= 0
     * 
     * %
     * 
     * % function [x,value,w] = simplex1(A,b,c,freevars)
     * 
     * % 
     * 
     * % A, b, c: system problem
     * 
     * % freevars = (optional) list of free variables in problem
     * 
     * %
     * 
     * % x = solution
     * 
     * % value = value of solution
     * 
     * % w = (optiona)l solution of the dual problem.
     * 
     * %    If w is used as a return value, then the dual problem is also solved.
     * 
     * %    (In this implementation, the dual problem cannot be solved when free
     * 
     * %    variables are employed.)
     * 
     * 
     * 
     * % Copyright 1999 by Todd K. Moon
     * 
     * 
     * 
     * 
     * 
     * flag_display=0;
     */
    mlfAssign(&flag_display, _mxarray2_);
    /*
     * 
     * 
     * 
     * for i=1:length(varargin)/2
     */
    {
        int v_ = mclForIntStart(1);
        int e_
          = mclForIntEnd(
              mclMrdivide(
                mlfScalar(mclLengthInt(mclVa(varargin, "varargin"))),
                _mxarray4_));
        if (v_ > e_) {
            mlfAssign(&i, _mxarray3_);
        } else {
            /*
             * 
             * option=varargin{i*2-1};
             * 
             * option_value=varargin{i*2};
             * 
             * switch lower(option)
             * 
             * case 'flag_display'
             * 
             * flag_display=option_value;
             * 
             * otherwise
             * 
             * fprintf('unknown option [%s]',option);
             * 
             * fprintf('error!\n');
             * 
             * return;
             * 
             * end;
             * 
             * end;
             */
            for (; ; ) {
                mlfAssign(
                  &option,
                  mlfIndexRef(
                    mclVsa(varargin, "varargin"),
                    "{?}",
                    mclMinus(
                      mclMtimes(mlfScalar(v_), _mxarray4_), _mxarray5_)));
                mlfAssign(
                  &option_value,
                  mlfIndexRef(
                    mclVsa(varargin, "varargin"),
                    "{?}",
                    mclMtimes(mlfScalar(v_), _mxarray4_)));
                {
                    mxArray * v_0
                      = mclInitialize(
                          mclVe(mlfLower(mclVv(option, "option"))));
                    if (mclSwitchCompare(v_0, _mxarray6_)) {
                        mlfAssign(
                          &flag_display, mclVsv(option_value, "option_value"));
                    } else {
                        mclAssignAns(
                          &ans,
                          mlfNFprintf(
                            0, _mxarray8_, mclVv(option, "option"), NULL));
                        mclAssignAns(&ans, mlfNFprintf(0, _mxarray10_, NULL));
                        mxDestroyArray(v_0);
                        goto return_;
                    }
                    mxDestroyArray(v_0);
                }
                if (v_ == e_) {
                    break;
                }
                ++v_;
            }
            mlfAssign(&i, mlfScalar(v_));
        }
    }
    /*
     * 
     * 
     * 
     * 
     * 
     * [m,n] = size(A);
     */
    mlfSize(mlfVarargout(&m, &n, NULL), mclVa(A, "A"), NULL);
    /*
     * 
     * nvars = n;                              % save this in case is changes
     */
    mlfAssign(&nvars, mclVsv(n, "n"));
    /*
     * 
     * if(m >= n)
     */
    if (mclGeBool(mclVv(m, "m"), mclVv(n, "n"))) {
        /*
         * 
         * error('must have more variables than constraints');
         */
        mlfError(_mxarray12_);
    /*
     * 
     * end
     */
    }
    /*
     * 
     * if(rank(A) < m)
     */
    if (mclLtBool(mclVe(mlfRank(mclVa(A, "A"), NULL)), mclVv(m, "m"))) {
        /*
         * 
         * error('degenerate matrix');
         */
        mlfError(_mxarray14_);
    /*
     * 
     * end
     */
    }
    /*
     * 
     * value = 0;                              % value of the tableau
     */
    mlfAssign(value, _mxarray2_);
    /*
     * 
     * nfree = 0;                              % number of free variables
     */
    mlfAssign(&nfree, _mxarray2_);
    /*
     * 
     * 
     * 
     * if(nargin == 4)         % a list of free variables was passed
     */
    if (nargin_ == 4) {
        /*
         * 
         * [A,b,c,value,savefree,nfree] = reducefree(A,b,c,freevars);
         */
        mlfAssign(
          &A,
          mlfReducefree(
            &b,
            &c,
            value,
            &savefree,
            &nfree,
            mclVa(A, "A"),
            mclVa(b, "b"),
            mclVa(c, "c"),
            mclVa(freevars, "freevars")));
        /*
         * 
         * [m,n] = size(A);
         */
        mlfSize(mlfVarargout(&m, &n, NULL), mclVa(A, "A"), NULL);
    /*
     * 
     * end
     */
    }
    /*
     * 
     * 
     * 
     * fprintf('simplex phase 1: solving init. solution...\n');
     */
    mclAssignAns(&ans, mlfNFprintf(0, _mxarray16_, NULL));
    /*
     * 
     * 
     * 
     * % Phase I: Find a basic solution by the use of artificial variables
     * 
     * idx = b<0; A(idx,:) = -A(idx,:); b(idx) = -b(idx);
     */
    mlfAssign(&idx, mclLt(mclVa(b, "b"), _mxarray2_));
    mclArrayAssign2(
      &A,
      mclUminus(
        mclVe(
          mclArrayRef2(
            mclVsa(A, "A"), mclVsv(idx, "idx"), mlfCreateColonIndex()))),
      mclVsv(idx, "idx"),
      mlfCreateColonIndex());
    mclArrayAssign1(
      &b,
      mclUminus(mclVe(mclArrayRef1(mclVsa(b, "b"), mclVsv(idx, "idx")))),
      mclVsv(idx, "idx"));
    /*
     * 
     * tableau = [A eye(m) b;  -sum(A,1) zeros(1,m) -sum(b)];
     */
    mlfAssign(
      &tableau,
      mlfVertcat(
        mlfHorzcat(
          mclVa(A, "A"),
          mclVe(mlfEye(mclVv(m, "m"), NULL)),
          mclVa(b, "b"),
          NULL),
        mlfHorzcat(
          mclUminus(mclVe(mlfSum(mclVa(A, "A"), _mxarray5_))),
          mclVe(mlfZeros(_mxarray5_, mclVv(m, "m"), NULL)),
          mclUminus(mclVe(mlfSum(mclVa(b, "b"), NULL))),
          NULL),
        NULL));
    /*
     * 
     * [mn,nn] = size(tableau);
     */
    mlfSize(mlfVarargout(&mn, &nn, NULL), mclVv(tableau, "tableau"), NULL);
    /*
     * 
     * basicptr = [n+1:n+m];
     */
    mlfAssign(
      &basicptr,
      mlfColon(
        mclPlus(mclVv(n, "n"), _mxarray5_),
        mclPlus(mclVv(n, "n"), mclVv(m, "m")),
        NULL));
    /*
     * 
     * [tableau,basicptr] = pivottableau(tableau,basicptr,'flag_display',flag_display);
     */
    mlfAssign(
      &tableau,
      mlfPivottableau(
        &basicptr,
        NULL,
        mclVv(tableau, "tableau"),
        mclVv(basicptr, "basicptr"),
        _mxarray6_,
        mclVv(flag_display, "flag_display"),
        NULL));
    /*
     * 
     * sbasicptr = basicptr;
     */
    mlfAssign(&sbasicptr, mclVsv(basicptr, "basicptr"));
    /*
     * 
     * B1i = tableau(1:m,n+1:n+m);             % for dual
     */
    mlfAssign(
      &B1i,
      mclArrayRef2(
        mclVsv(tableau, "tableau"),
        mlfColon(_mxarray5_, mclVv(m, "m"), NULL),
        mlfColon(
          mclPlus(mclVv(n, "n"), _mxarray5_),
          mclPlus(mclVv(n, "n"), mclVv(m, "m")),
          NULL)));
    /*
     * 
     * % Build the tableau for phase II
     * 
     * 
     * 
     * tableau = [tableau(1:m,1:n) tableau(1:m,nn); c' value];
     */
    mlfAssign(
      &tableau,
      mlfVertcat(
        mlfHorzcat(
          mclVe(
            mclArrayRef2(
              mclVsv(tableau, "tableau"),
              mlfColon(_mxarray5_, mclVv(m, "m"), NULL),
              mlfColon(_mxarray5_, mclVv(n, "n"), NULL))),
          mclVe(
            mclArrayRef2(
              mclVsv(tableau, "tableau"),
              mlfColon(_mxarray5_, mclVv(m, "m"), NULL),
              mclVsv(nn, "nn"))),
          NULL),
        mlfHorzcat(mlfCtranspose(mclVa(c, "c")), mclVv(*value, "value"), NULL),
        NULL));
    /*
     * 
     * ci = tableau(end,sbasicptr)';           % for dual
     */
    mlfAssign(
      &ci,
      mlfCtranspose(
        mclVe(
          mclArrayRef2(
            mclVsv(tableau, "tableau"),
            mlfEnd(mclVv(tableau, "tableau"), _mxarray5_, _mxarray4_),
            mclVsv(sbasicptr, "sbasicptr")))));
    /*
     * 
     * % transform so there are zeros in the basic columns
     * 
     * for i = 1:m
     */
    {
        int v_ = mclForIntStart(1);
        int e_ = mclForIntEnd(mclVv(m, "m"));
        if (v_ > e_) {
            mlfAssign(&i, _mxarray3_);
        } else {
            /*
             * 
             * tableau(mn,:) = tableau(mn,:) - c(basicptr(i))*tableau(i,:);
             * 
             * end
             */
            for (; ; ) {
                mclArrayAssign2(
                  &tableau,
                  mclMinus(
                    mclVe(
                      mclArrayRef2(
                        mclVsv(tableau, "tableau"),
                        mclVsv(mn, "mn"),
                        mlfCreateColonIndex())),
                    mclMtimes(
                      mclVe(
                        mclArrayRef1(
                          mclVsa(c, "c"),
                          mclIntArrayRef1(mclVsv(basicptr, "basicptr"), v_))),
                      mclVe(
                        mclArrayRef2(
                          mclVsv(tableau, "tableau"),
                          mlfScalar(v_),
                          mlfCreateColonIndex())))),
                  mclVsv(mn, "mn"),
                  mlfCreateColonIndex());
                if (v_ == e_) {
                    break;
                }
                ++v_;
            }
            mlfAssign(&i, mlfScalar(v_));
        }
    }
    /*
     * 
     * 
     * 
     * fprintf('simplex phase 2: searching opt. solution...\n');
     */
    mclAssignAns(&ans, mlfNFprintf(0, _mxarray18_, NULL));
    /*
     * 
     * 
     * 
     * % Phase II
     * 
     * [tableau,basicptr] = pivottableau(tableau,basicptr,'flag_display',flag_display);
     */
    mlfAssign(
      &tableau,
      mlfPivottableau(
        &basicptr,
        NULL,
        mclVv(tableau, "tableau"),
        mclVv(basicptr, "basicptr"),
        _mxarray6_,
        mclVv(flag_display, "flag_display"),
        NULL));
    /*
     * 
     * cf = tableau(end,sbasicptr)';           % for dual
     */
    mlfAssign(
      &cf,
      mlfCtranspose(
        mclVe(
          mclArrayRef2(
            mclVsv(tableau, "tableau"),
            mlfEnd(mclVv(tableau, "tableau"), _mxarray5_, _mxarray4_),
            mclVsv(sbasicptr, "sbasicptr")))));
    /*
     * 
     * x = zeros(1,n);
     */
    mlfAssign(&x, mlfZeros(_mxarray5_, mclVv(n, "n"), NULL));
    /*
     * 
     * x(basicptr) = tableau(1:m,end);
     */
    mclArrayAssign1(
      &x,
      mclArrayRef2(
        mclVsv(tableau, "tableau"),
        mlfColon(_mxarray5_, mclVv(m, "m"), NULL),
        mlfEnd(mclVv(tableau, "tableau"), _mxarray4_, _mxarray4_)),
      mclVsv(basicptr, "basicptr"));
    /*
     * 
     * value = -tableau(end,end);
     */
    mlfAssign(
      value,
      mclUminus(
        mclVe(
          mclArrayRef2(
            mclVsv(tableau, "tableau"),
            mlfEnd(mclVv(tableau, "tableau"), _mxarray5_, _mxarray4_),
            mlfEnd(mclVv(tableau, "tableau"), _mxarray4_, _mxarray4_)))));
    /*
     * 
     * 
     * 
     * if(nfree)
     */
    if (mlfTobool(mclVv(nfree, "nfree"))) {
        /*
         * 
         * x = restorefree(x,savefree,freevars);
         */
        mlfAssign(
          &x,
          mlfRestorefree(
            mclVv(x, "x"),
            mclVv(savefree, "savefree"),
            mclVa(freevars, "freevars")));
    /*
     * 
     * end
     */
    }
    /*
     * 
     * 
     * 
     * if(nargout==3)
     */
    if (nargout_ == 3) {
        /*
         * 
         * if(nargin == 4)
         */
        if (nargin_ == 4) {
            /*
             * 
             * error('Cannot find dual with free variables');
             */
            mlfError(_mxarray20_);
        /*
         * 
         * end
         */
        }
        /*
         * 
         * w = B1i'*(ci-cf);                     % fix solution
         */
        mlfAssign(
          w,
          mclMtimes(
            mlfCtranspose(mclVv(B1i, "B1i")),
            mclMinus(mclVv(ci, "ci"), mclVv(cf, "cf"))));
    /*
     * 
     * end
     */
    }
    return_:
    mclValidateOutput(x, 1, nargout_, "x", "simplex1");
    mclValidateOutput(*value, 2, nargout_, "value", "simplex1");
    mclValidateOutput(*w, 3, nargout_, "w", "simplex1");
    mxDestroyArray(flag_display);
    mxDestroyArray(i);
    mxDestroyArray(option);
    mxDestroyArray(option_value);
    mxDestroyArray(ans);
    mxDestroyArray(m);
    mxDestroyArray(n);
    mxDestroyArray(nvars);
    mxDestroyArray(nfree);
    mxDestroyArray(savefree);
    mxDestroyArray(idx);
    mxDestroyArray(tableau);
    mxDestroyArray(mn);
    mxDestroyArray(nn);
    mxDestroyArray(basicptr);
    mxDestroyArray(sbasicptr);
    mxDestroyArray(B1i);
    mxDestroyArray(ci);
    mxDestroyArray(cf);
    mxDestroyArray(varargin);
    mxDestroyArray(freevars);
    mxDestroyArray(c);
    mxDestroyArray(b);
    mxDestroyArray(A);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return x;
}
