/*---------------------------------------------------------------------------*/
/*  Copyright (C) Siemens AG 1998  All Rights Reserved.  Confidential        */
/*---------------------------------------------------------------------------*/
/*
 * Project: NUMARIS/4
 *    File: \n4\pkg\MrServers\MrMeasSrv\SeqIF\MDH\mdh.h@@\main\5
 * Version:
 *  Author: schostzf
 *    Date: Mon 18.08.2003 15:02
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
  unsigned long  ulFlagsAndDMALength;          // bit  0..27: DMA length [bytes]
                                               // bit 28..31: pci_rx enable flags                   4 byte
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
  unsigned short ushCoilSelect;                // Bit 0..3: CoilSelect                              2
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
