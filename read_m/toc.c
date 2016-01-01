/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "toc.h"
#include "etime.h"
#include "libmatlbm.h"

extern mxArray * TICTOC;

static mxChar _array1_[124] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 't', 'o', 'c', ' ', 'L',
                                'i', 'n', 'e', ':', ' ', '1', ' ', 'C', 'o',
                                'l', 'u', 'm', 'n', ':', ' ', '1', ' ', 'T',
                                'h', 'e', ' ', 'f', 'u', 'n', 'c', 't', 'i',
                                'o', 'n', ' ', '"', 't', 'o', 'c', '"', ' ',
                                'w', 'a', 's', ' ', 'c', 'a', 'l', 'l', 'e',
                                'd', ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o',
                                'r', 'e', ' ', 't', 'h', 'a', 'n', ' ', 't',
                                'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r',
                                'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r',
                                ' ', 'o', 'f', ' ', 'o', 'u', 't', 'p', 'u',
                                't', 's', ' ', '(', '1', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[123] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 't', 'o', 'c', ' ', 'L',
                                'i', 'n', 'e', ':', ' ', '1', ' ', 'C', 'o',
                                'l', 'u', 'm', 'n', ':', ' ', '1', ' ', 'T',
                                'h', 'e', ' ', 'f', 'u', 'n', 'c', 't', 'i',
                                'o', 'n', ' ', '"', 't', 'o', 'c', '"', ' ',
                                'w', 'a', 's', ' ', 'c', 'a', 'l', 'l', 'e',
                                'd', ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o',
                                'r', 'e', ' ', 't', 'h', 'a', 'n', ' ', 't',
                                'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r',
                                'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r',
                                ' ', 'o', 'f', ' ', 'i', 'n', 'p', 'u', 't',
                                's', ' ', '(', '0', ')', '.' };
static mxArray * _mxarray2_;

static mxChar _array5_[37] = { 'Y', 'o', 'u', ' ', 'm', 'u', 's', 't', ' ', 'c',
                               'a', 'l', 'l', ' ', 'T', 'I', 'C', ' ', 'b', 'e',
                               'f', 'o', 'r', 'e', ' ', 'c', 'a', 'l', 'l', 'i',
                               'n', 'g', ' ', 'T', 'O', 'C', '.' };
static mxArray * _mxarray4_;

void InitializeModule_toc(void) {
    _mxarray0_ = mclInitializeString(124, _array1_);
    _mxarray2_ = mclInitializeString(123, _array3_);
    _mxarray4_ = mclInitializeString(37, _array5_);
}

void TerminateModule_toc(void) {
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mtoc(int nargout_);

_mexLocalFunctionTable _local_function_table_toc
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfNToc" contains the nargout interface for the "toc"
 * M-function from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/toc.m" (lines 1-21). This interface is only produced if the
 * M-function uses the special variable "nargout". The nargout interface allows
 * the number of requested outputs to be specified via the nargout argument, as
 * opposed to the normal interface which dynamically calculates the number of
 * outputs based on the number of non-NULL inputs it receives. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
mxArray * mlfNToc(int nargout) {
    mxArray * t = mclGetUninitializedArray();
    mlfEnterNewContext(0, 0);
    t = Mtoc(nargout);
    mlfRestorePreviousContext(0, 0);
    return mlfReturnValue(t);
}

/*
 * The function "mlfToc" contains the normal interface for the "toc" M-function
 * from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/toc.m" (lines 1-21). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfToc(void) {
    int nargout = 1;
    mxArray * t = mclGetUninitializedArray();
    mlfEnterNewContext(0, 0);
    t = Mtoc(nargout);
    mlfRestorePreviousContext(0, 0);
    return mlfReturnValue(t);
}

/*
 * The function "mlfVToc" contains the void interface for the "toc" M-function
 * from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/toc.m" (lines 1-21). The void interface is only produced if the
 * M-function uses the special variable "nargout", and has at least one output.
 * The void interface function specifies zero output arguments to the
 * implementation version of the function, and in the event that the
 * implementation version still returns an output (which, in MATLAB, would be
 * assigned to the "ans" variable), it deallocates the output. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlfVToc(void) {
    mxArray * t = NULL;
    mlfEnterNewContext(0, 0);
    t = Mtoc(0);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(t);
}

/*
 * The function "mlxToc" contains the feval interface for the "toc" M-function
 * from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/toc.m" (lines 1-21). The feval function calls the
 * implementation version of toc through this function. This function processes
 * any input arguments and passes them to the implementation version of the
 * function, appearing above.
 */
void mlxToc(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 0) {
        mlfError(_mxarray2_);
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    mlfEnterNewContext(0, 0);
    mplhs[0] = Mtoc(nlhs);
    mlfRestorePreviousContext(0, 0);
    plhs[0] = mplhs[0];
}

/*
 * The function "Mtoc" is the implementation version of the "toc" M-function
 * from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/toc.m" (lines 1-21). It contains the actual compiled code for
 * that M-function. It is a static function and must only be called from one of
 * the interface functions, appearing below.
 */
/*
 * function t = toc
 */
static mxArray * Mtoc(int nargout_) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_toc);
    mxArray * t = mclGetUninitializedArray();
    mxArray * elapsed_time = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    /*
     * %TOC Read the stopwatch timer.
     * %   TOC, by itself, prints the elapsed time (in seconds) since TIC was used.
     * %   t = TOC; saves the elapsed time in t, instead of printing it out.
     * %
     * %   See also TIC, ETIME, CLOCK, CPUTIME.
     * 
     * %   Copyright 1984-2001 The MathWorks, Inc. 
     * %   $Revision: 5.10 $  $Date: 2001/04/15 12:03:25 $
     * 
     * % TOC uses ETIME and the value of CLOCK saved by TIC.
     * global TICTOC
     * if isempty(TICTOC)
     */
    if (mlfTobool(mclVe(mlfIsempty(mclVg(&TICTOC, "TICTOC"))))) {
        /*
         * error('You must call TIC before calling TOC.');
         */
        mlfError(_mxarray4_);
    /*
     * end
     */
    }
    /*
     * if nargout < 1
     */
    if (nargout_ < 1) {
        /*
         * elapsed_time = etime(clock,TICTOC)
         */
        mlfAssign(
          &elapsed_time, mlfEtime(mclVe(mlfClock()), mclVg(&TICTOC, "TICTOC")));
        mclPrintArray(mclVsv(elapsed_time, "elapsed_time"), "elapsed_time");
    /*
     * else
     */
    } else {
        /*
         * t = etime(clock,TICTOC);
         */
        mlfAssign(&t, mlfEtime(mclVe(mlfClock()), mclVg(&TICTOC, "TICTOC")));
    /*
     * end
     */
    }
    mclValidateOutput(t, 1, nargout_, "t", "toc");
    mxDestroyArray(ans);
    mxDestroyArray(elapsed_time);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return t;
}
