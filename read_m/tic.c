/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "tic.h"
#include "libmatlbm.h"

extern mxArray * TICTOC;

static mxChar _array1_[124] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 't', 'i', 'c', ' ', 'L',
                                'i', 'n', 'e', ':', ' ', '1', ' ', 'C', 'o',
                                'l', 'u', 'm', 'n', ':', ' ', '1', ' ', 'T',
                                'h', 'e', ' ', 'f', 'u', 'n', 'c', 't', 'i',
                                'o', 'n', ' ', '"', 't', 'i', 'c', '"', ' ',
                                'w', 'a', 's', ' ', 'c', 'a', 'l', 'l', 'e',
                                'd', ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o',
                                'r', 'e', ' ', 't', 'h', 'a', 'n', ' ', 't',
                                'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r',
                                'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r',
                                ' ', 'o', 'f', ' ', 'o', 'u', 't', 'p', 'u',
                                't', 's', ' ', '(', '0', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[123] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 't', 'i', 'c', ' ', 'L',
                                'i', 'n', 'e', ':', ' ', '1', ' ', 'C', 'o',
                                'l', 'u', 'm', 'n', ':', ' ', '1', ' ', 'T',
                                'h', 'e', ' ', 'f', 'u', 'n', 'c', 't', 'i',
                                'o', 'n', ' ', '"', 't', 'i', 'c', '"', ' ',
                                'w', 'a', 's', ' ', 'c', 'a', 'l', 'l', 'e',
                                'd', ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o',
                                'r', 'e', ' ', 't', 'h', 'a', 'n', ' ', 't',
                                'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r',
                                'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r',
                                ' ', 'o', 'f', ' ', 'i', 'n', 'p', 'u', 't',
                                's', ' ', '(', '0', ')', '.' };
static mxArray * _mxarray2_;

void InitializeModule_tic(void) {
    _mxarray0_ = mclInitializeString(124, _array1_);
    _mxarray2_ = mclInitializeString(123, _array3_);
}

void TerminateModule_tic(void) {
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static void Mtic(void);

_mexLocalFunctionTable _local_function_table_tic
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfTic" contains the normal interface for the "tic" M-function
 * from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/tic.m" (lines 1-15). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
void mlfTic(void) {
    mlfEnterNewContext(0, 0);
    Mtic();
    mlfRestorePreviousContext(0, 0);
}

/*
 * The function "mlxTic" contains the feval interface for the "tic" M-function
 * from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/tic.m" (lines 1-15). The feval function calls the
 * implementation version of tic through this function. This function processes
 * any input arguments and passes them to the implementation version of the
 * function, appearing above.
 */
void mlxTic(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    if (nlhs > 0) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 0) {
        mlfError(_mxarray2_);
    }
    mlfEnterNewContext(0, 0);
    Mtic();
    mlfRestorePreviousContext(0, 0);
}

/*
 * The function "Mtic" is the implementation version of the "tic" M-function
 * from file
 * "/.automount/lyon/local_mount/space/lyon/9/pubsw/common/matlab/6.1/toolbox/ma
 * tlab/timefun/tic.m" (lines 1-15). It contains the actual compiled code for
 * that M-function. It is a static function and must only be called from one of
 * the interface functions, appearing below.
 */
/*
 * function tic
 */
static void Mtic(void) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_tic);
    mxArray * ans = mclGetUninitializedArray();
    /*
     * %TIC Start a stopwatch timer.
     * %   The sequence of commands
     * %       TIC, operation, TOC
     * %   prints the number of seconds required for the operation.
     * %
     * %   See also TOC, CLOCK, ETIME, CPUTIME.
     * 
     * %   Copyright 1984-2001 The MathWorks, Inc. 
     * %   $Revision: 5.9 $  $Date: 2001/04/15 12:03:24 $
     * 
     * % TIC simply stores CLOCK in a global variable.
     * global TICTOC
     * TICTOC = clock;
     */
    mlfAssign(mclPrepareGlobal(&TICTOC), mlfClock());
    mxDestroyArray(ans);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
}
