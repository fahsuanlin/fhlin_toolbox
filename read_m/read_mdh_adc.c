/*
 * MATLAB Compiler: 2.2
 * Date: Wed Jul  3 14:59:34 2002
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-h" "-A" "annotation:all"
 * "myread_meas_out" 
 */
#include "read_mdh_adc.h"
#include "complex_mex_interface.h"
#include "libmatlbm.h"

static mxChar _array1_[142] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 'a', 'd', '_',
                                'm', 'd', 'h', '_', 'a', 'd', 'c', ' ', 'L',
                                'i', 'n', 'e', ':', ' ', '1', ' ', 'C', 'o',
                                'l', 'u', 'm', 'n', ':', ' ', '1', ' ', 'T',
                                'h', 'e', ' ', 'f', 'u', 'n', 'c', 't', 'i',
                                'o', 'n', ' ', '"', 'r', 'e', 'a', 'd', '_',
                                'm', 'd', 'h', '_', 'a', 'd', 'c', '"', ' ',
                                'w', 'a', 's', ' ', 'c', 'a', 'l', 'l', 'e',
                                'd', ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o',
                                'r', 'e', ' ', 't', 'h', 'a', 'n', ' ', 't',
                                'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r',
                                'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r',
                                ' ', 'o', 'f', ' ', 'o', 'u', 't', 'p', 'u',
                                't', 's', ' ', '(', '2', ')', '.' };
static mxArray * _mxarray0_;

static mxChar _array3_[141] = { 'R', 'u', 'n', '-', 't', 'i', 'm', 'e', ' ',
                                'E', 'r', 'r', 'o', 'r', ':', ' ', 'F', 'i',
                                'l', 'e', ':', ' ', 'r', 'e', 'a', 'd', '_',
                                'm', 'd', 'h', '_', 'a', 'd', 'c', ' ', 'L',
                                'i', 'n', 'e', ':', ' ', '1', ' ', 'C', 'o',
                                'l', 'u', 'm', 'n', ':', ' ', '1', ' ', 'T',
                                'h', 'e', ' ', 'f', 'u', 'n', 'c', 't', 'i',
                                'o', 'n', ' ', '"', 'r', 'e', 'a', 'd', '_',
                                'm', 'd', 'h', '_', 'a', 'd', 'c', '"', ' ',
                                'w', 'a', 's', ' ', 'c', 'a', 'l', 'l', 'e',
                                'd', ' ', 'w', 'i', 't', 'h', ' ', 'm', 'o',
                                'r', 'e', ' ', 't', 'h', 'a', 'n', ' ', 't',
                                'h', 'e', ' ', 'd', 'e', 'c', 'l', 'a', 'r',
                                'e', 'd', ' ', 'n', 'u', 'm', 'b', 'e', 'r',
                                ' ', 'o', 'f', ' ', 'i', 'n', 'p', 'u', 't',
                                's', ' ', '(', '1', ')', '.' };
static mxArray * _mxarray2_;
static mxArray * _mxarray4_;

static mxChar _array6_[5] = { 'u', 'l', 'o', 'n', 'g' };
static mxArray * _mxarray5_;

static mxChar _array8_[4] = { 'l', 'o', 'n', 'g' };
static mxArray * _mxarray7_;
static mxArray * _mxarray9_;

static mxChar _array13_[10] = { 'M', 'D', 'H', '_', 'A',
                                'C', 'Q', 'E', 'N', 'D' };
static mxArray * _mxarray12_;

static mxChar _array15_[14] = { 'M', 'D', 'H', '_', 'R', 'T', 'F',
                                'E', 'E', 'D', 'B', 'A', 'C', 'K' };
static mxArray * _mxarray14_;

static mxChar _array17_[14] = { 'M', 'D', 'H', '_', 'H', 'P', 'F',
                                'E', 'E', 'D', 'B', 'A', 'C', 'K' };
static mxArray * _mxarray16_;

static mxChar _array19_[10] = { 'M', 'D', 'H', '_', 'O',
                                'N', 'L', 'I', 'N', 'E' };
static mxArray * _mxarray18_;

static mxChar _array21_[11] = { 'M', 'D', 'H', '_', 'O', 'F',
                                'F', 'L', 'I', 'N', 'E' };
static mxArray * _mxarray20_;

static mxChar _array23_[3] = { 'S', 'i', 'x' };
static mxArray * _mxarray22_;

static mxChar _array25_[5] = { 'S', 'e', 'v', 'e', 'n' };
static mxArray * _mxarray24_;

static mxChar _array27_[5] = { 'E', 'i', 'g', 'h', 't' };
static mxArray * _mxarray26_;

static mxChar _array29_[4] = { 'N', 'i', 'n', 'e' };
static mxArray * _mxarray28_;

static mxChar _array31_[3] = { 'T', 'e', 'n' };
static mxArray * _mxarray30_;

static mxChar _array33_[6] = { 'E', 'l', 'e', 'v', 'e', 'n' };
static mxArray * _mxarray32_;

static mxChar _array35_[6] = { 'T', 'w', 'e', 'l', 'v', 'e' };
static mxArray * _mxarray34_;

static mxChar _array37_[8] = { 'T', 'h', 'i', 'r', 't', 'e', 'e', 'n' };
static mxArray * _mxarray36_;

static mxChar _array39_[8] = { 'F', 'o', 'u', 'r', 't', 'e', 'e', 'n' };
static mxArray * _mxarray38_;

static mxChar _array41_[20] = { 'M', 'D', 'H', '_', 'R', 'E', 'F',
                                'P', 'H', 'A', 'S', 'E', 'S', 'T',
                                'A', 'B', 'S', 'C', 'A', 'N' };
static mxArray * _mxarray40_;

static mxChar _array43_[17] = { 'M', 'D', 'H', '_', 'P', 'H', 'A', 'S', 'E',
                                'S', 'T', 'A', 'B', 'S', 'C', 'A', 'N' };
static mxArray * _mxarray42_;

static mxChar _array45_[9] = { 'M', 'D', 'H', '_', 'D', '3', 'F', 'F', 'T' };
static mxArray * _mxarray44_;

static mxChar _array47_[11] = { 'M', 'D', 'H', '_', 'S', 'I',
                                'G', 'N', 'R', 'E', 'V' };
static mxArray * _mxarray46_;

static mxChar _array49_[12] = { 'M', 'D', 'H', '_', 'P', 'H',
                                'A', 'S', 'E', 'F', 'F', 'T' };
static mxArray * _mxarray48_;

static mxChar _array51_[11] = { 'M', 'D', 'H', '_', 'S', 'W',
                                'A', 'P', 'P', 'E', 'D' };
static mxArray * _mxarray50_;

static mxChar _array53_[18] = { 'M', 'D', 'H', '_', 'P', 'O', 'S', 'T', 'S',
                                'H', 'A', 'R', 'E', 'D', 'L', 'I', 'N', 'E' };
static mxArray * _mxarray52_;

static mxChar _array55_[11] = { 'M', 'D', 'H', '_', 'P', 'H',
                                'A', 'S', 'C', 'O', 'R' };
static mxArray * _mxarray54_;

static mxChar _array57_[12] = { 'M', 'D', 'H', '_', 'Z', 'E',
                                'R', 'O', 'L', 'I', 'N', 'E' };
static mxArray * _mxarray56_;

static mxChar _array59_[17] = { 'M', 'D', 'H', '_', 'Z', 'E', 'R', 'O', 'P',
                                'A', 'R', 'T', 'I', 'T', 'I', 'O', 'N' };
static mxArray * _mxarray58_;

static mxChar _array61_[11] = { 'M', 'D', 'H', '_', 'R', 'E',
                                'F', 'L', 'E', 'C', 'T' };
static mxArray * _mxarray60_;

static mxChar _array63_[16] = { 'M', 'D', 'H', '_', 'N', 'O', 'I', 'S',
                                'E', 'A', 'D', 'J', 'S', 'C', 'A', 'N' };
static mxArray * _mxarray62_;

static mxChar _array65_[12] = { 'M', 'D', 'H', '_', 'S', 'H',
                                'A', 'R', 'E', 'N', 'O', 'W' };
static mxArray * _mxarray64_;

static mxChar _array67_[20] = { 'M', 'D', 'H', '_', 'L', 'A', 'S',
                                'T', 'M', 'E', 'A', 'S', 'U', 'R',
                                'E', 'D', 'L', 'I', 'N', 'E' };
static mxArray * _mxarray66_;

static mxChar _array69_[20] = { 'M', 'D', 'H', '_', 'F', 'I', 'R',
                                'S', 'T', 'S', 'C', 'A', 'N', 'I',
                                'N', 'S', 'L', 'I', 'C', 'E' };
static mxArray * _mxarray68_;

static mxChar _array71_[19] = { 'M', 'D', 'H', '_', 'L', 'A', 'S',
                                'T', 'S', 'C', 'A', 'N', 'I', 'N',
                                'S', 'L', 'I', 'C', 'E' };
static mxArray * _mxarray70_;

static mxChar _array73_[20] = { 'M', 'D', 'H', '_', 'T', 'R', 'E',
                                'F', 'F', 'E', 'C', 'T', 'I', 'V',
                                'E', 'B', 'E', 'G', 'I', 'N' };
static mxArray * _mxarray72_;

static mxChar _array75_[18] = { 'M', 'D', 'H', '_', 'T', 'R', 'E', 'F', 'F',
                                'E', 'C', 'T', 'I', 'V', 'E', 'E', 'N', 'D' };
static mxArray * _mxarray74_;

static mxArray * _array11_[32] = { NULL /*_mxarray12_*/, NULL /*_mxarray14_*/,
                                   NULL /*_mxarray16_*/, NULL /*_mxarray18_*/,
                                   NULL /*_mxarray20_*/, NULL /*_mxarray22_*/,
                                   NULL /*_mxarray24_*/, NULL /*_mxarray26_*/,
                                   NULL /*_mxarray28_*/, NULL /*_mxarray30_*/,
                                   NULL /*_mxarray32_*/, NULL /*_mxarray34_*/,
                                   NULL /*_mxarray36_*/, NULL /*_mxarray38_*/,
                                   NULL /*_mxarray40_*/, NULL /*_mxarray42_*/,
                                   NULL /*_mxarray44_*/, NULL /*_mxarray46_*/,
                                   NULL /*_mxarray48_*/, NULL /*_mxarray50_*/,
                                   NULL /*_mxarray52_*/, NULL /*_mxarray54_*/,
                                   NULL /*_mxarray56_*/, NULL /*_mxarray58_*/,
                                   NULL /*_mxarray60_*/, NULL /*_mxarray62_*/,
                                   NULL /*_mxarray64_*/, NULL /*_mxarray66_*/,
                                   NULL /*_mxarray68_*/, NULL /*_mxarray70_*/,
                                   NULL /*_mxarray72_*/, NULL /*_mxarray74_*/ };
static mxArray * _mxarray10_;
static mxArray * _mxarray76_;
static mxArray * _mxarray77_;

static mxChar _array79_[6] = { 'u', 's', 'h', 'o', 'r', 't' };
static mxArray * _mxarray78_;

static mxChar _array81_[5] = { 'f', 'l', 'o', 'a', 't' };
static mxArray * _mxarray80_;
static mxArray * _mxarray82_;
static mxArray * _mxarray83_;
static mxArray * _mxarray84_;

void InitializeModule_read_mdh_adc(void) {
    _mxarray0_ = mclInitializeString(142, _array1_);
    _mxarray2_ = mclInitializeString(141, _array3_);
    _mxarray4_ = mclInitializeDouble(1.0);
    _mxarray5_ = mclInitializeString(5, _array6_);
    _mxarray7_ = mclInitializeString(4, _array8_);
    _mxarray9_ = mclInitializeDouble(2.5);
    _mxarray12_ = mclInitializeString(10, _array13_);
    _array11_[0] = _mxarray12_;
    _mxarray14_ = mclInitializeString(14, _array15_);
    _array11_[1] = _mxarray14_;
    _mxarray16_ = mclInitializeString(14, _array17_);
    _array11_[2] = _mxarray16_;
    _mxarray18_ = mclInitializeString(10, _array19_);
    _array11_[3] = _mxarray18_;
    _mxarray20_ = mclInitializeString(11, _array21_);
    _array11_[4] = _mxarray20_;
    _mxarray22_ = mclInitializeString(3, _array23_);
    _array11_[5] = _mxarray22_;
    _mxarray24_ = mclInitializeString(5, _array25_);
    _array11_[6] = _mxarray24_;
    _mxarray26_ = mclInitializeString(5, _array27_);
    _array11_[7] = _mxarray26_;
    _mxarray28_ = mclInitializeString(4, _array29_);
    _array11_[8] = _mxarray28_;
    _mxarray30_ = mclInitializeString(3, _array31_);
    _array11_[9] = _mxarray30_;
    _mxarray32_ = mclInitializeString(6, _array33_);
    _array11_[10] = _mxarray32_;
    _mxarray34_ = mclInitializeString(6, _array35_);
    _array11_[11] = _mxarray34_;
    _mxarray36_ = mclInitializeString(8, _array37_);
    _array11_[12] = _mxarray36_;
    _mxarray38_ = mclInitializeString(8, _array39_);
    _array11_[13] = _mxarray38_;
    _mxarray40_ = mclInitializeString(20, _array41_);
    _array11_[14] = _mxarray40_;
    _mxarray42_ = mclInitializeString(17, _array43_);
    _array11_[15] = _mxarray42_;
    _mxarray44_ = mclInitializeString(9, _array45_);
    _array11_[16] = _mxarray44_;
    _mxarray46_ = mclInitializeString(11, _array47_);
    _array11_[17] = _mxarray46_;
    _mxarray48_ = mclInitializeString(12, _array49_);
    _array11_[18] = _mxarray48_;
    _mxarray50_ = mclInitializeString(11, _array51_);
    _array11_[19] = _mxarray50_;
    _mxarray52_ = mclInitializeString(18, _array53_);
    _array11_[20] = _mxarray52_;
    _mxarray54_ = mclInitializeString(11, _array55_);
    _array11_[21] = _mxarray54_;
    _mxarray56_ = mclInitializeString(12, _array57_);
    _array11_[22] = _mxarray56_;
    _mxarray58_ = mclInitializeString(17, _array59_);
    _array11_[23] = _mxarray58_;
    _mxarray60_ = mclInitializeString(11, _array61_);
    _array11_[24] = _mxarray60_;
    _mxarray62_ = mclInitializeString(16, _array63_);
    _array11_[25] = _mxarray62_;
    _mxarray64_ = mclInitializeString(12, _array65_);
    _array11_[26] = _mxarray64_;
    _mxarray66_ = mclInitializeString(20, _array67_);
    _array11_[27] = _mxarray66_;
    _mxarray68_ = mclInitializeString(20, _array69_);
    _array11_[28] = _mxarray68_;
    _mxarray70_ = mclInitializeString(19, _array71_);
    _array11_[29] = _mxarray70_;
    _mxarray72_ = mclInitializeString(20, _array73_);
    _array11_[30] = _mxarray72_;
    _mxarray74_ = mclInitializeString(18, _array75_);
    _array11_[31] = _mxarray74_;
    _mxarray10_ = mclInitializeCellVector(1, 32, _array11_);
    _mxarray76_ = mclInitializeDouble(32.0);
    _mxarray77_ = mclInitializeDoubleVector(0, 0, (double *)NULL);
    _mxarray78_ = mclInitializeString(6, _array79_);
    _mxarray80_ = mclInitializeString(5, _array81_);
    _mxarray82_ = mclInitializeDouble(14.0);
    _mxarray83_ = mclInitializeDouble(4.0);
    _mxarray84_ = mclInitializeDouble(2.0);
}

void TerminateModule_read_mdh_adc(void) {
    mxDestroyArray(_mxarray84_);
    mxDestroyArray(_mxarray83_);
    mxDestroyArray(_mxarray82_);
    mxDestroyArray(_mxarray80_);
    mxDestroyArray(_mxarray78_);
    mxDestroyArray(_mxarray77_);
    mxDestroyArray(_mxarray76_);
    mxDestroyArray(_mxarray10_);
    mxDestroyArray(_mxarray74_);
    mxDestroyArray(_mxarray72_);
    mxDestroyArray(_mxarray70_);
    mxDestroyArray(_mxarray68_);
    mxDestroyArray(_mxarray66_);
    mxDestroyArray(_mxarray64_);
    mxDestroyArray(_mxarray62_);
    mxDestroyArray(_mxarray60_);
    mxDestroyArray(_mxarray58_);
    mxDestroyArray(_mxarray56_);
    mxDestroyArray(_mxarray54_);
    mxDestroyArray(_mxarray52_);
    mxDestroyArray(_mxarray50_);
    mxDestroyArray(_mxarray48_);
    mxDestroyArray(_mxarray46_);
    mxDestroyArray(_mxarray44_);
    mxDestroyArray(_mxarray42_);
    mxDestroyArray(_mxarray40_);
    mxDestroyArray(_mxarray38_);
    mxDestroyArray(_mxarray36_);
    mxDestroyArray(_mxarray34_);
    mxDestroyArray(_mxarray32_);
    mxDestroyArray(_mxarray30_);
    mxDestroyArray(_mxarray28_);
    mxDestroyArray(_mxarray26_);
    mxDestroyArray(_mxarray24_);
    mxDestroyArray(_mxarray22_);
    mxDestroyArray(_mxarray20_);
    mxDestroyArray(_mxarray18_);
    mxDestroyArray(_mxarray16_);
    mxDestroyArray(_mxarray14_);
    mxDestroyArray(_mxarray12_);
    mxDestroyArray(_mxarray9_);
    mxDestroyArray(_mxarray7_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray4_);
    mxDestroyArray(_mxarray2_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * Mread_mdh_adc(mxArray * * mdh, int nargout_, mxArray * fid);

_mexLocalFunctionTable _local_function_table_read_mdh_adc
  = { 0, (mexFunctionTableEntry *)NULL };

/*
 * The function "mlfRead_mdh_adc" contains the normal interface for the
 * "read_mdh_adc" M-function from file
 * "/.automount/space/local_mount/homes/nmrnew/home/fhlin/matlab/toolbox/fhlin_t
 * oolbox/read_m/read_mdh_adc.m" (lines 1-104). This function processes any
 * input arguments and passes them to the implementation version of the
 * function, appearing above.
 */
mxArray * mlfRead_mdh_adc(mxArray * * mdh, mxArray * fid) {
    int nargout = 1;
    mxArray * adc_data = mclGetUninitializedArray();
    mxArray * mdh__ = mclGetUninitializedArray();
    mlfEnterNewContext(1, 1, mdh, fid);
    if (mdh != NULL) {
        ++nargout;
    }
    adc_data = Mread_mdh_adc(&mdh__, nargout, fid);
    mlfRestorePreviousContext(1, 1, mdh, fid);
    if (mdh != NULL) {
        mclCopyOutputArg(mdh, mdh__);
    } else {
        mxDestroyArray(mdh__);
    }
    return mlfReturnValue(adc_data);
}

/*
 * The function "mlxRead_mdh_adc" contains the feval interface for the
 * "read_mdh_adc" M-function from file
 * "/.automount/space/local_mount/homes/nmrnew/home/fhlin/matlab/toolbox/fhlin_t
 * oolbox/read_m/read_mdh_adc.m" (lines 1-104). The feval function calls the
 * implementation version of read_mdh_adc through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxRead_mdh_adc(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]) {
    mxArray * mprhs[1];
    mxArray * mplhs[2];
    int i;
    if (nlhs > 2) {
        mlfError(_mxarray0_);
    }
    if (nrhs > 1) {
        mlfError(_mxarray2_);
    }
    for (i = 0; i < 2; ++i) {
        mplhs[i] = mclGetUninitializedArray();
    }
    for (i = 0; i < 1 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 1; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 1, mprhs[0]);
    mplhs[0] = Mread_mdh_adc(&mplhs[1], nlhs, mprhs[0]);
    mlfRestorePreviousContext(0, 1, mprhs[0]);
    plhs[0] = mplhs[0];
    for (i = 1; i < 2 && i < nlhs; ++i) {
        plhs[i] = mplhs[i];
    }
    for (; i < 2; ++i) {
        mxDestroyArray(mplhs[i]);
    }
}

/*
 * The function "Mread_mdh_adc" is the implementation version of the
 * "read_mdh_adc" M-function from file
 * "/.automount/space/local_mount/homes/nmrnew/home/fhlin/matlab/toolbox/fhlin_t
 * oolbox/read_m/read_mdh_adc.m" (lines 1-104). It contains the actual compiled
 * code for that M-function. It is a static function and must only be called
 * from one of the interface functions, appearing below.
 */
/*
 * function [adc_data, mdh] = read_mdh_adc(fid)
 */
static mxArray * Mread_mdh_adc(mxArray * * mdh, int nargout_, mxArray * fid) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(&_local_function_table_read_mdh_adc);
    mxArray * adc_data = mclGetUninitializedArray();
    mxArray * iii = mclGetUninitializedArray();
    mxArray * mask = mclGetUninitializedArray();
    mxArray * evalInfo = mclGetUninitializedArray();
    mxArray * bitMask = mclGetUninitializedArray();
    mclCopyArray(&fid);
    /*
     * % Read the (complex) data off the ADC and the Mdh (Siemens Numaris 4
     * % Measurement Data Header)
     * %
     * % [adc_data, mdh] = read_mdh_adc(fid)
     * 
     * % (MukundB, Tue Dec 4, 2001)
     * 
     * % First, read the mdh (measurement data header)
     * mdh.DMAlength = fread(fid, 1, 'ulong');
     */
    mlfIndexAssign(
      mdh,
      ".DMAlength",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray5_, NULL));
    /*
     * mdh.MeasUID = fread(fid, 1, 'long');
     */
    mlfIndexAssign(
      mdh,
      ".MeasUID",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray7_, NULL));
    /*
     * mdh.ScanCounter = fread(fid, 1, 'ulong');
     */
    mlfIndexAssign(
      mdh,
      ".ScanCounter",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray5_, NULL));
    /*
     * 
     * % time since 00:00 in 2.5 ms ticks
     * mdh.TimeStamp = fread(fid, 1, 'ulong');
     */
    mlfIndexAssign(
      mdh,
      ".TimeStamp",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray5_, NULL));
    /*
     * mdh.TimeStamp = 2.5 * mdh.TimeStamp; % now in milliseconds
     */
    mlfIndexAssign(
      mdh,
      ".TimeStamp",
      mclFeval(
        mclValueVarargout(),
        mlxMtimes,
        _mxarray9_,
        mclVe(mlfIndexRef(mclVsv(*mdh, "mdh"), ".TimeStamp")),
        NULL));
    /*
     * 
     * % time since last trigger in 2.5 ms ticks
     * mdh.PMUTimeStamp = fread(fid, 1, 'ulong');  
     */
    mlfIndexAssign(
      mdh,
      ".PMUTimeStamp",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray5_, NULL));
    /*
     * mdh.PMUTimeStamp = 2.5 * mdh.PMUTimeStamp; % now in milliseconds
     */
    mlfIndexAssign(
      mdh,
      ".PMUTimeStamp",
      mclFeval(
        mclValueVarargout(),
        mlxMtimes,
        _mxarray9_,
        mclVe(mlfIndexRef(mclVsv(*mdh, "mdh"), ".PMUTimeStamp")),
        NULL));
    /*
     * 
     * % EVALINFOMASK
     * bitMask = fread(fid, 1, 'ulong');
     */
    mlfAssign(
      &bitMask,
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray5_, NULL));
    /*
     * evalInfo = {'MDH_ACQEND', ...             %  1
     */
    mlfAssign(&evalInfo, _mxarray10_);
    /*
     * 'MDH_RTFEEDBACK', ...         %  2
     * 'MDH_HPFEEDBACK', ...         %  3
     * 'MDH_ONLINE', ...             %  4
     * 'MDH_OFFLINE', ...            %  5
     * 'Six', ...                    %  6
     * 'Seven', ...                  %  7
     * 'Eight', ...                  %  8
     * 'Nine', ...                   %  9
     * 'Ten', ...                    % 10
     * 'Eleven', ...                 % 11
     * 'Twelve', ...                 % 12
     * 'Thirteen', ...               % 13
     * 'Fourteen', ...               % 14
     * 'MDH_REFPHASESTABSCAN', ...   % 15
     * 'MDH_PHASESTABSCAN', ...      % 16
     * 'MDH_D3FFT', ...              % 17
     * 'MDH_SIGNREV', ...            % 18
     * 'MDH_PHASEFFT', ...           % 19
     * 'MDH_SWAPPED', ...            % 20
     * 'MDH_POSTSHAREDLINE', ...     % 21
     * 'MDH_PHASCOR', ...            % 22
     * 'MDH_ZEROLINE', ...           % 23
     * 'MDH_ZEROPARTITION', ...      % 24
     * 'MDH_REFLECT', ...            % 25
     * 'MDH_NOISEADJSCAN', ...       % 26
     * 'MDH_SHARENOW', ...           % 27
     * 'MDH_LASTMEASUREDLINE', ...   % 28
     * 'MDH_FIRSTSCANINSLICE', ...   % 29
     * 'MDH_LASTSCANINSLICE', ...    % 30
     * 'MDH_TREFFECTIVEBEGIN', ...   % 31
     * 'MDH_TREFFECTIVEEND'};        % 32
     * 
     * mask = zeros(32,1);
     */
    mlfAssign(&mask, mlfZeros(_mxarray76_, _mxarray4_, NULL));
    /*
     * for iii = 1:32
     */
    {
        int v_ = mclForIntStart(1);
        int e_ = mclForIntEnd(_mxarray76_);
        if (v_ > e_) {
            mlfAssign(&iii, _mxarray77_);
        } else {
            /*
             * mask(iii) = bitget(bitMask, iii);
             * end
             */
            for (; ; ) {
                mclIntArrayAssign1(
                  &mask,
                  mlfBitget(mclVv(bitMask, "bitMask"), mlfScalar(v_)),
                  v_);
                if (v_ == e_) {
                    break;
                }
                ++v_;
            }
            mlfAssign(&iii, mlfScalar(v_));
        }
    }
    /*
     * 
     * mdh.EvalInfoMask = mask;
     */
    mlfIndexAssign(mdh, ".EvalInfoMask", mclVsv(mask, "mask"));
    /*
     * mdh.EvalInfoMaskChar = evalInfo(find(mask));
     */
    mlfIndexAssign(
      mdh,
      ".EvalInfoMaskChar",
      mclArrayRef1(
        mclVsv(evalInfo, "evalInfo"),
        mlfFind(NULL, NULL, mclVv(mask, "mask"))));
    /*
     * mdh.EvalInfoMaskChar = mdh.EvalInfoMaskChar(:);
     */
    mlfIndexAssign(
      mdh,
      ".EvalInfoMaskChar",
      mlfIndexRef(
        mclVsv(*mdh, "mdh"), ".EvalInfoMaskChar(?)", mlfCreateColonIndex()));
    /*
     * 
     * mdh.SamplesInScan = fread(fid, 1, 'ushort');
     */
    mlfIndexAssign(
      mdh,
      ".SamplesInScan",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.UsedChannels = fread(fid, 1, 'ushort');
     */
    mlfIndexAssign(
      mdh,
      ".UsedChannels",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * 
     * mdh.LoopCounter.Line = fread(fid, 1, 'ushort');
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Line",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Acquisition = fread(fid, 1, 'ushort');  
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Acquisition",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Slice = fread(fid, 1, 'ushort');         
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Slice",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Partition = fread(fid, 1, 'ushort');  
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Partition",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Echo = fread(fid, 1, 'ushort');          
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Echo",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Phase = fread(fid, 1, 'ushort');         
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Phase",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Repetition = fread(fid, 1, 'ushort');  
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Repetition",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Set = fread(fid, 1, 'ushort');  
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Set",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Seg = fread(fid, 1, 'ushort');  
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Seg",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.LoopCounter.Free = fread(fid, 1, 'ushort');  
     */
    mlfIndexAssign(
      mdh,
      ".LoopCounter.Free",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * 
     * mdh.CutOffData.Pre = fread(fid, 1, 'ushort');  
     */
    mlfIndexAssign(
      mdh,
      ".CutOffData.Pre",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.CutOffData.Post = fread(fid, 1, 'ushort');  
     */
    mlfIndexAssign(
      mdh,
      ".CutOffData.Post",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * 
     * mdh.KSpaceCentreColumn = fread(fid, 1, 'ushort');
     */
    mlfIndexAssign(
      mdh,
      ".KSpaceCentreColumn",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * 
     * mdh.Dummy = fread(fid, 1, 'ushort');
     */
    mlfIndexAssign(
      mdh,
      ".Dummy",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.ReadOutOffcentre = fread(fid, 1, 'float');
     */
    mlfIndexAssign(
      mdh,
      ".ReadOutOffcentre",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray80_, NULL));
    /*
     * mdh.TimeSinceLastRF = fread(fid, 1, 'ulong');
     */
    mlfIndexAssign(
      mdh,
      ".TimeSinceLastRF",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray5_, NULL));
    /*
     * mdh.KSpaceCentreLineNo = fread(fid, 1, 'ushort');
     */
    mlfIndexAssign(
      mdh,
      ".KSpaceCentreLineNo",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * mdh.KSpaceCentrePartitionNo = fread(fid, 1, 'ushort');
     */
    mlfIndexAssign(
      mdh,
      ".KSpaceCentrePartitionNo",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray78_, NULL));
    /*
     * 
     * mdh.FreePara = fread(fid, 14, 'ushort');
     */
    mlfIndexAssign(
      mdh,
      ".FreePara",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray82_, _mxarray78_, NULL));
    /*
     * 
     * mdh.SD.SlicePosVec.Sag = fread(fid, 1, 'float');
     */
    mlfIndexAssign(
      mdh,
      ".SD.SlicePosVec.Sag",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray80_, NULL));
    /*
     * mdh.SD.SlicePosVec.Cor = fread(fid, 1, 'float');
     */
    mlfIndexAssign(
      mdh,
      ".SD.SlicePosVec.Cor",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray80_, NULL));
    /*
     * mdh.SD.SlicePosVec.Tra = fread(fid, 1, 'float');
     */
    mlfIndexAssign(
      mdh,
      ".SD.SlicePosVec.Tra",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray80_, NULL));
    /*
     * mdh.SD.Quaternion = fread(fid, 4, 'float');
     */
    mlfIndexAssign(
      mdh,
      ".SD.Quaternion",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray83_, _mxarray80_, NULL));
    /*
     * 
     * mdh.ChannelId = fread(fid, 1, 'ulong');
     */
    mlfIndexAssign(
      mdh,
      ".ChannelId",
      mlfFread(NULL, mclVa(fid, "fid"), _mxarray4_, _mxarray5_, NULL));
    /*
     * 
     * % Last, read the adc_data
     * adc_data = fread(fid, 2*mdh.SamplesInScan, 'float');
     */
    mlfAssign(
      &adc_data,
      mlfFread(
        NULL,
        mclVa(fid, "fid"),
        mclFeval(
          mclValueVarargout(),
          mlxMtimes,
          _mxarray84_,
          mclVe(mlfIndexRef(mclVsv(*mdh, "mdh"), ".SamplesInScan")),
          NULL),
        _mxarray80_,
        NULL));
    /*
     * adc_data = reshape(adc_data, 2, mdh.SamplesInScan); 
     */
    mlfAssign(
      &adc_data,
      mlfReshape(
        mclVv(adc_data, "adc_data"),
        _mxarray84_,
        mclVe(mlfIndexRef(mclVsv(*mdh, "mdh"), ".SamplesInScan")),
        NULL));
    /*
     * adc_data = complex(adc_data(1,:), adc_data(2,:));
     */
    mlfAssign(
      &adc_data,
      mlfNComplex(
        0,
        mclValueVarargout(),
        mclVe(
          mclArrayRef2(
            mclVsv(adc_data, "adc_data"), _mxarray4_, mlfCreateColonIndex())),
        mclVe(
          mclArrayRef2(
            mclVsv(adc_data, "adc_data"), _mxarray84_, mlfCreateColonIndex())),
        NULL));
    mclValidateOutput(adc_data, 1, nargout_, "adc_data", "read_mdh_adc");
    mclValidateOutput(*mdh, 2, nargout_, "mdh", "read_mdh_adc");
    mxDestroyArray(bitMask);
    mxDestroyArray(evalInfo);
    mxDestroyArray(mask);
    mxDestroyArray(iii);
    mxDestroyArray(fid);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return adc_data;
}
