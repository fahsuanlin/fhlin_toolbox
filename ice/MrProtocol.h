//
// This file provides a list of quantities to be read
// from the protocol file "MrProt.asc" that is generated
// along with "meas.out" when raw data are saved though
// the Siemens utility "Mate".
//

typedef struct
{
  long lBaseResolution;       // # of phase-encode steps in x
  long lPhaseEncodingLines;   // # of phase-encode steps in y
  long lSegments;             // # of segments
  long lNyPerSeg;             // # of y lines per segment (lPhaseEncodingLines/lNyPerSeg)
  long lFIDNav;               // # of FID navigator lines per excitation
  long lSlices;               // # of slices
  long lTimePoints;           // # of time points (derived from repetitions)
  long lDummyScans;           // # of dummy scans
  long lScanTimeSec;          // scan time for one shot (sec)
  long lTotalScanTimeSec;     // total scan time (sec)
  long lFlyBack;              // number of times lines are retraced (1 or 2)
  long lNumberOfChannels;     // # of receiver channels
  long lADCDuration;          // ADC duration (us) used for regridding
  long lRampTime;             // Ramp Time for x gradient (us) for regridding
  long lFlatTime;             // Flat Time for x gradient (us) for regridding
  long lRampMode;             // 0 = trapezoid, 1 = sinusoid
  long lTE;                   // echo time
  long lTR;                   // repetition time
  BOOL swap_PE;               // logical that is true for L->R (swap phase-encode)
  float fScaleFT;             // Scale factor for FT for conversion to short integers
  FILE *FileBshortOut;        // Output file for images.
  char BshortFileName[LEN_STR];        // Output file for images.
} PROT;

  PROT MrProt;
