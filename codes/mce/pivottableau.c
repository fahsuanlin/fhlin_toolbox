/*
 * MATLAB Compiler: 2.2
 * Date: Sat Nov 30 14:13:31 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "simplex1" 
 */
#include "pivottableau.h"
#include "libmatlbm.h"
#include "realmax.h"

static mxChar _array1_[142] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'p', 'i', 'v', 'o', 't',
                                't', 'a', 'b', 'l', 'e', 'a', 'u', ' ', 'L',
                                'i', 'n', 'e', ':', ' ', '1', ' ', 'C', 'o',
                                'l', 'u', 'm', 'n', ':', ' ', '1', ' ', 'T',
                                'h', 'e', ' ', 'f', 'u', 'n', 'c', 't', 'i',
                                'o', 'n', ' ', '"', 'p', 'i', 'v', 'o', 't',
                                't', 'a', 'b', 'l', 'e', 'a', 'u', '"', ' ',
                                'w', 'a', 's', ' ', 'c', 'a', 'l', 'l', 'e',
                                'd', ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o',
                                'r', 'e', ' ', 't', 'h', 'a', 'n', ' ', 't',
                                'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r',
                                'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r',
                                ' ', 'o', 'f', ' ', 'o', 'u', 't', 'p', 'u',
                                't', 's', ' ', '(', '3', ')', '.' };
static mxArray * _mxarray0_;
static mxArray * _mxarray2_;
static mxArray * _mxarray3_;
static mxArray * _mxarray4_;

static mxChar _array6_[12] = { 'f', 'l', 'a', 'g', '_', 'd',
                               'i', 's', 'p', 'l', 'a', 'y' };
static mxArray * _mxarray5_;

static mxChar _array8_[19] = { 'u', 'n', 'k', 'n', 'o', 'w', 'n', ' ', 'o', 'p',
                               't', 'i', 'o', 'n', ' ', '[', '%', 's', ']' };
static mxArray * _mxarray7_;

static mxChar _array10_[8] = { 'e', 'r', 'r', 'o', 'r', '!', 0x005c, 'n' };
static mxArray * _mxarray9_;
static mxArray * _mxarray11_;
static mxArray * _mxarray12_;

static mxChar _array14_[18] = { 'u', 'n', 'b', 'o', 'u', 'n', 'd', 'e', 'd',
                                ' ', 's', 'o', 'l', 'u', 't', 'i', 'o', 'n' };
static mxArray * _mxarray13_;

static mxChar _array16_[35] = { 's', 'i', 'm', 'p', 'l', 'e', 'x', ' ', '[',
                                '%', 'd', ']', '.', '.', '.', 'r', '_', 'm',
                                'i', 'n', '=', '[', '%', 'e', ']', ' ', 'c',
                                'o', 's', 't', '=', '[', '%', 'e', ']' };
static mxArray * _mxarray15_;

static mxChar _array18_[12] = { ' ', 'd', 'i', 'f', 'f', '=', '[',
                                '%', 'e', ']', 0x005c, 'n' };
static mxArray * _mxarray17_;
static mxArray * _mxarray19_;

static mxChar _array21_[2] = { 0x005c, 'n' };
static mxArray * _mxarray20_;

void InitializeModule_pivottableau(void) {
    _mxarray0_ = mclInitializeString(142, _array1_);
    _mxarray2_ = mclInitializeDouble(1.0);
    _mxarray3_ = mclInitializeDoubleVector(0, 0, (double *)NULL);
    _mxarray4_ = mclInitializeDouble(2.0);
    _mxarray5_ = mclInitializeString(12, _array6_);
    _mxarray7_ = mclInitializeString(19, _array8_);
    _mxarray9_ = mclInitializeString(8, _array10_);
    _mxarray11_ = mclInitializeDouble(0.0);
    _mxarray12_ = mclInitializeDouble(-2.220446049250313e-16);
    _mxarray13_ = mclInitializeString(18, _array14_);
    _mxarray15_ = mclInitializeString(35, _array16_);
    _mxarray17_ = mclInitializeString(12, _array18_);
    _mxarray19_ = mclInitializeDouble(1e-05);
    _mxarray20_ = mclInitializeString(2, _array21_);
}

void TerminateModule_pivottableau(void) {
    mxDestroyArray(_mxarray20_);
    mxDestroyArray(_mxarray19_);
    mxDestroyArray(_mxarray17_);
    mxDestroyArray(_mxarray15_);
    mxDestroyArray(_mxarray13_);
    mxDestroyArray(_mxarray12_);
    mxDestroyArray(_mxarray11_);
    mxDestroyArray(_mxarray9_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray3_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mpivottableau(mxArray * * basicptr,
                               mxArray * * cost,
                               int nargout_,
                               mxArray * intableau,
                               mxArray * inbasicptr,
                               mxArray * varargin);

_mexLocalFunctionTable _local_function_table_pivottableau
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfPivottableau" contains the normal interface for the
 * "pivottableau" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/pivottabl
 * eau.m" (lines 1-86). This function processes any input arguments and passes
 * them to the implementation version of the function, appearing above.
 */
mxArray * mlfPivottableau(mxArray * * basicptr,
                          mxArray * * cost,
                          mxArray * intableau,
                          mxArray * inbasicptr,
                          ...) {
    mxArray * varargin = NULL;
    int nargout = 1;
    mxArray * tableau = mclGetUninitializedArray();
    mxArray * basicptr__ = mclGetUninitializedArray();
    mxArray * cost__ = mclGetUninitializedArray();
    mlfVarargin(&varargin, inbasicptr, 0);
    mlfEnterNewContext(2, -3, basicptr, cost, intableau, inbasicptr, varargin);
    if (basicptr != NULL) {
        ++nargout;
    }
    if (cost != NULL) {
        ++nargout;
    }
    tableau
      = Mpivottableau(
          &basicptr__, &cost__, nargout, intableau, inbasicptr, varargin);
    mlfRestorePreviousContext(2, 2, basicptr, cost, intableau, inbasicptr);
    mxDestroyArray(varargin);
    if (basicptr != NULL) {
        mclCopyOutputArg(basicptr, basicptr__);
    } else {
        mxDestroyArray(basicptr__);
    }
    if (cost != NULL) {
        mclCopyOutputArg(cost, cost__);
    } else {
        mxDestroyArray(cost__);
    }
    return mlfReturnValue(tableau);
}

/*
 * The function "mlxPivottableau" contains the feval interface for the
 * "pivottableau" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/pivottabl
 * eau.m" (lines 1-86). The feval function calls the implementation version of
 * pivottableau through this function. This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
void mlxPivottableau(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[3];
    mxArray * mplhs[3];
    int i;
    if (nlhs > 3) {
        mlfError(_mxarray0_);
    }
    for (i = 0; i < 3; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 2 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 2; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 2, mprhs[0], mprhs[1]);
    mprhs[2] = NULL;
    mlfAssign(&mprhs[2], mclCreateVararginCell(nrhs - 2, prhs + 2));
    mplhs[0]
      = Mpivottableau(
          &mplhs[1], &mplhs[2], nlhs, mprhs[0], mprhs[1], mprhs[2]);
    mlfRestorePreviousContext(0, 2, mprhs[0], mprhs[1]);
    plhs[0] = mplhs[0];
    for (i = 1; i < 3 && i < nlhs; ++i) {
        plhs[i] = mplhs[i];
    }
    for (; i < 3; ++i) {
        mxDestroyArray(mplhs[i]);
    }
    mxDestroyArray(mprhs[2]);
}

/*
 * The function "Mpivottableau" is the implementation version of the
 * "pivottableau" M-function from file
 * "/autofs/homes/meso_001/home/fhlin/matlab/toolbox/fhlin_toolbox/mce/pivottabl
 * eau.m" (lines 1-86). It contains the actual compiled code for that
 * M-function. It is a static function and must only be called from one of the
 * interface functions, appearing below.
 */
/*
 * function [tableau,basicptr,cost] = pivottableau(intableau,inbasicptr,varargin)
 */
static mxArray * Mpivottableau(mxArray * * basicptr,
                               mxArray * * cost,
                               int nargout_,
                               mxArray * intableau,
                               mxArray * inbasicptr,
                               mxArray * varargin) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_pivottableau);
    mxArray * tableau = mclGetUninitializedArray();
    mxArray * oldb = mclGetUninitializedArray();
    mxArray * r = mclGetUninitializedArray();
    mxArray * minratio = mclGetUninitializedArray();
    mxArray * p = mclGetUninitializedArray();
    mxArray * cont = mclGetUninitializedArray();
    mxArray * count = mclGetUninitializedArray();
    mxArray * q = mclGetUninitializedArray();
    mxArray * rmin = mclGetUninitializedArray();
    mxArray * m = mclGetUninitializedArray();
    mxArray * n = mclGetUninitializedArray();
    mxArray * np1 = mclGetUninitializedArray();
    mxArray * mp1 = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    mxArray * option_value = mclGetUninitializedArray();
    mxArray * option = mclGetUninitializedArray();
    mxArray * i = mclGetUninitializedArray();
    mxArray * flag_display = mclGetUninitializedArray();
    mclCopyArray(&intableau);
    mclCopyArray(&inbasicptr);
    mclCopyArray(&varargin);
    /*
     * 
     * % 
     * 
     * % Perform pivoting on an augmented tableau until 
     * 
     * % there are no negative entries on the last row
     * 
     * %
     * 
     * % function [tableau,basicptr] = pivottableau(intableau,inbasicptr)
     * 
     * %
     * 
     * % intableau = input tableau tableau,
     * 
     * % inbasicptr = a list of the basic variables, such as [1 3 4]
     * 
     * %
     * 
     * % tableau = pivoted tableau 
     * 
     * % basicptr = new list of basic variables
     * 
     * 
     * 
     * % Copyright 1999 by Todd K. Moon
     * 
     * 
     * 
     * 
     * 
     * flag_display=1;
     */
    mlfAssign(&flag_display, _mxarray2_);
    /*
     * 
     * cost=[];
     */
    mlfAssign(cost, _mxarray3_);
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
                      mclMtimes(mlfScalar(v_), _mxarray4_), _mxarray2_)));
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
                    if (mclSwitchCompare(v_0, _mxarray5_)) {
                        mlfAssign(
                          &flag_display, mclVsv(option_value, "option_value"));
                    } else {
                        mclAssignAns(
                          &ans,
                          mlfNFprintf(
                            0, _mxarray7_, mclVv(option, "option"), NULL));
                        mclAssignAns(&ans, mlfNFprintf(0, _mxarray9_, NULL));
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
     * tableau = intableau; basicptr = inbasicptr;
     */
    mlfAssign(&tableau, mclVsa(intableau, "intableau"));
    mlfAssign(basicptr, mclVsa(inbasicptr, "inbasicptr"));
    /*
     * 
     * [mp1,np1] = size(tableau);
     */
    mlfSize(mlfVarargout(&mp1, &np1, NULL), mclVv(tableau, "tableau"), NULL);
    /*
     * 
     * n = np1-1;  m = mp1-1;
     */
    mlfAssign(&n, mclMinus(mclVv(np1, "np1"), _mxarray2_));
    mlfAssign(&m, mclMinus(mclVv(mp1, "mp1"), _mxarray2_));
    /*
     * 
     * 
     * 
     * 
     * 
     * [rmin,q] = min(tableau(end,1:n));
     */
    mlfAssign(
      &rmin,
      mlfMin(
        &q,
        mclVe(
          mclArrayRef2(
            mclVsv(tableau, "tableau"),
            mlfEnd(mclVv(tableau, "tableau"), _mxarray2_, _mxarray4_),
            mlfColon(_mxarray2_, mclVv(n, "n"), NULL))),
        NULL,
        NULL));
    /*
     * 
     * count=0;
     */
    mlfAssign(&count, _mxarray11_);
    /*
     * 
     * cont=1;
     */
    mlfAssign(&cont, _mxarray2_);
    /*
     * 
     * while((rmin < -eps)&cont)
     */
    for (;;) {
        mxArray * a_ = mclInitialize(mclLt(mclVv(rmin, "rmin"), _mxarray12_));
        if (mlfTobool(a_) && mlfTobool(mclAnd(a_, mclVv(cont, "cont")))) {
            mxDestroyArray(a_);
        } else {
            mxDestroyArray(a_);
            break;
        }
        /*
         * 
         * p = 0;
         */
        mlfAssign(&p, _mxarray11_);
        /*
         * 
         * minratio = realmax;
         */
        mlfAssign(&minratio, mlfRealmax());
        /*
         * 
         * for i=1:m
         */
        {
            int v_ = mclForIntStart(1);
            int e_ = mclForIntEnd(mclVv(m, "m"));
            if (v_ > e_) {
                mlfAssign(&i, _mxarray3_);
            } else {
                /*
                 * 
                 * if(tableau(i,q) > 0)
                 * 
                 * r = tableau(i,np1)/tableau(i,q);
                 * 
                 * if(r < minratio)
                 * 
                 * minratio = r;
                 * 
                 * p = i;
                 * 
                 * end
                 * 
                 * end
                 * 
                 * end
                 */
                for (; ; ) {
                    if (mclGtBool(
                          mclVe(
                            mclArrayRef2(
                              mclVsv(tableau, "tableau"),
                              mlfScalar(v_),
                              mclVsv(q, "q"))),
                          _mxarray11_)) {
                        mlfAssign(
                          &r,
                          mclMrdivide(
                            mclVe(
                              mclArrayRef2(
                                mclVsv(tableau, "tableau"),
                                mlfScalar(v_),
                                mclVsv(np1, "np1"))),
                            mclVe(
                              mclArrayRef2(
                                mclVsv(tableau, "tableau"),
                                mlfScalar(v_),
                                mclVsv(q, "q")))));
                        if (mclLtBool(
                              mclVv(r, "r"), mclVv(minratio, "minratio"))) {
                            mlfAssign(&minratio, mclVsv(r, "r"));
                            mlfAssign(&p, mlfScalar(v_));
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
         * if(p == 0)
         */
        if (mclEqBool(mclVv(p, "p"), _mxarray11_)) {
            /*
             * 
             * error('unbounded solution');
             */
            mlfError(_mxarray13_);
        /*
         * 
         * end
         */
        }
        /*
         * 
         * % update which are the basic variables in the list
         * 
         * oldb = basicptr(p); basicptr(p) = q;
         */
        mlfAssign(
          &oldb, mclArrayRef1(mclVsv(*basicptr, "basicptr"), mclVsv(p, "p")));
        mclArrayAssign1(basicptr, mclVsv(q, "q"), mclVsv(p, "p"));
        /*
         * 
         * % perform the pivot
         * 
         * tableau(p,:) = tableau(p,:) / tableau(p,q);
         */
        mclArrayAssign2(
          &tableau,
          mclMrdivide(
            mclVe(
              mclArrayRef2(
                mclVsv(tableau, "tableau"),
                mclVsv(p, "p"),
                mlfCreateColonIndex())),
            mclVe(
              mclArrayRef2(
                mclVsv(tableau, "tableau"), mclVsv(p, "p"), mclVsv(q, "q")))),
          mclVsv(p, "p"),
          mlfCreateColonIndex());
        /*
         * 
         * for i=1:mp1
         */
        {
            int v_ = mclForIntStart(1);
            int e_ = mclForIntEnd(mclVv(mp1, "mp1"));
            if (v_ > e_) {
                mlfAssign(&i, _mxarray3_);
            } else {
                /*
                 * 
                 * if(i ~= p)
                 * 
                 * tableau(i,:) = tableau(i,:) - tableau(p,:) .* tableau(i,q);
                 * 
                 * end
                 * 
                 * end
                 */
                for (; ; ) {
                    if (mclNeBool(mlfScalar(v_), mclVv(p, "p"))) {
                        mclArrayAssign2(
                          &tableau,
                          mclMinus(
                            mclVe(
                              mclArrayRef2(
                                mclVsv(tableau, "tableau"),
                                mlfScalar(v_),
                                mlfCreateColonIndex())),
                            mclTimes(
                              mclVe(
                                mclArrayRef2(
                                  mclVsv(tableau, "tableau"),
                                  mclVsv(p, "p"),
                                  mlfCreateColonIndex())),
                              mclVe(
                                mclArrayRef2(
                                  mclVsv(tableau, "tableau"),
                                  mlfScalar(v_),
                                  mclVsv(q, "q"))))),
                          mlfScalar(v_),
                          mlfCreateColonIndex());
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
         * [rmin,q] = min(tableau(end,1:n));
         */
        mlfAssign(
          &rmin,
          mlfMin(
            &q,
            mclVe(
              mclArrayRef2(
                mclVsv(tableau, "tableau"),
                mlfEnd(mclVv(tableau, "tableau"), _mxarray2_, _mxarray4_),
                mlfColon(_mxarray2_, mclVv(n, "n"), NULL))),
            NULL,
            NULL));
        /*
         * 
         * 
         * 
         * if(flag_display)
         */
        if (mlfTobool(mclVv(flag_display, "flag_display"))) {
            /*
             * 
             * fprintf('simplex [%d]...r_min=[%e] cost=[%e]',count,rmin,tableau(end,end));
             */
            mclAssignAns(
              &ans,
              mlfNFprintf(
                0,
                _mxarray15_,
                mclVv(count, "count"),
                mclVv(rmin, "rmin"),
                mclVe(
                  mclArrayRef2(
                    mclVsv(tableau, "tableau"),
                    mlfEnd(mclVv(tableau, "tableau"), _mxarray2_, _mxarray4_),
                    mlfEnd(mclVv(tableau, "tableau"), _mxarray4_, _mxarray4_))),
                NULL));
        /*
         * 
         * end;
         */
        }
        /*
         * 
         * 
         * 
         * count=count+1;
         */
        mlfAssign(&count, mclPlus(mclVv(count, "count"), _mxarray2_));
        /*
         * 
         * cost(count)=tableau(end,end);
         */
        mclArrayAssign1(
          cost,
          mclArrayRef2(
            mclVsv(tableau, "tableau"),
            mlfEnd(mclVv(tableau, "tableau"), _mxarray2_, _mxarray4_),
            mlfEnd(mclVv(tableau, "tableau"), _mxarray4_, _mxarray4_)),
          mclVsv(count, "count"));
        /*
         * 
         * plot([1:count],cost);
         */
        mclAssignAns(
          &ans,
          mlfNPlot(
            0,
            mlfColon(_mxarray2_, mclVv(count, "count"), NULL),
            mclVv(*cost, "cost"),
            NULL));
        /*
         * 
         * if(count>1) 
         */
        if (mclGtBool(mclVv(count, "count"), _mxarray2_)) {
            /*
             * 
             * if(flag_display)
             */
            if (mlfTobool(mclVv(flag_display, "flag_display"))) {
                /*
                 * 
                 * fprintf(' diff=[%e]\n',cost(count)-cost(count-1)); 
                 */
                mclAssignAns(
                  &ans,
                  mlfNFprintf(
                    0,
                    _mxarray17_,
                    mclMinus(
                      mclVe(
                        mclArrayRef1(
                          mclVsv(*cost, "cost"), mclVsv(count, "count"))),
                      mclVe(
                        mclArrayRef1(
                          mclVsv(*cost, "cost"),
                          mclMinus(mclVv(count, "count"), _mxarray2_)))),
                    NULL));
            /*
             * 
             * end;
             */
            }
            /*
             * 
             * if(cost(count)-cost(count-1)<1e-5) cont=0;  end; 
             */
            if (mclLtBool(
                  mclMinus(
                    mclVe(
                      mclArrayRef1(
                        mclVsv(*cost, "cost"), mclVsv(count, "count"))),
                    mclVe(
                      mclArrayRef1(
                        mclVsv(*cost, "cost"),
                        mclMinus(mclVv(count, "count"), _mxarray2_)))),
                  _mxarray19_)) {
                mlfAssign(&cont, _mxarray11_);
            }
        /*
         * 
         * else
         */
        } else {
            /*
             * 
             * if(flag_display)
             */
            if (mlfTobool(mclVv(flag_display, "flag_display"))) {
                /*
                 * 
                 * fprintf('\n');
                 */
                mclAssignAns(&ans, mlfNFprintf(0, _mxarray20_, NULL));
            /*
             * 
             * end;
             */
            }
        /*
         * 
         * end;
         */
        }
    /*
     * 
     * 
     * 
     * end
     */
    }
    return_:
    mclValidateOutput(tableau, 1, nargout_, "tableau", "pivottableau");
    mclValidateOutput(*basicptr, 2, nargout_, "basicptr", "pivottableau");
    mclValidateOutput(*cost, 3, nargout_, "cost", "pivottableau");
    mxDestroyArray(flag_display);
    mxDestroyArray(i);
    mxDestroyArray(option);
    mxDestroyArray(option_value);
    mxDestroyArray(ans);
    mxDestroyArray(mp1);
    mxDestroyArray(np1);
    mxDestroyArray(n);
    mxDestroyArray(m);
    mxDestroyArray(rmin);
    mxDestroyArray(q);
    mxDestroyArray(count);
    mxDestroyArray(cont);
    mxDestroyArray(p);
    mxDestroyArray(minratio);
    mxDestroyArray(r);
    mxDestroyArray(oldb);
    mxDestroyArray(varargin);
    mxDestroyArray(inbasicptr);
    mxDestroyArray(intableau);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return tableau;
    /*
     * 
     */
}
