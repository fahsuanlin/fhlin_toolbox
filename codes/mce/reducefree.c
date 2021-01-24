/*
 * MATLAB Compiler: 2.2
 * Date: Sat Nov 30 14:13:31 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "simplex1" 
 */
#include "reducefree.h"
#include "libmatlbm.h"

static mxChar _array1_[138] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 'd', 'u', 'c',
                                'e', 'f', 'r', 'e', 'e', ' ', 'L', 'i', 'n',
                                'e', ':', ' ', '1', ' ', 'C', 'o', 'l', 'u',
                                'm', 'n', ':', ' ', '1', ' ', 'T', 'h', 'e',
                                ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n',
                                ' ', '"', 'r', 'e', 'd', 'u', 'c', 'e', 'f',
                                'r', 'e', 'e', '"', ' ', 'w', 'a', 's', ' ',
                                'c', 'a', 'l', 'l', 'e', 'd', ' ', 'w', 'i',
                                't', 'h', ' ', 'm', 'o', 'r', 'e', ' ', 't',
                                'h', 'a', 'n', ' ', 't', 'h', 'e', ' ', 'd',
                                'e', 'c', 'l', 'a', 'r', 'e', 'd', ' ', 'n',
                                'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ',
                                'o', 'u', 't', 'p', 'u', 't', 's', ' ', '(',
                                '6', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[137] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 'd', 'u', 'c',
                                'e', 'f', 'r', 'e', 'e', ' ', 'L', 'i', 'n',
                                'e', ':', ' ', '1', ' ', 'C', 'o', 'l', 'u',
                                'm', 'n', ':', ' ', '1', ' ', 'T', 'h', 'e',
                                ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n',
                                ' ', '"', 'r', 'e', 'd', 'u', 'c', 'e', 'f',
                                'r', 'e', 'e', '"', ' ', 'w', 'a', 's', ' ',
                                'c', 'a', 'l', 'l', 'e', 'd', ' ', 'w', 'i',
                                't', 'h', ' ', 'm', 'o', 'r', 'e', ' ', 't',
                                'h', 'a', 'n', ' ', 't', 'h', 'e', ' ', 'd',
                                'e', 'c', 'l', 'a', 'r', 'e', 'd', ' ', 'n',
                                'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ',
                                'i', 'n', 'p', 'u', 't', 's', ' ', '(', '4',
                                ')', '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;
static mxArray * _mxarray5_;
static mxArray * _mxarray6_;

static mxChar _array8_[17] = { 'd', 'e', 'g', 'e', 'n', 'e', 'r', 'a', 't',
                               'e', ' ', 'm', 'a', 't', 'r', 'i', 'x' };
static mxArray * _mxarray7_;
static mxArray * _mxarray9_;

void InitializeModule_reducefree(void) {
    _mxarray0_ = mclInitializeString(138, _array1_);
    _mxarray2_ = mclInitializeString(137, _array3_);
    _mxarray4_ = mclInitializeDouble(0.0);
    _mxarray5_ = mclInitializeDouble(1.0);
    _mxarray6_ = mclInitializeDoubleVector(0, 0, (double *)NULL);
    _mxarray7_ = mclInitializeString(17, _array8_);
    _mxarray9_ = mclInitializeDouble(2.0);
}

void TerminateModule_reducefree(void) {
    mxDestroyArray(_mxarray9_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray6_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mreducefree(mxArray * * b,
                             mxArray * * c,
                             mxArray * * value,
                             mxArray * * savefree,
                             mxArray * * nfree,
                             int nargout_,
                             mxArray * A_in,
                             mxArray * b_in,
                             mxArray * c_in,
                             mxArray * freevars);

_mexLocalFunctionTable _local_function_table_reducefree
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfReducefree" contains the normal interface for the
 * "reducefree" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/reducefre
 * e.m" (lines 1-48). This function processes any input arguments and passes
 * them to the implementation version of the function, appearing above.
 */
mxArray * mlfReducefree(mxArray * * b,
                        mxArray * * c,
                        mxArray * * value,
                        mxArray * * savefree,
                        mxArray * * nfree,
                        mxArray * A_in,
                        mxArray * b_in,
                        mxArray * c_in,
                        mxArray * freevars) {
    int nargout = 1;
    mxArray * A = mclGetUninitializedArray();
    mxArray * b__ = mclGetUninitializedArray();
    mxArray * c__ = mclGetUninitializedArray();
    mxArray * value__ = mclGetUninitializedArray();
    mxArray * savefree__ = mclGetUninitializedArray();
    mxArray * nfree__ = mclGetUninitializedArray();
    mlfEnterNewContext(
      5, 4, b, c, value, savefree, nfree, A_in, b_in, c_in, freevars);
    if (b != NULL) {
        ++nargout;
    }
    if (c != NULL) {
        ++nargout;
    }
    if (value != NULL) {
        ++nargout;
    }
    if (savefree != NULL) {
        ++nargout;
    }
    if (nfree != NULL) {
        ++nargout;
    }
    A
      = Mreducefree(
          &b__,
          &c__,
          &value__,
          &savefree__,
          &nfree__,
          nargout,
          A_in,
          b_in,
          c_in,
          freevars);
    mlfRestorePreviousContext(
      5, 4, b, c, value, savefree, nfree, A_in, b_in, c_in, freevars);
    if (b != NULL) {
        mclCopyOutputArg(b, b__);
    } else {
        mxDestroyArray(b__);
    }
    if (c != NULL) {
        mclCopyOutputArg(c, c__);
    } else {
        mxDestroyArray(c__);
    }
    if (value != NULL) {
        mclCopyOutputArg(value, value__);
    } else {
        mxDestroyArray(value__);
    }
    if (savefree != NULL) {
        mclCopyOutputArg(savefree, savefree__);
    } else {
        mxDestroyArray(savefree__);
    }
    if (nfree != NULL) {
        mclCopyOutputArg(nfree, nfree__);
    } else {
        mxDestroyArray(nfree__);
    }
    return mlfReturnValue(A);
}

/*
 * The function "mlxReducefree" contains the feval interface for the
 * "reducefree" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/reducefre
 * e.m" (lines 1-48). The feval function calls the implementation version of
 * reducefree through this function. This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
void mlxReducefree(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[4];
    mxArray * mplhs[6];
    int i;
    if (nlhs > 6) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 4) {
        mlfError(_mxarray2_);
    }
    for (i = 0; i < 6; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 4 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 4; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 4, mprhs[0], mprhs[1], mprhs[2], mprhs[3]);
    mplhs[0]
      = Mreducefree(
          &mplhs[1],
          &mplhs[2],
          &mplhs[3],
          &mplhs[4],
          &mplhs[5],
          nlhs,
          mprhs[0],
          mprhs[1],
          mprhs[2],
          mprhs[3]);
    mlfRestorePreviousContext(0, 4, mprhs[0], mprhs[1], mprhs[2], mprhs[3]);
    plhs[0] = mplhs[0];
    for (i = 1; i < 6 && i < nlhs; ++i) {
        plhs[i] = mplhs[i];
    }
    for (; i < 6; ++i) {
        mxDestroyArray(mplhs[i]);
    }
}

/*
 * The function "Mreducefree" is the implementation version of the "reducefree"
 * M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/reducefre
 * e.m" (lines 1-48). It contains the actual compiled code for that M-function.
 * It is a static function and must only be called from one of the interface
 * functions, appearing below.
 */
/*
 * function [A,b,c,value,savefree,nfree] = reducefree(A,b,c,freevars)
 */
static mxArray * Mreducefree(mxArray * * b,
                             mxArray * * c,
                             mxArray * * value,
                             mxArray * * savefree,
                             mxArray * * nfree,
                             int nargout_,
                             mxArray * A_in,
                             mxArray * b_in,
                             mxArray * c_in,
                             mxArray * freevars) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_reducefree);
    mxArray * A = mclGetUninitializedArray();
    mxArray * k = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    mxArray * idx = mclGetUninitializedArray();
    mxArray * p = mclGetUninitializedArray();
    mxArray * i = mclGetUninitializedArray();
    mxArray * nvars = mclGetUninitializedArray();
    mxArray * rowout = mclGetUninitializedArray();
    mxArray * nn = mclGetUninitializedArray();
    mxArray * mn = mclGetUninitializedArray();
    mxArray * tableau = mclGetUninitializedArray();
    mxArray * n = mclGetUninitializedArray();
    mxArray * m = mclGetUninitializedArray();
    mclCopyInputArg(&A, A_in);
    mclCopyInputArg(b, b_in);
    mclCopyInputArg(c, c_in);
    mclCopyArray(&freevars);
    /*
     * 
     * % 
     * 
     * % Perform elimination on the free variables in a linear programming problem
     * 
     * %
     * 
     * % function [A,b,c,value,savefree,nfree] = reducefree(A,b,c,freevars)
     * 
     * % 
     * 
     * % A,b,c = parameters from linear programming problem
     * 
     * % freevars = list of free variables
     * 
     * %
     * 
     * % A,b,c = new parameters for linear programming problem (with free variables
     * 
     * %         eliminated)
     * 
     * % value = value of linear program
     * 
     * % savefree = tableau information for restoring free variables
     * 
     * % nfree = number of free variables found
     * 
     * 
     * 
     * % Copyright 1999 by Todd K. Moon
     * 
     * 
     * 
     * nfree = 0;
     */
    mlfAssign(nfree, _mxarray4_);
    /*
     * 
     * [m,n] = size(A);
     */
    mlfSize(mlfVarargout(&m, &n, NULL), mclVa(A, "A"), NULL);
    /*
     * 
     * tableau = [A b; c' 0];
     */
    mlfAssign(
      &tableau,
      mlfVertcat(
        mlfHorzcat(mclVa(A, "A"), mclVa(*b, "b"), NULL),
        mlfHorzcat(mlfCtranspose(mclVa(*c, "c")), _mxarray4_, NULL),
        NULL));
    /*
     * 
     * [mn,nn] = size(tableau);
     */
    mlfSize(mlfVarargout(&mn, &nn, NULL), mclVv(tableau, "tableau"), NULL);
    /*
     * 
     * rowout = logical(zeros(1,mn));
     */
    mlfAssign(
      &rowout, mlfLogical(mclVe(mlfZeros(_mxarray5_, mclVv(mn, "mn"), NULL))));
    /*
     * 
     * savefree = [];
     */
    mlfAssign(savefree, _mxarray6_);
    /*
     * 
     * nvars = n;
     */
    mlfAssign(&nvars, mclVsv(n, "n"));
    /*
     * 
     * for i=1:n
     */
    {
        int v_ = mclForIntStart(1);
        int e_ = mclForIntEnd(mclVv(n, "n"));
        if (v_ > e_) {
            mlfAssign(&i, _mxarray6_);
        } else {
            /*
             * 
             * if(freevars(i))                       % pivot on this column
             * 
             * nfree = nfree+1;
             * 
             * [p,idx] = max(abs(tableau(1:m,i)));
             * 
             * % pivot on row idx
             * 
             * if(p==0)
             * 
             * error('degenerate matrix')
             * 
             * end
             * 
             * rowout(idx) = 1;
             * 
             * p = tableau(idx,i);
             * 
             * tableau(idx,:) = tableau(idx,:)/p;
             * 
             * savefree = [savefree; tableau(idx,:)];
             * 
             * for k=1:mn
             * 
             * if(~rowout(k))
             * 
             * tableau(k,:) = tableau(k,:) - tableau(idx,:) .* tableau(k,i);
             * 
             * end
             * 
             * end
             * 
             * end
             * 
             * end
             */
            for (; ; ) {
                if (mlfTobool(
                      mclVe(
                        mclIntArrayRef1(mclVsa(freevars, "freevars"), v_)))) {
                    mlfAssign(
                      nfree, mclPlus(mclVv(*nfree, "nfree"), _mxarray5_));
                    mlfAssign(
                      &p,
                      mlfMax(
                        &idx,
                        mclVe(
                          mlfAbs(
                            mclVe(
                              mclArrayRef2(
                                mclVsv(tableau, "tableau"),
                                mlfColon(_mxarray5_, mclVv(m, "m"), NULL),
                                mlfScalar(v_))))),
                        NULL,
                        NULL));
                    if (mclEqBool(mclVv(p, "p"), _mxarray4_)) {
                        mlfError(_mxarray7_);
                    }
                    mclArrayAssign1(&rowout, _mxarray5_, mclVsv(idx, "idx"));
                    mlfAssign(
                      &p,
                      mclArrayRef2(
                        mclVsv(tableau, "tableau"),
                        mclVsv(idx, "idx"),
                        mlfScalar(v_)));
                    mclArrayAssign2(
                      &tableau,
                      mclMrdivide(
                        mclVe(
                          mclArrayRef2(
                            mclVsv(tableau, "tableau"),
                            mclVsv(idx, "idx"),
                            mlfCreateColonIndex())),
                        mclVv(p, "p")),
                      mclVsv(idx, "idx"),
                      mlfCreateColonIndex());
                    mlfAssign(
                      savefree,
                      mlfVertcat(
                        mclVv(*savefree, "savefree"),
                        mclVe(
                          mclArrayRef2(
                            mclVsv(tableau, "tableau"),
                            mclVsv(idx, "idx"),
                            mlfCreateColonIndex())),
                        NULL));
                    {
                        int v_0 = mclForIntStart(1);
                        int e_0 = mclForIntEnd(mclVv(mn, "mn"));
                        if (v_0 > e_0) {
                            mlfAssign(&k, _mxarray6_);
                        } else {
                            for (; ; ) {
                                if (mclNotBool(
                                      mclVe(
                                        mclIntArrayRef1(
                                          mclVsv(rowout, "rowout"), v_0)))) {
                                    mclArrayAssign2(
                                      &tableau,
                                      mclMinus(
                                        mclVe(
                                          mclArrayRef2(
                                            mclVsv(tableau, "tableau"),
                                            mlfScalar(v_0),
                                            mlfCreateColonIndex())),
                                        mclTimes(
                                          mclVe(
                                            mclArrayRef2(
                                              mclVsv(tableau, "tableau"),
                                              mclVsv(idx, "idx"),
                                              mlfCreateColonIndex())),
                                          mclVe(
                                            mclIntArrayRef2(
                                              mclVsv(tableau, "tableau"),
                                              v_0,
                                              v_)))),
                                      mlfScalar(v_0),
                                      mlfCreateColonIndex());
                                }
                                if (v_0 == e_0) {
                                    break;
                                }
                                ++v_0;
                            }
                            mlfAssign(&k, mlfScalar(v_0));
                        }
                    }
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
     * rowout = rowout(1:end-1);
     */
    mlfAssign(
      &rowout,
      mclArrayRef1(
        mclVsv(rowout, "rowout"),
        mlfColon(
          _mxarray5_,
          mclMinus(
            mlfEnd(mclVv(rowout, "rowout"), _mxarray5_, _mxarray5_),
            _mxarray5_),
          NULL)));
    /*
     * 
     * b = -tableau(~rowout,end);
     */
    mlfAssign(
      b,
      mclUminus(
        mclVe(
          mclArrayRef2(
            mclVsv(tableau, "tableau"),
            mclNot(mclVv(rowout, "rowout")),
            mlfEnd(mclVv(tableau, "tableau"), _mxarray9_, _mxarray9_)))));
    /*
     * 
     * A = -tableau(~rowout,~freevars);
     */
    mlfAssign(
      &A,
      mclUminus(
        mclVe(
          mclArrayRef2(
            mclVsv(tableau, "tableau"),
            mclNot(mclVv(rowout, "rowout")),
            mclNot(mclVa(freevars, "freevars"))))));
    /*
     * 
     * c = tableau(mn,~freevars)';
     */
    mlfAssign(
      c,
      mlfCtranspose(
        mclVe(
          mclArrayRef2(
            mclVsv(tableau, "tableau"),
            mclVsv(mn, "mn"),
            mclNot(mclVa(freevars, "freevars"))))));
    /*
     * 
     * value = tableau(mn,nn);
     */
    mlfAssign(
      value,
      mclArrayRef2(
        mclVsv(tableau, "tableau"), mclVsv(mn, "mn"), mclVsv(nn, "nn")));
    mclVo(&A);
    mclVo(b);
    mclVo(c);
    mclValidateOutput(A, 1, nargout_, "A", "reducefree");
    mclValidateOutput(*b, 2, nargout_, "b", "reducefree");
    mclValidateOutput(*c, 3, nargout_, "c", "reducefree");
    mclValidateOutput(*value, 4, nargout_, "value", "reducefree");
    mclValidateOutput(*savefree, 5, nargout_, "savefree", "reducefree");
    mclValidateOutput(*nfree, 6, nargout_, "nfree", "reducefree");
    mxDestroyArray(m);
    mxDestroyArray(n);
    mxDestroyArray(tableau);
    mxDestroyArray(mn);
    mxDestroyArray(nn);
    mxDestroyArray(rowout);
    mxDestroyArray(nvars);
    mxDestroyArray(i);
    mxDestroyArray(p);
    mxDestroyArray(idx);
    mxDestroyArray(ans);
    mxDestroyArray(k);
    mxDestroyArray(freevars);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return A;
}
