/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "etime.h"
#include "datenummx_mex_interface.h"
#include "libmatlbm.h"

static mxChar _array1_[128] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'e', 't', 'i', 'm', 'e',
                                ' ', 'L', 'i', 'n', 'e', ':', ' ', '1', ' ',
                                'C', 'o', 'l', 'u', 'm', 'n', ':', ' ', '1',
                                ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n', 'c',
                                't', 'i', 'o', 'n', ' ', '"', 'e', 't', 'i',
                                'm', 'e', '"', ' ', 'w', 'a', 's', ' ', 'c',
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
                                'l', 'e', ':', ' ', 'e', 't', 'i', 'm', 'e',
                                ' ', 'L', 'i', 'n', 'e', ':', ' ', '1', ' ',
                                'C', 'o', 'l', 'u', 'm', 'n', ':', ' ', '1',
                                ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n', 'c',
                                't', 'i', 'o', 'n', ' ', '"', 'e', 't', 'i',
                                'm', 'e', '"', ' ', 'w', 'a', 's', ' ', 'c',
                                'a', 'l', 'l', 'e', 'd', ' ', 'w', 'i', 't',
                                'h', ' ', 'm', 'o', 'r', 'e', ' ', 't', 'h',
                                'a', 'n', ' ', 't', 'h', 'e', ' ', 'd', 'e',
                                'c', 'l', 'a', 'r', 'e', 'd', ' ', 'n', 'u',
                                'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'i',
                                'n', 'p', 'u', 't', 's', ' ', '(', '2', ')',
                                '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;
static mxArray * _mxarray5_;
static mxArray * _mxarray6_;
static mxArray * _mxarray7_;
static mxArray * _mxarray8_;

static double _array10_[3] = { 3600.0, 60.0, 1.0 };
static mxArray * _mxarray9_;

void InitializeModule_etime(void) {
    _mxarray0_ = mclInitializeString(128, _array1_);
    _mxarray2_ = mclInitializeString(127, _array3_);
    _mxarray4_ = mclInitializeDouble(86400.0);
    _mxarray5_ = mclInitializeDouble(1.0);
    _mxarray6_ = mclInitializeDouble(3.0);
    _mxarray7_ = mclInitializeDouble(4.0);
    _mxarray8_ = mclInitializeDouble(6.0);
    _mxarray9_ = mclInitializeDoubleVector(3, 1, _array10_);
}

void TerminateModule_etime(void) {
    mxDestroyArray(_mxarray9_);
    mxDestroyArray(_mxarray8_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray6_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Metime(int nargout_, mxArray * t1, mxArray * t0);

_mexLocalFunctionTable _local_function_table_etime
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfEtime" contains the normal interface for the "etime"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/etime.m" (lines 1-27). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfEtime(mxArray * t1, mxArray * t0) {
    int nargout = 1;
    mxArray * t = mclGetUninitializedArray();
    mlfEnterNewContext(0, 2, t1, t0);
    t = Metime(nargout, t1, t0);
    mlfRestorePreviousContext(0, 2, t1, t0);
    return mlfReturnValue(t);
}

/*
 * The function "mlxEtime" contains the feval interface for the "etime"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/etime.m" (lines 1-27). The feval function calls the
 * implementation version of etime through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxEtime(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
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
    mplhs[0] = Metime(nlhs, mprhs[0], mprhs[1]);
    mlfRestorePreviousContext(0, 2, mprhs[0], mprhs[1]);
    plhs[0] = mplhs[0];
}

/*
 * The function "Metime" is the implementation version of the "etime"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/etime.m" (lines 1-27). It contains the actual compiled code for
 * that M-function. It is a static function and must only be called from one of
 * the interface functions, appearing below.
 */
/*
 * function t = etime(t1,t0)
 */
static mxArray * Metime(int nargout_, mxArray * t1, mxArray * t0) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_etime);
    mxArray * t = mclGetUninitializedArray();
    mclCopyArray(&t1);
    mclCopyArray(&t0);
    /*
     * %ETIME  Elapsed time.
     * %   ETIME(T1,T0) returns the time in seconds that has elapsed between
     * %   vectors T1 and T0.  The two vectors must be six elements long, in
     * %   the format returned by CLOCK:
     * %
     * %       T = [Year Month Day Hour Minute Second]
     * %
     * %   Time differences over many orders of magnitude are computed accurately.
     * %   The result can be thousands of seconds if T1 and T0 differ in their
     * %   first five compoents, or small fractions of seconds if the first five
     * %   components are equal.
     * %
     * %     t0 = clock;
     * %     operation
     * %     etime(clock,t0)
     * %
     * %   See also TIC, TOC, CLOCK, CPUTIME, DATENUM.
     * 
     * %   Copyright 1984-2001 The MathWorks, Inc. 
     * %   $Revision: 5.8 $  $Date: 2001/04/15 12:03:24 $
     * 
     * % Compute time difference accurately to preserve fractions of seconds.
     * 
     * t = 86400*(datenummx(t1(:,1:3)) - datenummx(t0(:,1:3))) + ...
     */
    mlfAssign(
      &t,
      mclPlus(
        mclMtimes(
          _mxarray4_,
          mclMinus(
            mclVe(
              mlfNDatenummx(
                0,
                mclValueVarargout(),
                mclVe(
                  mclArrayRef2(
                    mclVsa(t1, "t1"),
                    mlfCreateColonIndex(),
                    mlfColon(_mxarray5_, _mxarray6_, NULL))),
                NULL)),
            mclVe(
              mlfNDatenummx(
                0,
                mclValueVarargout(),
                mclVe(
                  mclArrayRef2(
                    mclVsa(t0, "t0"),
                    mlfCreateColonIndex(),
                    mlfColon(_mxarray5_, _mxarray6_, NULL))),
                NULL)))),
        mclMtimes(
          mclMinus(
            mclVe(
              mclArrayRef2(
                mclVsa(t1, "t1"),
                mlfCreateColonIndex(),
                mlfColon(_mxarray7_, _mxarray8_, NULL))),
            mclVe(
              mclArrayRef2(
                mclVsa(t0, "t0"),
                mlfCreateColonIndex(),
                mlfColon(_mxarray7_, _mxarray8_, NULL)))),
          _mxarray9_)));
    mclValidateOutput(t, 1, nargout_, "t", "etime");
    mxDestroyArray(t0);
    mxDestroyArray(t1);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return t;
    /*
     * (t1(:,4:6) - t0(:,4:6))*[3600; 60; 1];
     */
}
