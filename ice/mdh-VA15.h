/*---------------------------------------------------------------------------*/
/*  Copyright (C) Siemens AG 1998  All Rights Reserved.  Confidential        */
/*---------------------------------------------------------------------------*/
/*
 * Project: NUMARIS/4
 *    File: comp\Measurement\mdh.h@@\main\4a15a\1
 * Version: 
 *  Author: KLUGE
 *    Date: Tue 12.06.2001 17:56 
 *
 *    Lang: C
 *
 * Descrip: measurement data header
 *
 *                      ATTENTION
 *                      ---------
 *
 *  If you change the measurement data header, you have to take care that
 *  long variables start at an address which is aligned for longs. If you add
 *  a short variable, then add two shorts from the short array or use the 
 *  second one from the previous change (called "dummy", if only one was added and
 *  no dummy exists).
 *  Then you have to extend the swap-method from MdhProxy.
 *  This is necessary, because a 32 bit swaped is executed from MPCU to image
 *  calculator. 
 *  Additional, you have to change the dump method from libIDUMP/IDUMPRXUInstr.cpp.
 *
 * Functns: n.a.
 *
 *---------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* Include control                                                          */
/*--------------------------------------------------------------------------*/
#ifndef MDH_H
#define MDH_H


/***************************************************************************\
*
*  Definition of constants
*
*  Note: the #define SIZEOF_sRXU_INSTR_ACQ in the header file
*        Measurement/MC4C40/RXU/DSP_RXU.h has to be adapted manually
*        whenever the size of the measurement data header is changed!
*        Due to an imcompatibiliy between the host compiler and the DSP
*        compiler, this cannot be done automatically.
*
\****************************************************************************/

/*--------------------------------------------------------------------------*/
/*  Definition of free header parameters (short)                            */
/*--------------------------------------------------------------------------*/
#define MDH_FREEHDRPARA  (14)

/*--------------------------------------------------------------------------*/
/*  Definition of EvalInfoMask: First 16 bits for Ice-COP                   */
/*                          Second 16 bits free for application.            */
/*--------------------------------------------------------------------------*/
#define	MDH_ACQEND           0x00000001
#define MDH_RTFEEDBACK       0x00000002
#define MDH_HPFEEDBACK       0x00000004
#define	MDH_ONLINE           0x00000008
#define	MDH_OFFLINE          0x00000010

#define MDH_PPAEXTRAREFSCAN  0x00002000       // additonal scan for PPA reference line/partition
#define MDH_REFPHASESTABSCAN 0x00004000       // reference phase stabilization scan         
#define MDH_PHASESTABSCAN    0x00008000       // phase stabilization scan
#define MDH_D3FFT            0x00010000       // execute 3D FFT         
#define MDH_SIGNREV          0x00020000       // sign reversal
#define MDH_PHASEFFT         0x00040000       // execute phase fft     
#define MDH_SWAPPED          0x00080000       // swapped phase/readout direction
#define MDH_POSTSHAREDLINE   0x00100000       // shared line               
#define MDH_PHASCOR          0x00200000       // phase correction data    
#define MDH_ZEROLINE         0x00400000       // k-Space centre line     
#define MDH_ZEROPARTITION    0x00800000       // k-Space centre partition 
#define MDH_REFLECT          0x01000000       // reflect line              
#define MDH_NOISEADJSCAN     0x02000000       // noise adjust scan --> Not used in NUM4        
#define MDH_SHARENOW         0x04000000       // all lines are acquired from the actual and previous e.g. phases
#define MDH_LASTMEASUREDLINE 0x08000000       // indicates that the current line is the last measured line of all succeeding e.g. phases
#define MDH_FIRSTSCANINSLICE 0x10000000       // indicates first scan in slice (needed for time stamps)
#define MDH_LASTSCANINSLICE  0x20000000       // indicates  last scan in slice (needed for time stamps)
#define MDH_TREFFECTIVEBEGIN 0x40000000       // indicates the begin time stamp for TReff (triggered measurement)
#define MDH_TREFFECTIVEEND   0x80000000       // indicates the   end time stamp for TReff (triggered measurement)

// Max define 0x80000000

#define DUMP_EVALINFOMASK(stream, val)                            \
  if (val & MDH_ACQEND)           stream << "MDH_ACQEND ";        \
  if (val & MDH_RTFEEDBACK)       stream << "MDH_RTFEEDBACK ";    \
  if (val & MDH_HPFEEDBACK)       stream << "MDH_HPFEEDBACK ";    \
  if (val & MDH_ONLINE)           stream << "MDH_ONLINE ";        \
  if (val & MDH_OFFLINE)          stream << "MDH_OFFLINE ";       \
  if (val & MDH_PPAEXTRAREFSCAN ) stream << "MDH_PPAEXTRAREFSCAN ";\
  if (val & MDH_REFPHASESTABSCAN) stream << "MDH_REFPHASESTABSCAN ";\
  if (val & MDH_PHASESTABSCAN)    stream << "MDH_PHASESTABSCAN "; \
  if (val & MDH_D3FFT)            stream << "MDH_D3FFT ";         \
  if (val & MDH_SIGNREV)          stream << "MDH_SIGNREV ";       \
  if (val & MDH_PHASEFFT)         stream << "MDH_PHASEFFT ";      \
  if (val & MDH_SWAPPED)          stream << "MDH_SWAPPED ";       \
  if (val & MDH_POSTSHAREDLINE)   stream << "MDH_POSTSHAREDLINE ";\
  if (val & MDH_PHASCOR)          stream << "MDH_PHASCOR ";       \
  if (val & MDH_ZEROLINE)         stream << "MDH_ZEROLINE ";      \
  if (val & MDH_ZEROPARTITION)    stream << "MDH_ZEROPARTITION "; \
  if (val & MDH_REFLECT)          stream << "MDH_REFLECT ";       \
  if (val & MDH_NOISEADJSCAN)     stream << "MDH_NOISEADJSCAN ";  \
  if (val & MDH_SHARENOW)         stream << "MDH_SHARENOW ";      \
  if (val & MDH_LASTMEASUREDLINE) stream << "MDH_LASTMEASUREDLINE ";\
  if (val & MDH_FIRSTSCANINSLICE) stream << "MDH_FIRSTSCANINSLICE ";\
  if (val & MDH_LASTSCANINSLICE)  stream << "MDH_LASTSCANINSLICE "; \
  if (val & MDH_TREFFECTIVEBEGIN) stream << "MDH_TREFFECTIVEBEGIN ";\
  if (val & MDH_TREFFECTIVEEND)   stream << "MDH_TREFFECTIVEEND ";

/*--------------------------------------------------------------------------*/
/* Definition of time stamp tick interval/frequency                         */
/* (used for ulTimeStamp and ulPMUTimeStamp                                 */
/*--------------------------------------------------------------------------*/
#define RXU_TIMER_INTERVAL  (2500000)     /* data header timer interval [ns]*/
#define RXU_TIMER_FREQUENCY (400)         /* data header timer frequency[Hz]*/

/*--------------------------------------------------------------------------*/
/* Definition of loop counter structure                                     */
/* Note: any changes of this structure affect the corresponding swapping    */
/*       method of the measurement data header proxy class (MdhProxy)       */
/*--------------------------------------------------------------------------*/
typedef struct
{
  unsigned short  ushLine;                  /* line index                   */
  unsigned short  ushAcquisition;           /* acquisition index            */
  unsigned short  ushSlice;                 /* slice index                  */
  unsigned short  ushPartition;             /* partition index              */
  unsigned short  ushEcho;                  /* echo index                   */	
  unsigned short  ushPhase;                 /* phase index                  */
  unsigned short  ushRepetition;            /* measurement repeat index     */
  unsigned short  ushSet;                   /* set index                    */
  unsigned short  ushSeg;                   /* segment index  (for TSE)     */
  unsigned short  ushFree;                  /* free loop counter            */
} sLoopCounter;                             /* sizeof : 20 B                */

/*--------------------------------------------------------------------------*/
/*  Definition of slice vectors                                             */
/*--------------------------------------------------------------------------*/

typedef struct
{
  float  flSag;
  float  flCor;
  float  flTra;
} sVector;


typedef struct
{
  sVector  sSlicePosVec;                    /* slice position vector        */
  float    aflQuaternion[4];                /* rotation matrix as quaternion*/
} sSliceData;                               /* sizeof : 28 B                */

/*--------------------------------------------------------------------------*/
/*  Definition of cut-off data                                              */
/*--------------------------------------------------------------------------*/
typedef struct
{
  unsigned short  ushPre;               /* write ushPre zeros at line start */
  unsigned short  ushPost;              /* write ushPost zeros at line end  */
} sCutOffData;


/*--------------------------------------------------------------------------*/
/*  Definition of measurement data header                                   */
/*--------------------------------------------------------------------------*/
typedef struct
{
  unsigned long  ulDMALength;                  // DMA length [bytes] must be                        4 byte                                               // first parameter                        
  long           lMeasUID;                     // measurement user ID                               4     
  unsigned long  ulScanCounter;                // scan counter [1...]                               4
  unsigned long  ulTimeStamp;                  // time stamp [2.5 ms ticks since 00:00]             4
  unsigned long  ulPMUTimeStamp;               // PMU time stamp [2.5 ms ticks since last trigger]  4
  unsigned long  ulEvalInfoMask;               // evaluation info mask                              4
  unsigned short ushSamplesInScan;             // # of samples acquired in scan                     2
  unsigned short ushUsedChannels;              // # of channels used in scan                        2
  sLoopCounter   sLC;                          // loop counters                                    20
  sCutOffData    sCutOff;                      // cut-off values                                    4           
  unsigned short ushKSpaceCentreColumn;        // centre of echo                                    2
  unsigned short ushDummy;                     // for swapping                                      2
  float          fReadOutOffcentre;            // ReadOut offcenter value                           4
  unsigned long  ulTimeSinceLastRF;            // Sequence time stamp since last RF pulse           4
  unsigned short ushKSpaceCentreLineNo;        // number of K-space centre line                     2
  unsigned short ushKSpaceCentrePartitionNo;   // number of K-space centre partition                2
  unsigned short aushFreePara[MDH_FREEHDRPARA];// free parameter                         14 * 2 =  32
 sSliceData     sSD;                          // Slice Data                                       28
  unsigned long	 ulChannelId;                  // channel Id must be the last parameter             4
} sMDH;                                        // total length: 32 * 32 Bit (128 Byte)            128

#endif   /* MDH_H */

/*---------------------------------------------------------------------------*/
/*  Copyright (C) Siemens AG 1998  All Rights Reserved.  Confidential        */
/*---------------------------------------------------------------------------*/
