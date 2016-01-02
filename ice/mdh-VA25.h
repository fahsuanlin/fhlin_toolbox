/*---------------------------------------------------------------------------*/
/*  Copyright (C) Siemens AG 1998  All Rights Reserved.  Confidential        */
/*---------------------------------------------------------------------------*/
/*
 * Project: NUMARIS/4
 *    File: Servers\MrMeasSrv\SeqIF\MDH\mdh.h@@\main\2
 * Version: 
 *  Author: JESCHE62
 *    Date: Do 06.06.2002 17:26 
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


/*--------------------------------------------------------------------------*/
/*  Definition of header parameters                                         */
/*--------------------------------------------------------------------------*/
#define MDH_NUMBEROFEVALINFOMASK   2
#define MDH_NUMBEROFICEPROGRAMPARA 4

/*--------------------------------------------------------------------------*/
/*  Definition of free header parameters (short)                            */
/*--------------------------------------------------------------------------*/
#define MDH_FREEHDRPARA  (4)

/*--------------------------------------------------------------------------*/
/*  Definition of EvalInfoMask:                                             */
/*--------------------------------------------------------------------------*/
//typedef MrBitField< MDH_NUMBEROFEVALINFOMASK * BITPERLONGS  > MdhBitField;
// original: const MdhBitField MDH_ONLINE (3);
// new     : #define MDH_ONLINE           (1<<3)

#define MDH_ACQEND            (1<<0)
#define MDH_RTFEEDBACK        (1<<1)
#define MDH_HPFEEDBACK        (1<<2)
#define MDH_ONLINE            (1<<3)
#define MDH_OFFLINE           (1<<4)

#define MDH_LASTSCANINCONCAT  (1<<8)       // Flag for last scan in concatination

#define MDH_RAWDATACORRECTION (1<<10)      // Correct the rawadata with the rawdata correction factor
#define MDH_LASTSCANINMEAS    (1<<11)      // Flag for last scan in measurement
#define MDH_SCANSCALEFACTOR   (1<<12)      // Flag for scan specific additional scale factor
#define MDH_2NDHADAMARPULSE   (1<<13)      // 2nd RF exitation of HADAMAR
#define MDH_REFPHASESTABSCAN  (1<<14)      // reference phase stabilization scan         
#define MDH_PHASESTABSCAN     (1<<15)      // phase stabilization scan
#define MDH_D3FFT             (1<<16)      // execute 3D FFT         
#define MDH_SIGNREV           (1<<17)      // sign reversal
#define MDH_PHASEFFT          (1<<18)      // execute phase fft     
#define MDH_SWAPPED           (1<<19)      // swapped phase/readout direction
#define MDH_POSTSHAREDLINE    (1<<20)      // shared line               
#define MDH_PHASCOR           (1<<21)      // phase correction data    
#define MDH_PATREFSCAN        (1<<22)      // additonal scan for PAT reference line/partition
#define MDH_PATREFANDIMASCAN  (1<<23)      // additonal scan for PAT reference line/partition that is also used as image scan
#define MDH_REFLECT           (1<<24)      // reflect line              
#define MDH_NOISEADJSCAN      (1<<25)      // noise adjust scan --> Not used in NUM4        
#define MDH_SHARENOW          (1<<26)      // all lines are acquired from the actual and previous e.g. phases
#define MDH_LASTMEASUREDLINE  (1<<27)      // indicates that the current line is the last measured line of all succeeding e.g. phases
#define MDH_FIRSTSCANINSLICE  (1<<28)      // indicates first scan in slice (needed for time stamps)
#define MDH_LASTSCANINSLICE   (1<<29)      // indicates  last scan in slice (needed for time stamps)
#define MDH_TREFFECTIVEBEGIN  (1<<30)      // indicates the begin time stamp for TReff (triggered measurement)
#define MDH_TREFFECTIVEEND    (1<<31)      // indicates the   end time stamp for TReff (triggered measurement)

#define DUMP_EVALINFOMASK(val)                             \
  if (val & MDH_ACQEND)            printf("MDH_ACQEND ");        \
  if (val & MDH_RTFEEDBACK)        printf("MDH_RTFEEDBACK ");    \
  if (val & MDH_HPFEEDBACK)        printf("MDH_HPFEEDBACK ");    \
  if (val & MDH_ONLINE)            printf("MDH_ONLINE ");        \
  if (val & MDH_OFFLINE)           printf("MDH_OFFLINE ");       \
  if (val & MDH_LASTSCANINCONCAT)  printf("MDH_LASTSCANINCONCAT ");   \
  if (val & MDH_RAWDATACORRECTION) printf("MDH_RAWDATACORRECTION ");  \
  if (val & MDH_LASTSCANINMEAS)    printf("MDH_LASTSCANINMEAS ");     \
  if (val & MDH_SCANSCALEFACTOR)   printf("MDH_SCANSCALEFACTOR ");    \
  if (val & MDH_2NDHADAMARPULSE)   printf("MDH_2NDHADAMARPULSE ");    \
  if (val & MDH_REFPHASESTABSCAN)  printf("MDH_REFPHASESTABSCAN ");   \
  if (val & MDH_PHASESTABSCAN)     printf("MDH_PHASESTABSCAN "); \
  if (val & MDH_D3FFT)             printf("MDH_D3FFT ");         \
  if (val & MDH_SIGNREV)           printf("MDH_SIGNREV ");       \
  if (val & MDH_PHASEFFT)          printf("MDH_PHASEFFT ");      \
  if (val & MDH_SWAPPED)           printf("MDH_SWAPPED ");       \
  if (val & MDH_POSTSHAREDLINE)    printf("MDH_POSTSHAREDLINE ");\
  if (val & MDH_PHASCOR)           printf("MDH_PHASCOR ");       \
  if (val & MDH_PATREFSCAN)        printf("MDH_PATREFSCAN ");    \
  if (val & MDH_PATREFANDIMASCAN)  printf("MDH_PATREFANDIMASCAN ");    \
  if (val & MDH_REFLECT)           printf("MDH_REFLECT ");       \
  if (val & MDH_NOISEADJSCAN)      printf("MDH_NOISEADJSCAN ");  \
  if (val & MDH_SHARENOW)          printf("MDH_SHARENOW ");      \
  if (val & MDH_LASTMEASUREDLINE)  printf("MDH_LASTMEASUREDLINE ");   \
  if (val & MDH_FIRSTSCANINSLICE)  printf("MDH_FIRSTSCANINSLICE ");   \
  if (val & MDH_LASTSCANINSLICE)   printf("MDH_LASTSCANINSLICE ");    \
  if (val & MDH_TREFFECTIVEBEGIN)  printf("MDH_TREFFECTIVEBEGIN ");   \
  if (val & MDH_TREFFECTIVEEND)    printf("MDH_TREFFECTIVEEND ");

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
  unsigned short  ushIda;                   /* IceDimension a index         */
  unsigned short  ushIdb;                   /* IceDimension b index         */
  unsigned short  ushIdc;                   /* IceDimension c index         */
  unsigned short  ushIdd;                   /* IceDimension d index         */
  unsigned short  ushIde;                   /* IceDimension e index         */
} sLoopCounter;                             /* sizeof : 28 byte             */

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
} sSliceData;                               /* sizeof : 28 byte             */

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
  unsigned long  aulEvalInfoMask[MDH_NUMBEROFEVALINFOMASK]; // evaluation info mask field           8
  unsigned short ushSamplesInScan;             // # of samples acquired in scan                     2
  unsigned short ushUsedChannels;              // # of channels used in scan                        2   =32
  sLoopCounter   sLC;                          // loop counters                                    28   =60
  sCutOffData    sCutOff;                      // cut-off values                                    4           
  unsigned short ushKSpaceCentreColumn;        // centre of echo                                    2
  unsigned short ushDummy;                     // for swapping                                      2
  float          fReadOutOffcentre;            // ReadOut offcenter value                           4
  unsigned long  ulTimeSinceLastRF;            // Sequence time stamp since last RF pulse           4
  unsigned short ushKSpaceCentreLineNo;        // number of K-space centre line                     2
  unsigned short ushKSpaceCentrePartitionNo;   // number of K-space centre partition                2
  unsigned short aushIceProgramPara[MDH_NUMBEROFICEPROGRAMPARA]; // free parameter for IceProgram   8   =88
  unsigned short aushFreePara[MDH_FREEHDRPARA];// free parameter                          4 * 2 =   8   
  sSliceData     sSD;                          // Slice Data                                       28   =124
  unsigned long	 ulChannelId;                  // channel Id must be the last parameter             4
} sMDH;                                        // total length: 32 * 32 Bit (128 Byte)            128

#endif   /* MDH_H */

/*---------------------------------------------------------------------------*/
/*  Copyright (C) Siemens AG 1998  All Rights Reserved.  Confidential        */
/*---------------------------------------------------------------------------*/
