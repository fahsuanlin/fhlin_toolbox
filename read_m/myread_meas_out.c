/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "myread_meas_out.h"
#include "angle.h"
#include "fftshift.h"
#include "fliplr.h"
#include "libmatlbm.h"
#include "read_mdh_adc.h"
#include "tic.h"
#include "toc.h"

static mxChar _array1_[148] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'm', 'y', 'r', 'e', 'a',
                                'd', '_', 'm', 'e', 'a', 's', '_', 'o', 'u',
                                't', ' ', 'L', 'i', 'n', 'e', ':', ' ', '1',
                                ' ', 'C', 'o', 'l', 'u', 'm', 'n', ':', ' ',
                                '1', ' ', 'T', 'h', 'e', ' ', 'f', 'u', 'n',
                                'c', 't', 'i', 'o', 'n', ' ', '"', 'm', 'y',
                                'r', 'e', 'a', 'd', '_', 'm', 'e', 'a', 's',
                                '_', 'o', 'u', 't', '"', ' ', 'w', 'a', 's',
                                ' ', 'c', 'a', 'l', 'l', 'e', 'd', ' ', 'w',
                                'i', 't', 'h', ' ', 'm', 'o', 'r', 'e', ' ',
                                't', 'h', 'a', 'n', ' ', 't', 'h', 'e', ' ',
                                'd', 'e', 'c', 'l', 'a', 'r', 'e', 'd', ' ',
                                'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f',
                                ' ', 'o', 'u', 't', 'p', 'u', 't', 's', ' ',
                                '(', '3', ')', '.' };
static mxArray * _mxarray0_;
static mxArray * _mxarray2_;
static mxArray * _mxarray3_;
static mxArray * _mxarray4_;
static mxArray * _mxarray5_;
static mxArray * _mxarray6_;

static mxChar _array8_[8] = { 'm', 'e', 'a', 's', '.', 'o', 'u', 't' };
static mxArray * _mxarray7_;

static mxChar _array10_[47] = { 'T', 'h', 'e', 'r', 'e', ' ', 'i', 's',
                                ' ', 'n', 'o', ' ', 'm', 'e', 'a', 's',
                                '.', 'o', 'u', 't', ' ', 'i', 'n', ' ',
                                't', 'h', 'e', ' ', 'c', 'u', 'r', 'r',
                                'e', 'n', 't', ' ', 'd', 'i', 'r', 'e',
                                'c', 't', 'o', 'r', 'y', 0x005c, 'n' };
static mxArray * _mxarray9_;

static mxChar _array12_[11] = { 'E', 'x', 'i', 't', 'i', 'n',
                                'g', ' ', '.', '.', '.' };
static mxArray * _mxarray11_;

static mxChar _array14_[1] = { 'r' };
static mxArray * _mxarray13_;

static mxChar _array16_[1] = { 'l' };
static mxArray * _mxarray15_;

static mxChar _array18_[4] = { 'l', 'o', 'n', 'g' };
static mxArray * _mxarray17_;

static mxChar _array20_[3] = { 'b', 'o', 'f' };
static mxArray * _mxarray19_;
static mxArray * _mxarray21_;

static mxChar _array23_[31] = { 'l', 'o', 'a', 'd', 'i', 'n', 'g', ' ',
                                '[', '%', 'd', ']', ' ', 'k', '-', 's',
                                'p', 'a', 'c', 'e', ' ', 'l', 'i', 'n',
                                'e', 's', '.', '.', '.', 0x005c, 'n' };
static mxArray * _mxarray22_;

static mxChar _array25_[21] = { '3', 'D', ' ', 's', 'e', 'q', 'u', 'e',
                                'n', 'c', 'e', ' ', 'd', 'a', 't', 'a',
                                '.', '.', '.', 0x005c, 'n' };
static mxArray * _mxarray24_;

static mxChar _array27_[21] = { '2', 'D', ' ', 's', 'e', 'q', 'u', 'e',
                                'n', 'c', 'e', ' ', 'd', 'a', 't', 'a',
                                '.', '.', '.', 0x005c, 'n' };
static mxArray * _mxarray26_;

static mxChar _array29_[23] = { 'T', 'o', 't', 'a', 'l', ' ', 'U', 's',
                                'e', 'd', ' ', 'c', 'h', 'a', 'n', 'n',
                                'e', 'l', '=', '%', 'd', 0x005c, 'n' };
static mxArray * _mxarray28_;
static mxArray * _mxarray30_;
static mxArray * _mxarray31_;
static mxArray * _mxarray32_;
static mxArray * _mxarray33_;
static mxArray * _mxarray34_;
static mxArray * _mxarray35_;

static mxChar _array37_[11] = { '%', 'd', '%', '%', ' ', 'd',
                                'o', 'n', 'e', 0x005c, 'n' };
static mxArray * _mxarray36_;

static mxChar _array39_[2] = { 0x005c, 'n' };
static mxArray * _mxarray38_;

static mxChar _array41_[51] = { 'F', 'F', 'T', ' ', 'a', 't', ' ', 't', 'h',
                                'e', ' ', 'p', 'a', 'r', 't', 'i', 't', 'i',
                                'o', 'n', ' ', 'd', 'i', 'm', 'e', 'n', 's',
                                'i', 'o', 'n', ' ', 'f', 'o', 'r', ' ', '3',
                                'D', ' ', 's', 'e', 'q', 'u', 'e', 'n', 'c',
                                'e', '.', '.', '.', 0x005c, 'n' };
static mxArray * _mxarray40_;

void InitializeModule_myread_meas_out(void) {
    _mxarray0_ = mclInitializeString(148, _array1_);
    _mxarray2_ = mclInitializeDouble(3.0);
    _mxarray3_ = mclInitializeDouble(1.0);
    _mxarray4_ = mclInitializeDouble(2.0);
    _mxarray5_ = mclInitializeDouble(0.0);
    _mxarray6_ = mclInitializeDoubleVector(0, 0, (double *)NULL);
    _mxarray7_ = mclInitializeString(8, _array8_);
    _mxarray9_ = mclInitializeString(47, _array10_);
    _mxarray11_ = mclInitializeString(11, _array12_);
    _mxarray13_ = mclInitializeString(1, _array14_);
    _mxarray15_ = mclInitializeString(1, _array16_);
    _mxarray17_ = mclInitializeString(4, _array18_);
    _mxarray19_ = mclInitializeString(3, _array20_);
    _mxarray21_ = mclInitializeDouble(100.0);
    _mxarray22_ = mclInitializeString(31, _array23_);
    _mxarray24_ = mclInitializeString(21, _array25_);
    _mxarray26_ = mclInitializeString(21, _array27_);
    _mxarray28_ = mclInitializeString(23, _array29_);
    _mxarray30_ = mclInitializeDouble(5.0);
    _mxarray31_ = mclInitializeDouble(22.0);
    _mxarray32_ = mclInitializeDouble(25.0);
    _mxarray33_ = mclInitializeDouble(.5);
    _mxarray34_ = mclInitializeDouble(6.0);
    _mxarray35_ = mclInitializeDouble(-1.0);
    _mxarray36_ = mclInitializeString(11, _array37_);
    _mxarray38_ = mclInitializeString(2, _array39_);
    _mxarray40_ = mclInitializeString(51, _array41_);
}

void TerminateModule_myread_meas_out(void) {
    mxDestroyArray(_mxarray40_);
    mxDestroyArray(_mxarray38_);
    mxDestroyArray(_mxarray36_);
    mxDestroyArray(_mxarray35_);
    mxDestroyArray(_mxarray34_);
    mxDestroyArray(_mxarray33_);
    mxDestroyArray(_mxarray32_);
    mxDestroyArray(_mxarray31_);
    mxDestroyArray(_mxarray30_);
    mxDestroyArray(_mxarray28_);
    mxDestroyArray(_mxarray26_);
    mxDestroyArray(_mxarray24_);
    mxDestroyArray(_mxarray22_);
    mxDestroyArray(_mxarray21_);
    mxDestroyArray(_mxarray19_);
    mxDestroyArray(_mxarray17_);
    mxDestroyArray(_mxarray15_);
    mxDestroyArray(_mxarray13_);
    mxDestroyArray(_mxarray11_);
    mxDestroyArray(_mxarray9_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray6_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray3_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mmyread_meas_out(mxArray * * navs,
                                  mxArray * * kvol_orig,
                                  int nargout_,
                                  mxArray * varargin);

_mexLocalFunctionTable _local_function_table_myread_meas_out
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfMyread_meas_out" contains the normal interface for the
 * "myread_meas_out" M-function from file
 * "/.automount/space/local_mount/homes/nmrnew/home/fhlin/matlab/toolbox/fhlin_t
 * oolbox/read_m/myread_meas_out.m" (lines 1-260). This function processes any
 * input arguments and passes them to the implementation version of the
 * function, appearing above.
 */
mxArray * mlfMyread_meas_out(mxArray * * navs, mxArray * * kvol_orig, ...) {
    mxArray * varargin = NULL;
    int nargout = 1;
    mxArray * kvol = mclGetUninitializedArray();
    mxArray * navs__ = mclGetUninitializedArray();
    mxArray * kvol_orig__ = mclGetUninitializedArray();
    mlfVarargin(&varargin, kvol_orig, 0);
    mlfEnterNewContext(2, -1, navs, kvol_orig, varargin);
    if (navs != NULL) {
        ++nargout;
    }
    if (kvol_orig != NULL) {
        ++nargout;
    }
    kvol = Mmyread_meas_out(&navs__, &kvol_orig__, nargout, varargin);
    mlfRestorePreviousContext(2, 0, navs, kvol_orig);
    mxDestroyArray(varargin);
    if (navs != NULL) {
        mclCopyOutputArg(navs, navs__);
    } else {
        mxDestroyArray(navs__);
    }
    if (kvol_orig != NULL) {
        mclCopyOutputArg(kvol_orig, kvol_orig__);
    } else {
        mxDestroyArray(kvol_orig__);
    }
    return mlfReturnValue(kvol);
}

/*
 * The function "mlxMyread_meas_out" contains the feval interface for the
 * "myread_meas_out" M-function from file
 * "/.automount/space/local_mount/homes/nmrnew/home/fhlin/matlab/toolbox/fhlin_t
 * oolbox/read_m/myread_meas_out.m" (lines 1-260). The feval function calls the
 * implementation version of myread_meas_out through this function. This
 * function processes any input arguments and passes them to the implementation
 * version of the function, appearing above.
 */
void mlxMyread_meas_out(int nlhs,
                        mxArray * plhs[],
                        int nrhs,
                        mxArray * prhs[]) {
    mxArray * mprhs[1];
    mxArray * mplhs[3];
    int i;
    if (nlhs > 3) {
        mlfError(_mxarray0_);
    }
    for (i = 0; i < 3; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    mlfEnterNewContext(0, 0);
    mprhs[0] = NULL;
    mlfAssign(&mprhs[0], mclCreateVararginCell(nrhs, prhs));
    mplhs[0] = Mmyread_meas_out(&mplhs[1], &mplhs[2], nlhs, mprhs[0]);
    mlfRestorePreviousContext(0, 0);
    plhs[0] = mplhs[0];
    for (i = 1; i < 3 && i < nlhs; ++i) {
        plhs[i] = mplhs[i];
    }
    for (; i < 3; ++i) {
        mxDestroyArray(mplhs[i]);
    }
    mxDestroyArray(mprhs[0]);
}

/*
 * The function "Mmyread_meas_out" is the implementation version of the
 * "myread_meas_out" M-function from file
 * "/.automount/space/local_mount/homes/nmrnew/home/fhlin/matlab/toolbox/fhlin_t
 * oolbox/read_m/myread_meas_out.m" (lines 1-260). It contains the actual
 * compiled code for that M-function. It is a static function and must only be
 * called from one of the interface functions, appearing below.
 */
/*
 * function [kvol, navs, kvol_orig] = myread_meas_out(varargin)
 */
static mxArray * Mmyread_meas_out(mxArray * * navs,
                                  mxArray * * kvol_orig,
                                  int nargout_,
                                  mxArray * varargin) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(
          &_local_function_table_myread_meas_out);
    int nargin_ = mclNargin(-1, varargin, NULL);
    mxArray * kvol = mclGetUninitializedArray();
    mxArray * flag_neg = mclGetUninitializedArray();
    mxArray * nav_even = mclGetUninitializedArray();
    mxArray * nav_odd = mclGetUninitializedArray();
    mxArray * corrvec = mclGetUninitializedArray();
    mxArray * ch = mclGetUninitializedArray();
    mxArray * navcounter = mclGetUninitializedArray();
    mxArray * counter = mclGetUninitializedArray();
    mxArray * PERC = mclGetUninitializedArray();
    mxArray * numADCs = mclGetUninitializedArray();
    mxArray * flag_3D = mclGetUninitializedArray();
    mxArray * ec = mclGetUninitializedArray();
    mxArray * tt = mclGetUninitializedArray();
    mxArray * ps = mclGetUninitializedArray();
    mxArray * rr = mclGetUninitializedArray();
    mxArray * mdh = mclGetUninitializedArray();
    mxArray * adc_data = mclGetUninitializedArray();
    mxArray * ccc = mclGetUninitializedArray();
    mxArray * partitionMax = mclGetUninitializedArray();
    mxArray * sliceMax = mclGetUninitializedArray();
    mxArray * CONT = mclGetUninitializedArray();
    mxArray * ecMax = mclGetUninitializedArray();
    mxArray * ttMax = mclGetUninitializedArray();
    mxArray * psMax = mclGetUninitializedArray();
    mxArray * rrMax = mclGetUninitializedArray();
    mxArray * ccMax = mclGetUninitializedArray();
    mxArray * meas_out_start_offset = mclGetUninitializedArray();
    mxArray * fid = mclGetUninitializedArray();
    mxArray * ans = mclGetUninitializedArray();
    mxArray * ff = mclGetUninitializedArray();
    mxArray * MEASOUT_FOUND = mclGetUninitializedArray();
    mxArray * files = mclGetUninitializedArray();
    mxArray * fname = mclGetUninitializedArray();
    mxArray * DISPLAY = mclGetUninitializedArray();
    mxArray * numNavs = mclGetUninitializedArray();
    mclCopyArray(&varargin);
    /*
     * % (Painfully slow) reader for "meas.out" files (Siemens Num4 raw data)
     * % [kvol, navs] = read_meas_out    (assumes "meas.out" in current dir)
     * % [kvol, navs] = read_meas_out('my_meas.out') 
     * %
     * % Note 1: the only navigators this handles are the standard ones used
     * % in the Siemens EPI sequences: i.e. for each slice, a navigator is
     * % acquired by reading the center k-space line 3 times, and the mdh
     * % head is marked with an MDH_PHASECOR.
     * %
     * % Dimensions:
     * % ---------
     * % 1 -- Column (in k-space)
     * % 2 -- Phase encode line (row in k-space)
     * % 3 -- Partition (slice in 3-D k-space) or Slice
     * % 4 -- Repetition (i.e. the only change is time)
     * % 5 -- Echo 
     * 
     * % (MukundB, Tue Dec 18, 2001)
     * 
     * %more off
     * 
     * numNavs = 3;
     */
    mlfAssign(&numNavs, _mxarray2_);
    /*
     * 
     * DISPLAY = 1;
     */
    mlfAssign(&DISPLAY, _mxarray3_);
    /*
     * if nargin >=2
     */
    if (nargin_ >= 2) {
        /*
         * DISPLAY = varargin{2};
         */
        mlfAssign(
          &DISPLAY,
          mlfIndexRef(mclVsa(varargin, "varargin"), "{?}", _mxarray4_));
    /*
     * end
     */
    }
    /*
     * 
     * if nargin >= 1
     */
    if (nargin_ >= 1) {
        /*
         * fname = varargin{1};
         */
        mlfAssign(
          &fname, mlfIndexRef(mclVsa(varargin, "varargin"), "{?}", _mxarray3_));
    /*
     * else
     */
    } else {
        /*
         * files = dir;
         */
        mlfAssign(&files, mlfNDir(1, NULL));
        /*
         * MEASOUT_FOUND = 0;
         */
        mlfAssign(&MEASOUT_FOUND, _mxarray5_);
        /*
         * for ff = 1:length(files)
         */
        {
            int v_ = mclForIntStart(1);
            int e_
              = mclForIntEnd(mlfScalar(mclLengthInt(mclVv(files, "files"))));
            if (v_ > e_) {
                mlfAssign(&ff, _mxarray6_);
            } else {
                /*
                 * if strcmp(files(ff).name, 'meas.out')
                 * MEASOUT_FOUND = 1;
                 * end
                 * end
                 */
                for (; ; ) {
                    if (mlfTobool(
                          mclVe(
                            mclFeval(
                              mclValueVarargout(),
                              mlxStrcmp,
                              mclVe(
                                mlfIndexRef(
                                  mclVsv(files, "files"),
                                  "(?).name",
                                  mlfScalar(v_))),
                              _mxarray7_,
                              NULL)))) {
                        mlfAssign(&MEASOUT_FOUND, _mxarray3_);
                    }
                    if (v_ == e_) {
                        break;
                    }
                    ++v_;
                }
                mlfAssign(&ff, mlfScalar(v_));
            }
        }
        /*
         * if MEASOUT_FOUND == 0
         */
        if (mclEqBool(mclVv(MEASOUT_FOUND, "MEASOUT_FOUND"), _mxarray5_)) {
            /*
             * fprintf('There is no meas.out in the current directory\n');
             */
            mclAssignAns(&ans, mlfNFprintf(0, _mxarray9_, NULL));
            /*
             * error('Exiting ...');
             */
            mlfError(_mxarray11_);
        /*
         * end
         */
        }
        /*
         * fname = 'meas.out';
         */
        mlfAssign(&fname, _mxarray7_);
    /*
     * end
     */
    }
    /*
     * 
     * fid = fopen(fname, 'r', 'l');
     */
    mlfAssign(
      &fid,
      mlfFopen(NULL, NULL, mclVv(fname, "fname"), _mxarray13_, _mxarray15_));
    /*
     * 
     * % data starts 32 bytes from the file beginning for pineapple
     * meas_out_start_offset = fread(fid, 1, 'long'); 
     */
    mlfAssign(
      &meas_out_start_offset,
      mlfFread(NULL, mclVv(fid, "fid"), _mxarray3_, _mxarray17_, NULL));
    /*
     * fseek(fid, meas_out_start_offset, 'bof'); 
     */
    mclAssignAns(
      &ans,
      mlfFseek(
        mclVv(fid, "fid"),
        mclVv(meas_out_start_offset, "meas_out_start_offset"),
        _mxarray19_));
    /*
     * 
     * % Initialize for loop 1
     * ccMax = 1;
     */
    mlfAssign(&ccMax, _mxarray3_);
    /*
     * rrMax = 1;
     */
    mlfAssign(&rrMax, _mxarray3_);
    /*
     * psMax = 1;
     */
    mlfAssign(&psMax, _mxarray3_);
    /*
     * ttMax = 1;
     */
    mlfAssign(&ttMax, _mxarray3_);
    /*
     * ecMax = 1;
     */
    mlfAssign(&ecMax, _mxarray3_);
    /*
     * CONT = 1;
     */
    mlfAssign(&CONT, _mxarray3_);
    /*
     * 
     * sliceMax=0;
     */
    mlfAssign(&sliceMax, _mxarray5_);
    /*
     * partitionMax=0;
     */
    mlfAssign(&partitionMax, _mxarray5_);
    /*
     * 
     * % Start loop 1
     * if DISPLAY
     */
    if (mlfTobool(mclVv(DISPLAY, "DISPLAY"))) {
        /*
         * tic
         */
        mlfTic();
    /*
     * end
     */
    }
    /*
     * 
     * ccc=1;
     */
    mlfAssign(&ccc, _mxarray3_);
    /*
     * 
     * %fp=fopen('raw.txt','w');
     * 
     * while CONT == 1
     */
    while (mclEqBool(mclVv(CONT, "CONT"), _mxarray3_)) {
        /*
         * if(mod(ccc,100)==0)
         */
        if (mclEqBool(
              mclVe(mlfMod(mclVv(ccc, "ccc"), _mxarray21_)), _mxarray5_)) {
            /*
             * fprintf('loading [%d] k-space lines...\n',ccc);
             */
            mclAssignAns(
              &ans, mlfNFprintf(0, _mxarray22_, mclVv(ccc, "ccc"), NULL));
        /*
         * end;
         */
        }
        /*
         * 
         * [adc_data, mdh] = read_mdh_adc(fid);
         */
        mlfAssign(&adc_data, mlfRead_mdh_adc(&mdh, mclVv(fid, "fid")));
        /*
         * 
         * if (mdh.EvalInfoMask(1)) % i.e. MDH_ACQEND
         */
        if (mlfTobool(
              mclVe(
                mlfIndexRef(
                  mclVsv(mdh, "mdh"), ".EvalInfoMask(?)", _mxarray3_)))) {
            /*
             * 
             * CONT = 0;
             */
            mlfAssign(&CONT, _mxarray5_);
        /*
         * 
         * else
         */
        } else {
            /*
             * 
             * ccMax = mdh.SamplesInScan;
             */
            mlfAssign(
              &ccMax, mlfIndexRef(mclVsv(mdh, "mdh"), ".SamplesInScan"));
            /*
             * 
             * rr = mdh.LoopCounter.Line + 1;
             */
            mlfAssign(
              &rr,
              mclFeval(
                mclValueVarargout(),
                mlxPlus,
                mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Line")),
                _mxarray3_,
                NULL));
            /*
             * ps = max(mdh.LoopCounter.Partition + 1, ...
             */
            mlfAssign(
              &ps,
              mlfMax(
                NULL,
                mclFeval(
                  mclValueVarargout(),
                  mlxPlus,
                  mclVe(
                    mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Partition")),
                  _mxarray3_,
                  NULL),
                mclFeval(
                  mclValueVarargout(),
                  mlxPlus,
                  mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Slice")),
                  _mxarray3_,
                  NULL),
                NULL));
            /*
             * mdh.LoopCounter.Slice + 1);
             * tt = mdh.LoopCounter.Repetition + 1;
             */
            mlfAssign(
              &tt,
              mclFeval(
                mclValueVarargout(),
                mlxPlus,
                mclVe(
                  mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Repetition")),
                _mxarray3_,
                NULL));
            /*
             * ec = mdh.LoopCounter.Echo + 1;
             */
            mlfAssign(
              &ec,
              mclFeval(
                mclValueVarargout(),
                mlxPlus,
                mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Echo")),
                _mxarray3_,
                NULL));
            /*
             * 
             * if (mdh.LoopCounter.Partition+1>partitionMax)
             */
            if (mclGtBool(
                  mclFeval(
                    mclValueVarargout(),
                    mlxPlus,
                    mclVe(
                      mlfIndexRef(
                        mclVsv(mdh, "mdh"), ".LoopCounter.Partition")),
                    _mxarray3_,
                    NULL),
                  mclVv(partitionMax, "partitionMax"))) {
                /*
                 * partitionMax=mdh.LoopCounter.Partition+1;
                 */
                mlfAssign(
                  &partitionMax,
                  mclFeval(
                    mclValueVarargout(),
                    mlxPlus,
                    mclVe(
                      mlfIndexRef(
                        mclVsv(mdh, "mdh"), ".LoopCounter.Partition")),
                    _mxarray3_,
                    NULL));
            /*
             * end;
             */
            }
            /*
             * if (mdh.LoopCounter.Slice+1>sliceMax)
             */
            if (mclGtBool(
                  mclFeval(
                    mclValueVarargout(),
                    mlxPlus,
                    mclVe(
                      mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Slice")),
                    _mxarray3_,
                    NULL),
                  mclVv(sliceMax, "sliceMax"))) {
                /*
                 * sliceMax=mdh.LoopCounter.Slice+1;
                 */
                mlfAssign(
                  &sliceMax,
                  mclFeval(
                    mclValueVarargout(),
                    mlxPlus,
                    mclVe(
                      mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Slice")),
                    _mxarray3_,
                    NULL));
            /*
             * end;
             */
            }
            /*
             * 
             * if rr > rrMax
             */
            if (mclGtBool(mclVv(rr, "rr"), mclVv(rrMax, "rrMax"))) {
                /*
                 * rrMax = rr;
                 */
                mlfAssign(&rrMax, mclVsv(rr, "rr"));
            /*
             * end
             */
            }
            /*
             * if ps > psMax
             */
            if (mclGtBool(mclVv(ps, "ps"), mclVv(psMax, "psMax"))) {
                /*
                 * psMax = ps;
                 */
                mlfAssign(&psMax, mclVsv(ps, "ps"));
            /*
             * end
             */
            }
            /*
             * if tt > ttMax
             */
            if (mclGtBool(mclVv(tt, "tt"), mclVv(ttMax, "ttMax"))) {
                /*
                 * ttMax = tt;
                 */
                mlfAssign(&ttMax, mclVsv(tt, "tt"));
            /*
             * end
             */
            }
            /*
             * if ec > ecMax
             */
            if (mclGtBool(mclVv(ec, "ec"), mclVv(ecMax, "ecMax"))) {
                /*
                 * ecMax = ec;
                 */
                mlfAssign(&ecMax, mclVsv(ec, "ec"));
            /*
             * end
             */
            }
        /*
         * 
         * end
         */
        }
        /*
         * 
         * %fprintf(fp,'%d %d %d %d %d %d %d\n',ccc,rr,ccMax,ps,tt,ec,mdh.UsedChannels);
         * ccc=ccc+1;
         */
        mlfAssign(&ccc, mclPlus(mclVv(ccc, "ccc"), _mxarray3_));
    /*
     * 
     * end
     */
    }
    /*
     * %fclose(fp);
     * 
     * if(partitionMax>1)
     */
    if (mclGtBool(mclVv(partitionMax, "partitionMax"), _mxarray3_)) {
        /*
         * fprintf('3D sequence data...\n');
         */
        mclAssignAns(&ans, mlfNFprintf(0, _mxarray24_, NULL));
        /*
         * flag_3D=1;
         */
        mlfAssign(&flag_3D, _mxarray3_);
    /*
     * else
     */
    } else {
        /*
         * fprintf('2D sequence data...\n');
         */
        mclAssignAns(&ans, mlfNFprintf(0, _mxarray26_, NULL));
        /*
         * flag_3D=0;
         */
        mlfAssign(&flag_3D, _mxarray5_);
    /*
     * end;
     */
    }
    /*
     * 
     * 
     * if DISPLAY
     */
    if (mlfTobool(mclVv(DISPLAY, "DISPLAY"))) {
        /*
         * toc
         */
        mclPrintAns(&ans, mlfNToc(0));
    /*
     * %	[rrMax ccMax psMax ttMax ecMax]
     * %	fprintf('Paused: Hit any key\n');
     * %	pause
     * end
     */
    }
    /*
     * 
     * % Initialize for loop 2
     * fprintf('Total Used channel=%d\n',mdh.UsedChannels);
     */
    mclAssignAns(
      &ans,
      mlfNFprintf(
        0,
        _mxarray28_,
        mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".UsedChannels")),
        NULL));
    /*
     * 
     * 
     * kvol = zeros(rrMax, ccMax, psMax, ttMax, ecMax, mdh.UsedChannels);
     */
    mlfAssign(
      &kvol,
      mlfZeros(
        mclVv(rrMax, "rrMax"),
        mclVv(ccMax, "ccMax"),
        mclVv(psMax, "psMax"),
        mclVv(ttMax, "ttMax"),
        mclVv(ecMax, "ecMax"),
        mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".UsedChannels")),
        NULL));
    /*
     * kvol_orig = zeros(rrMax, ccMax, psMax, ttMax, ecMax, mdh.UsedChannels);
     */
    mlfAssign(
      kvol_orig,
      mlfZeros(
        mclVv(rrMax, "rrMax"),
        mclVv(ccMax, "ccMax"),
        mclVv(psMax, "psMax"),
        mclVv(ttMax, "ttMax"),
        mclVv(ecMax, "ecMax"),
        mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".UsedChannels")),
        NULL));
    /*
     * navs = zeros(numNavs, ccMax, psMax, ttMax, ecMax, mdh.UsedChannels );
     */
    mlfAssign(
      navs,
      mlfZeros(
        mclVv(numNavs, "numNavs"),
        mclVv(ccMax, "ccMax"),
        mclVv(psMax, "psMax"),
        mclVv(ttMax, "ttMax"),
        mclVv(ecMax, "ecMax"),
        mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".UsedChannels")),
        NULL));
    /*
     * numADCs = rrMax*psMax*ttMax*ecMax*mdh.UsedChannels;
     */
    mlfAssign(
      &numADCs,
      mclFeval(
        mclValueVarargout(),
        mlxMtimes,
        mclMtimes(
          mclMtimes(
            mclMtimes(mclVv(rrMax, "rrMax"), mclVv(psMax, "psMax")),
            mclVv(ttMax, "ttMax")),
          mclVv(ecMax, "ecMax")),
        mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".UsedChannels")),
        NULL));
    /*
     * PERC = 5;
     */
    mlfAssign(&PERC, _mxarray30_);
    /*
     * counter = 1;
     */
    mlfAssign(&counter, _mxarray3_);
    /*
     * navcounter = 1;
     */
    mlfAssign(&navcounter, _mxarray3_);
    /*
     * fseek(fid, meas_out_start_offset, 'bof'); 
     */
    mclAssignAns(
      &ans,
      mlfFseek(
        mclVv(fid, "fid"),
        mclVv(meas_out_start_offset, "meas_out_start_offset"),
        _mxarray19_));
    /*
     * CONT = 1;
     */
    mlfAssign(&CONT, _mxarray3_);
    /*
     * %rrMax
     * %ccMax
     * %psMax
     * %ttMax
     * %ecMax
     * %mdh.UsedChannels
     * %ccc
     * %pause;
     * 
     * 
     * 
     * % Start loop 2
     * if DISPLAY
     */
    if (mlfTobool(mclVv(DISPLAY, "DISPLAY"))) {
        /*
         * tic
         */
        mlfTic();
    /*
     * end
     */
    }
    /*
     * while CONT == 1
     */
    while (mclEqBool(mclVv(CONT, "CONT"), _mxarray3_)) {
        /*
         * 
         * [adc_data, mdh] = read_mdh_adc(fid);
         */
        mlfAssign(&adc_data, mlfRead_mdh_adc(&mdh, mclVv(fid, "fid")));
        /*
         * 
         * 
         * if mdh.EvalInfoMask(1) % i.e. MDH_ACQEND
         */
        if (mlfTobool(
              mclVe(
                mlfIndexRef(
                  mclVsv(mdh, "mdh"), ".EvalInfoMask(?)", _mxarray3_)))) {
            /*
             * 
             * CONT = 0;
             */
            mlfAssign(&CONT, _mxarray5_);
        /*
         * 
         * else
         */
        } else {
            /*
             * 
             * rr = mdh.LoopCounter.Line + 1;
             */
            mlfAssign(
              &rr,
              mclFeval(
                mclValueVarargout(),
                mlxPlus,
                mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Line")),
                _mxarray3_,
                NULL));
            /*
             * 
             * ps = max(mdh.LoopCounter.Partition + 1, mdh.LoopCounter.Slice + 1);
             */
            mlfAssign(
              &ps,
              mlfMax(
                NULL,
                mclFeval(
                  mclValueVarargout(),
                  mlxPlus,
                  mclVe(
                    mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Partition")),
                  _mxarray3_,
                  NULL),
                mclFeval(
                  mclValueVarargout(),
                  mlxPlus,
                  mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Slice")),
                  _mxarray3_,
                  NULL),
                NULL));
            /*
             * 
             * tt = mdh.LoopCounter.Repetition + 1;
             */
            mlfAssign(
              &tt,
              mclFeval(
                mclValueVarargout(),
                mlxPlus,
                mclVe(
                  mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Repetition")),
                _mxarray3_,
                NULL));
            /*
             * ec = mdh.LoopCounter.Echo + 1;
             */
            mlfAssign(
              &ec,
              mclFeval(
                mclValueVarargout(),
                mlxPlus,
                mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".LoopCounter.Echo")),
                _mxarray3_,
                NULL));
            /*
             * 
             * if mdh.EvalInfoMask(22) % i.e. MDH_PHASECOR
             */
            if (mlfTobool(
                  mclVe(
                    mlfIndexRef(
                      mclVsv(mdh, "mdh"), ".EvalInfoMask(?)", _mxarray31_)))) {
                /*
                 * 
                 * if mdh.EvalInfoMask(25) % MDH_REFLECT
                 */
                if (mlfTobool(
                      mclVe(
                        mlfIndexRef(
                          mclVsv(mdh, "mdh"),
                          ".EvalInfoMask(?)",
                          _mxarray32_)))) {
                    /*
                     * adc_data = fliplr(adc_data);
                     */
                    mlfAssign(
                      &adc_data, mlfFliplr(mclVv(adc_data, "adc_data")));
                    /*
                     * adc_data = adc_data([end, 1:end-1]);
                     */
                    mlfAssign(
                      &adc_data,
                      mclArrayRef1(
                        mclVsv(adc_data, "adc_data"),
                        mlfHorzcat(
                          mlfEnd(
                            mclVv(adc_data, "adc_data"),
                            _mxarray3_,
                            _mxarray3_),
                          mlfColon(
                            _mxarray3_,
                            mclMinus(
                              mlfEnd(
                                mclVv(adc_data, "adc_data"),
                                _mxarray3_,
                                _mxarray3_),
                              _mxarray3_),
                            NULL),
                          NULL)));
                /*
                 * end
                 */
                }
                /*
                 * 
                 * navs(navcounter, :, ps, tt, ec,mdh.ChannelId+1) = adc_data;
                 */
                mlfIndexAssign(
                  navs,
                  "(?,?,?,?,?,?)",
                  mclVsv(navcounter, "navcounter"),
                  mlfCreateColonIndex(),
                  mclVsv(ps, "ps"),
                  mclVsv(tt, "tt"),
                  mclVsv(ec, "ec"),
                  mclFeval(
                    mclValueVarargout(),
                    mlxPlus,
                    mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".ChannelId")),
                    _mxarray3_,
                    NULL),
                  mclVsv(adc_data, "adc_data"));
                /*
                 * navcounter = navcounter + 1;
                 */
                mlfAssign(
                  &navcounter,
                  mclPlus(mclVv(navcounter, "navcounter"), _mxarray3_));
                /*
                 * 
                 * if navcounter > 3
                 */
                if (mclGtBool(mclVv(navcounter, "navcounter"), _mxarray2_)) {
                    /*
                     * %reset navigator counter
                     * navcounter = 1;
                     */
                    mlfAssign(&navcounter, _mxarray3_);
                    /*
                     * 
                     * for ch=1:size(navs,6)
                     */
                    {
                        int v_ = mclForIntStart(1);
                        int e_
                          = mclForIntEnd(
                              mclVe(
                                mlfSize(
                                  mclValueVarargout(),
                                  mclVv(*navs, "navs"),
                                  _mxarray34_)));
                        if (v_ > e_) {
                            mlfAssign(&ch, _mxarray6_);
                        } else {
                            /*
                             * %corrvec{ps,tt,ec,ch}=angle( (0.5*(navs(1,:,ps,tt,ec,ch)+ navs(3,:,ps,tt,ec,ch) ))./navs(2,:,ps,tt,ec,ch));
                             * corrvec{ps,tt,ec,ch}=angle(fft( 0.5*(navs(1,:,ps,tt,ec,ch)+ navs(3,:,ps,tt,ec,ch)))./fft(navs(2,:,ps,tt,ec,ch)));
                             * 
                             * %determine either positive or negative phase compensation.
                             * nav_odd=0.5*(navs(1,:,ps,tt,ec,ch)+ navs(3,:,ps,tt,ec,ch));
                             * nav_even=navs(2,:,ps,tt,ec,ch);
                             * if(max(real(nav_odd))<max(real(nav_even)))
                             * flag_neg=1;
                             * else
                             * flag_neg=0;
                             * end;
                             * end;
                             */
                            for (; ; ) {
                                mlfIndexAssign(
                                  &corrvec,
                                  "{?,?,?,?}",
                                  mclVsv(ps, "ps"),
                                  mclVsv(tt, "tt"),
                                  mclVsv(ec, "ec"),
                                  mlfScalar(v_),
                                  mlfAngle(
                                    mclRdivide(
                                      mclVe(
                                        mlfFft(
                                          mclMtimes(
                                            _mxarray33_,
                                            mclPlus(
                                              mclVe(
                                                mlfIndexRef(
                                                  mclVsv(*navs, "navs"),
                                                  "(?,?,?,?,?,?)",
                                                  _mxarray3_,
                                                  mlfCreateColonIndex(),
                                                  mclVsv(ps, "ps"),
                                                  mclVsv(tt, "tt"),
                                                  mclVsv(ec, "ec"),
                                                  mlfScalar(v_))),
                                              mclVe(
                                                mlfIndexRef(
                                                  mclVsv(*navs, "navs"),
                                                  "(?,?,?,?,?,?)",
                                                  _mxarray2_,
                                                  mlfCreateColonIndex(),
                                                  mclVsv(ps, "ps"),
                                                  mclVsv(tt, "tt"),
                                                  mclVsv(ec, "ec"),
                                                  mlfScalar(v_))))),
                                          NULL,
                                          NULL)),
                                      mclVe(
                                        mlfFft(
                                          mclVe(
                                            mlfIndexRef(
                                              mclVsv(*navs, "navs"),
                                              "(?,?,?,?,?,?)",
                                              _mxarray4_,
                                              mlfCreateColonIndex(),
                                              mclVsv(ps, "ps"),
                                              mclVsv(tt, "tt"),
                                              mclVsv(ec, "ec"),
                                              mlfScalar(v_))),
                                          NULL,
                                          NULL)))));
                                mlfAssign(
                                  &nav_odd,
                                  mclMtimes(
                                    _mxarray33_,
                                    mclPlus(
                                      mclVe(
                                        mlfIndexRef(
                                          mclVsv(*navs, "navs"),
                                          "(?,?,?,?,?,?)",
                                          _mxarray3_,
                                          mlfCreateColonIndex(),
                                          mclVsv(ps, "ps"),
                                          mclVsv(tt, "tt"),
                                          mclVsv(ec, "ec"),
                                          mlfScalar(v_))),
                                      mclVe(
                                        mlfIndexRef(
                                          mclVsv(*navs, "navs"),
                                          "(?,?,?,?,?,?)",
                                          _mxarray2_,
                                          mlfCreateColonIndex(),
                                          mclVsv(ps, "ps"),
                                          mclVsv(tt, "tt"),
                                          mclVsv(ec, "ec"),
                                          mlfScalar(v_))))));
                                mlfAssign(
                                  &nav_even,
                                  mlfIndexRef(
                                    mclVsv(*navs, "navs"),
                                    "(?,?,?,?,?,?)",
                                    _mxarray4_,
                                    mlfCreateColonIndex(),
                                    mclVsv(ps, "ps"),
                                    mclVsv(tt, "tt"),
                                    mclVsv(ec, "ec"),
                                    mlfScalar(v_)));
                                if (mclLtBool(
                                      mclVe(
                                        mlfMax(
                                          NULL,
                                          mclVe(
                                            mlfReal(mclVv(nav_odd, "nav_odd"))),
                                          NULL,
                                          NULL)),
                                      mclVe(
                                        mlfMax(
                                          NULL,
                                          mclVe(
                                            mlfReal(
                                              mclVv(nav_even, "nav_even"))),
                                          NULL,
                                          NULL)))) {
                                    mlfAssign(&flag_neg, _mxarray3_);
                                } else {
                                    mlfAssign(&flag_neg, _mxarray5_);
                                }
                                if (v_ == e_) {
                                    break;
                                }
                                ++v_;
                            }
                            mlfAssign(&ch, mlfScalar(v_));
                        }
                    }
                /*
                 * end
                 */
                }
            /*
             * 
             * else
             */
            } else {
                /*
                 * %original un-processed k-space data
                 * kvol_orig(rr, :, ps, tt, ec, mdh.ChannelId+1) = adc_data;            
                 */
                mlfIndexAssign(
                  kvol_orig,
                  "(?,?,?,?,?,?)",
                  mclVsv(rr, "rr"),
                  mlfCreateColonIndex(),
                  mclVsv(ps, "ps"),
                  mclVsv(tt, "tt"),
                  mclVsv(ec, "ec"),
                  mclFeval(
                    mclValueVarargout(),
                    mlxPlus,
                    mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".ChannelId")),
                    _mxarray3_,
                    NULL),
                  mclVsv(adc_data, "adc_data"));
                /*
                 * 
                 * if mdh.EvalInfoMask(25)
                 */
                if (mlfTobool(
                      mclVe(
                        mlfIndexRef(
                          mclVsv(mdh, "mdh"),
                          ".EvalInfoMask(?)",
                          _mxarray32_)))) {
                    /*
                     * adc_data = fliplr(adc_data);
                     */
                    mlfAssign(
                      &adc_data, mlfFliplr(mclVv(adc_data, "adc_data")));
                    /*
                     * adc_data = adc_data([end, 1:end-1]);
                     */
                    mlfAssign(
                      &adc_data,
                      mclArrayRef1(
                        mclVsv(adc_data, "adc_data"),
                        mlfHorzcat(
                          mlfEnd(
                            mclVv(adc_data, "adc_data"),
                            _mxarray3_,
                            _mxarray3_),
                          mlfColon(
                            _mxarray3_,
                            mclMinus(
                              mlfEnd(
                                mclVv(adc_data, "adc_data"),
                                _mxarray3_,
                                _mxarray3_),
                              _mxarray3_),
                            NULL),
                          NULL)));
                    /*
                     * 
                     * %kvol(rr, :, ps, tt, ec, mdh.ChannelId+1) = adc_data.*exp(sqrt(-1.0)*(corrvec{ps,tt,ec,mdh.ChannelId+1}));
                     * 
                     * if(flag_neg)
                     */
                    if (mlfTobool(mclVv(flag_neg, "flag_neg"))) {
                        /*
                         * %negative phase compensation
                         * kvol(rr, :, ps, tt, ec, mdh.ChannelId+1) = ifft(fft(adc_data).*exp(sqrt(-1.0)*(0-corrvec{ps,tt,ec,mdh.ChannelId+1})));
                         */
                        mlfIndexAssign(
                          &kvol,
                          "(?,?,?,?,?,?)",
                          mclVsv(rr, "rr"),
                          mlfCreateColonIndex(),
                          mclVsv(ps, "ps"),
                          mclVsv(tt, "tt"),
                          mclVsv(ec, "ec"),
                          mclFeval(
                            mclValueVarargout(),
                            mlxPlus,
                            mclVe(
                              mlfIndexRef(mclVsv(mdh, "mdh"), ".ChannelId")),
                            _mxarray3_,
                            NULL),
                          mlfIfft(
                            mclTimes(
                              mclVe(
                                mlfFft(
                                  mclVv(adc_data, "adc_data"), NULL, NULL)),
                              mclVe(
                                mlfExp(
                                  mclMtimes(
                                    mclVe(mlfSqrt(_mxarray35_)),
                                    mclFeval(
                                      mclValueVarargout(),
                                      mlxMinus,
                                      _mxarray5_,
                                      mclVe(
                                        mlfIndexRef(
                                          mclVsv(corrvec, "corrvec"),
                                          "{?,?,?,?}",
                                          mclVsv(ps, "ps"),
                                          mclVsv(tt, "tt"),
                                          mclVsv(ec, "ec"),
                                          mclFeval(
                                            mclValueVarargout(),
                                            mlxPlus,
                                            mclVe(
                                              mlfIndexRef(
                                                mclVsv(mdh, "mdh"),
                                                ".ChannelId")),
                                            _mxarray3_,
                                            NULL))),
                                      NULL))))),
                            NULL,
                            NULL));
                    /*
                     * else
                     */
                    } else {
                        /*
                         * %positive phase compensation
                         * kvol(rr, :, ps, tt, ec, mdh.ChannelId+1) = ifft(fft(adc_data).*exp(sqrt(-1.0)*(corrvec{ps,tt,ec,mdh.ChannelId+1})));
                         */
                        mlfIndexAssign(
                          &kvol,
                          "(?,?,?,?,?,?)",
                          mclVsv(rr, "rr"),
                          mlfCreateColonIndex(),
                          mclVsv(ps, "ps"),
                          mclVsv(tt, "tt"),
                          mclVsv(ec, "ec"),
                          mclFeval(
                            mclValueVarargout(),
                            mlxPlus,
                            mclVe(
                              mlfIndexRef(mclVsv(mdh, "mdh"), ".ChannelId")),
                            _mxarray3_,
                            NULL),
                          mlfIfft(
                            mclTimes(
                              mclVe(
                                mlfFft(
                                  mclVv(adc_data, "adc_data"), NULL, NULL)),
                              mclVe(
                                mlfExp(
                                  mclFeval(
                                    mclValueVarargout(),
                                    mlxMtimes,
                                    mclVe(mlfSqrt(_mxarray35_)),
                                    mclVe(
                                      mlfIndexRef(
                                        mclVsv(corrvec, "corrvec"),
                                        "{?,?,?,?}",
                                        mclVsv(ps, "ps"),
                                        mclVsv(tt, "tt"),
                                        mclVsv(ec, "ec"),
                                        mclFeval(
                                          mclValueVarargout(),
                                          mlxPlus,
                                          mclVe(
                                            mlfIndexRef(
                                              mclVsv(mdh, "mdh"),
                                              ".ChannelId")),
                                          _mxarray3_,
                                          NULL))),
                                    NULL)))),
                            NULL,
                            NULL));
                    /*
                     * end;
                     */
                    }
                /*
                 * else
                 */
                } else {
                    /*
                     * kvol(rr, :, ps, tt, ec, mdh.ChannelId+1) = adc_data;
                     */
                    mlfIndexAssign(
                      &kvol,
                      "(?,?,?,?,?,?)",
                      mclVsv(rr, "rr"),
                      mlfCreateColonIndex(),
                      mclVsv(ps, "ps"),
                      mclVsv(tt, "tt"),
                      mclVsv(ec, "ec"),
                      mclFeval(
                        mclValueVarargout(),
                        mlxPlus,
                        mclVe(mlfIndexRef(mclVsv(mdh, "mdh"), ".ChannelId")),
                        _mxarray3_,
                        NULL),
                      mclVsv(adc_data, "adc_data"));
                /*
                 * end
                 */
                }
            /*
             * end
             */
            }
            /*
             * 
             * if DISPLAY
             */
            if (mlfTobool(mclVv(DISPLAY, "DISPLAY"))) {
                /*
                 * if 100*counter/numADCs > PERC;
                 */
                if (mclGtBool(
                      mclMrdivide(
                        mclMtimes(_mxarray21_, mclVv(counter, "counter")),
                        mclVv(numADCs, "numADCs")),
                      mclVv(PERC, "PERC"))) {
                    /*
                     * fprintf('%d%% done\n', PERC);
                     */
                    mclAssignAns(
                      &ans,
                      mlfNFprintf(0, _mxarray36_, mclVv(PERC, "PERC"), NULL));
                    /*
                     * PERC = PERC + 5;
                     */
                    mlfAssign(&PERC, mclPlus(mclVv(PERC, "PERC"), _mxarray30_));
                /*
                 * end
                 */
                }
            /*
             * end
             */
            }
            /*
             * 
             * counter = counter + 1;
             */
            mlfAssign(&counter, mclPlus(mclVv(counter, "counter"), _mxarray3_));
        /*
         * end
         */
        }
    /*
     * end
     */
    }
    /*
     * 
     * fprintf('\n');
     */
    mclAssignAns(&ans, mlfNFprintf(0, _mxarray38_, NULL));
    /*
     * 
     * 
     * if(flag_3D)
     */
    if (mlfTobool(mclVv(flag_3D, "flag_3D"))) {
        /*
         * fprintf('FFT at the partition dimension for 3D sequence...\n');
         */
        mclAssignAns(&ans, mlfNFprintf(0, _mxarray40_, NULL));
        /*
         * kvol=fftshift(fft(fftshift(kvol,3),[],3),3);
         */
        mlfAssign(
          &kvol,
          mlfFftshift(
            mclVe(
              mlfFft(
                mclVe(mlfFftshift(mclVv(kvol, "kvol"), _mxarray2_)),
                _mxarray6_,
                _mxarray2_)),
            _mxarray2_));
    /*
     * end;
     */
    }
    /*
     * 
     * if DISPLAY
     */
    if (mlfTobool(mclVv(DISPLAY, "DISPLAY"))) {
        /*
         * toc
         */
        mclPrintAns(&ans, mlfNToc(0));
    /*
     * end
     */
    }
    /*
     * 
     * fclose(fid);
     */
    mclAssignAns(&ans, mlfFclose(mclVv(fid, "fid")));
    mclValidateOutput(kvol, 1, nargout_, "kvol", "myread_meas_out");
    mclValidateOutput(*navs, 2, nargout_, "navs", "myread_meas_out");
    mclValidateOutput(*kvol_orig, 3, nargout_, "kvol_orig", "myread_meas_out");
    mxDestroyArray(numNavs);
    mxDestroyArray(DISPLAY);
    mxDestroyArray(fname);
    mxDestroyArray(files);
    mxDestroyArray(MEASOUT_FOUND);
    mxDestroyArray(ff);
    mxDestroyArray(ans);
    mxDestroyArray(fid);
    mxDestroyArray(meas_out_start_offset);
    mxDestroyArray(ccMax);
    mxDestroyArray(rrMax);
    mxDestroyArray(psMax);
    mxDestroyArray(ttMax);
    mxDestroyArray(ecMax);
    mxDestroyArray(CONT);
    mxDestroyArray(sliceMax);
    mxDestroyArray(partitionMax);
    mxDestroyArray(ccc);
    mxDestroyArray(adc_data);
    mxDestroyArray(mdh);
    mxDestroyArray(rr);
    mxDestroyArray(ps);
    mxDestroyArray(tt);
    mxDestroyArray(ec);
    mxDestroyArray(flag_3D);
    mxDestroyArray(numADCs);
    mxDestroyArray(PERC);
    mxDestroyArray(counter);
    mxDestroyArray(navcounter);
    mxDestroyArray(ch);
    mxDestroyArray(corrvec);
    mxDestroyArray(nav_odd);
    mxDestroyArray(nav_even);
    mxDestroyArray(flag_neg);
    mxDestroyArray(varargin);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return kvol;
    /*
     * 
     * %more on
     */
}
