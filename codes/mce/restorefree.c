/*
 * MATLAB Compiler: 2.2
 * Date: Sat Nov 30 14:13:31 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "simplex1" 
 */
#include "restorefree.h"
#include "libmatlbm.h"

static mxChar _array1_[140] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 's', 't', 'o',
                                'r', 'e', 'f', 'r', 'e', 'e', ' ', 'L', 'i',
                                'n', 'e', ':', ' ', '1', ' ', 'C', 'o', 'l',
                                'u', 'm', 'n', ':', ' ', '1', ' ', 'T', 'h',
                                'e', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o',
                                'n', ' ', '"', 'r', 'e', 's', 't', 'o', 'r',
                                'e', 'f', 'r', 'e', 'e', '"', ' ', 'w', 'a',
                                's', ' ', 'c', 'a', 'l', 'l', 'e', 'd', ' ',
                                'w', 'i', 't', 'h', ' ', 'm', 'o', 'r', 'e',
                                ' ', 't', 'h', 'a', 'n', ' ', 't', 'h', 'e',
                                ' ', 'd', 'e', 'c', 'l', 'a', 'r', 'e', 'd',
                                ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o',
                                'f', ' ', 'o', 'u', 't', 'p', 'u', 't', 's',
                                ' ', '(', '1', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[139] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 's', 't', 'o',
                                'r', 'e', 'f', 'r', 'e', 'e', ' ', 'L', 'i',
                                'n', 'e', ':', ' ', '1', ' ', 'C', 'o', 'l',
                                'u', 'm', 'n', ':', ' ', '1', ' ', 'T', 'h',
                                'e', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o',
                                'n', ' ', '"', 'r', 'e', 's', 't', 'o', 'r',
                                'e', 'f', 'r', 'e', 'e', '"', ' ', 'w', 'a',
                                's', ' ', 'c', 'a', 'l', 'l', 'e', 'd', ' ',
                                'w', 'i', 't', 'h', ' ', 'm', 'o', 'r', 'e',
                                ' ', 't', 'h', 'a', 'n', ' ', 't', 'h', 'e',
                                ' ', 'd', 'e', 'c', 'l', 'a', 'r', 'e', 'd',
                                ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o',
                                'f', ' ', 'i', 'n', 'p', 'u', 't', 's', ' ',
                                '(', '3', ')', '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;
static mxArray * _mxarray5_;
static mxArray * _mxarray6_;
static mxArray * _mxarray7_;
static mxArray * _mxarray8_;

void InitializeModule_restorefree(void) {
    _mxarray0_ = mclInitializeString(140, _array1_);
    _mxarray2_ = mclInitializeString(139, _array3_);
    _mxarray4_ = mclInitializeDouble(1.0);
    _mxarray5_ = mclInitializeDoubleVector(0, 0, (double *)NULL);
    _mxarray6_ = mclInitializeDouble(0.0);
    _mxarray7_ = mclInitializeDouble(-1.0);
    _mxarray8_ = mclInitializeDouble(2.0);
}

void TerminateModule_restorefree(void) {
    mxDestroyArray(_mxarray8_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray6_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mrestorefree(int nargout_,
                              mxArray * inx,
                              mxArray * savefree,
                              mxArray * freevars);

_mexLocalFunctionTable _local_function_table_restorefree
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfRestorefree" contains the normal interface for the
 * "restorefree" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/restorefr
 * ee.m" (lines 1-36). This function processes any input arguments and passes
 * them to the implementation version of the function, appearing above.
 */
mxArray * mlfRestorefree(mxArray * inx,
                         mxArray * savefree,
                         mxArray * freevars) {
    int nargout = 1;
    mxArray * x = mclGetUninitializedArray();
    mlfEnterNewContext(0, 3, inx, savefree, freevars);
    x = Mrestorefree(nargout, inx, savefree, freevars);
    mlfRestorePreviousContext(0, 3, inx, savefree, freevars);
    return mlfReturnValue(x);
}

/*
 * The function "mlxRestorefree" contains the feval interface for the
 * "restorefree" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/restorefr
 * ee.m" (lines 1-36). The feval function calls the implementation version of
 * restorefree through this function. This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
void mlxRestorefree(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
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
    mplhs[0] = Mrestorefree(nlhs, mprhs[0], mprhs[1], mprhs[2]);
    mlfRestorePreviousContext(0, 3, mprhs[0], mprhs[1], mprhs[2]);
    plhs[0] = mplhs[0];
}

/*
 * The function "Mrestorefree" is the implementation version of the
 * "restorefree" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/restorefr
 * ee.m" (lines 1-36). It contains the actual compiled code for that
 * M-function. It is a static function and must only be called from one of the
 * interface functions, appearing below.
 */
/*
 * function x = restorefree(inx,savefree,freevars)
 */
static mxArray * Mrestorefree(int nargout_,
                              mxArray * inx,
                              mxArray * savefree,
                              mxArray * freevars) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_restorefree);
    mxArray * x = mclGetUninitializedArray();
    mxArray * k = mclGetUninitializedArray();
    mxArray * j = mclGetUninitializedArray();
    mxArray * i = mclGetUninitializedArray();
    mxArray * nvars = mclGetUninitializedArray();
    mxArray * nfree = mclGetUninitializedArray();
    mclCopyArray(&inx);
    mclCopyArray(&savefree);
    mclCopyArray(&freevars);
    /*
     * 
     * % 
     * 
     * % Restore the free variables by back substitution
     * 
     * %
     * 
     * % function x = restorefree(inx,savefree,freevars)
     * 
     * % 
     * 
     * % inx = linear programming solution (without free variables)
     * 
     * % savefree = information from tableau for substitution
     * 
     * % freevars = list of free variables
     * 
     * % 
     * 
     * % x = linear programming solution (including free variables)
     * 
     * 
     * 
     * % Copyright 1999 by Todd K. Moon
     * 
     * 
     * 
     * x = inx;
     */
    mlfAssign(&x, mclVsa(inx, "inx"));
    /*
     * 
     * [nfree,nvars] = size(savefree);
     */
    mlfSize(
      mlfVarargout(&nfree, &nvars, NULL), mclVa(savefree, "savefree"), NULL);
    /*
     * 
     * nvars = nvars-1;
     */
    mlfAssign(&nvars, mclMinus(mclVv(nvars, "nvars"), _mxarray4_));
    /*
     * 
     * 
     * 
     * for i=1:nvars
     */
    {
        int v_ = mclForIntStart(1);
        int e_ = mclForIntEnd(mclVv(nvars, "nvars"));
        if (v_ > e_) {
            mlfAssign(&i, _mxarray5_);
        } else {
            /*
             * 
             * if(freevars(i))
             * 
             * x = [x(1:i-1) 0 x(i:end)];
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
                      &x,
                      mlfHorzcat(
                        mclVe(
                          mclArrayRef1(
                            mclVsv(x, "x"),
                            mlfColon(_mxarray4_, mlfScalar(v_ - 1), NULL))),
                        _mxarray6_,
                        mclVe(
                          mclArrayRef1(
                            mclVsv(x, "x"),
                            mlfColon(
                              mlfScalar(v_),
                              mlfEnd(mclVv(x, "x"), _mxarray4_, _mxarray4_),
                              NULL))),
                        NULL));
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
     * % back substitute
     * 
     * j = nfree;
     */
    mlfAssign(&j, mclVsv(nfree, "nfree"));
    /*
     * 
     * for i=nvars:-1:1
     */
    {
        mclForLoopIterator viter__;
        for (mclForStart(
               &viter__, mclVv(nvars, "nvars"), _mxarray7_, _mxarray4_);
             mclForNext(&viter__, &i);
             ) {
            /*
             * 
             * if(freevars(i))
             */
            if (mlfTobool(
                  mclVe(
                    mclArrayRef1(
                      mclVsa(freevars, "freevars"), mclVsv(i, "i"))))) {
                /*
                 * 
                 * x(i) = savefree(j,end);
                 */
                mclArrayAssign1(
                  &x,
                  mclArrayRef2(
                    mclVsa(savefree, "savefree"),
                    mclVsv(j, "j"),
                    mlfEnd(
                      mclVa(savefree, "savefree"), _mxarray8_, _mxarray8_)),
                  mclVsv(i, "i"));
                /*
                 * 
                 * for k=1:nvars
                 */
                {
                    int v_ = mclForIntStart(1);
                    int e_ = mclForIntEnd(mclVv(nvars, "nvars"));
                    if (v_ > e_) {
                        mlfAssign(&k, _mxarray5_);
                    } else {
                        /*
                         * 
                         * if(k ~= i)
                         * 
                         * x(i) = x(i) - x(k)*savefree(j,k);
                         * 
                         * end
                         * 
                         * end
                         */
                        for (; ; ) {
                            if (mclNeBool(mlfScalar(v_), mclVv(i, "i"))) {
                                mclArrayAssign1(
                                  &x,
                                  mclMinus(
                                    mclVe(
                                      mclArrayRef1(
                                        mclVsv(x, "x"), mclVsv(i, "i"))),
                                    mclMtimes(
                                      mclVe(
                                        mclIntArrayRef1(mclVsv(x, "x"), v_)),
                                      mclVe(
                                        mclArrayRef2(
                                          mclVsa(savefree, "savefree"),
                                          mclVsv(j, "j"),
                                          mlfScalar(v_))))),
                                  mclVsv(i, "i"));
                            }
                            if (v_ == e_) {
                                break;
                            }
                            ++v_;
                        }
                        mlfAssign(&k, mlfScalar(v_));
                    }
                }
                /*
                 * 
                 * j = j-1;
                 */
                mlfAssign(&j, mclMinus(mclVv(j, "j"), _mxarray4_));
            /*
             * 
             * end
             */
            }
        /*
         * 
         * end
         */
        }
        mclDestroyForLoopIterator(viter__);
    }
    mclValidateOutput(x, 1, nargout_, "x", "restorefree");
    mxDestroyArray(nfree);
    mxDestroyArray(nvars);
    mxDestroyArray(i);
    mxDestroyArray(j);
    mxDestroyArray(k);
    mxDestroyArray(freevars);
    mxDestroyArray(savefree);
    mxDestroyArray(inx);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return x;
}
