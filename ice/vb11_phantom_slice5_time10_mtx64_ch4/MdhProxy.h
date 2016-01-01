//	-----------------------------------------------------------------------------
//	  Copyright (C) Siemens AG 1998  All Rights Reserved.
//	-----------------------------------------------------------------------------
//
//	 Project: NUMARIS/4
//	    File: \n4\pkg\MrServers\MrMeasSrv\SeqIF\MDH\MdhProxy.h@@\main\4b11a\8
//	 Version:
//	  Author: schostzf
//	    Date: Mon 18.08.2003 15:02
//
//	    Lang: C++
//
//	 Descrip: MR::Measurement::SctToIce
//
//	 Classes:
//
//	-----------------------------------------------------------------------------

#ifndef MdhProxy_h
#define MdhProxy_h 1


//-----------------------------------------------------------------------------
// Includes
//-----------------------------------------------------------------------------
#ifdef VXWORKS
  #include "vxworks.h"
#elif !defined MRVISTA
#pragma warning(disable : 4237)
#include "csacommon\csadefs.h"
#endif

#ifdef MRVISTA
#include <iomanip>
#include <cmath>
using std::endl;
#endif

#include "MrServers/MrMeasSrv/SeqIF/MDH/mdh.h"              // sMDH
#include "MrServers/MrMeasSrv/MeasUtils/MrBitField.h"       // MrBitField

#ifndef MRVISTA
#include <iostream.h>
#include <iomanip.h>
#include <string.h>
#include <math.h>
#endif

#define MDH_QW  0
#define MDH_QX  1
#define MDH_QY  2
#define MDH_QZ  3

#ifdef MRVISTA
#define STREAM_HEX_W32_NL_XX(VAR)    std::setw(32) <<  #VAR << " = 0x" <<  std::hex << std::setw(8) << std::setfill ('0') << VAR << std::dec << std::setfill (' ') << " \n"
#define STREAM_DEC_W32_NL_XX(VAR)    std::setw(32) << #VAR << " = " << VAR << " \n"
#else
#define STREAM_HEX_W32_NL_XX(VAR)    setw(32) <<  #VAR << " = 0x" <<  hex << setw(8) << setfill ('0') << VAR << dec << setfill (' ') << " \n"
#define STREAM_DEC_W32_NL_XX(VAR)    setw(32) << #VAR << " = " << VAR << " \n"
#endif

//----------------------------------------------------------------------------
// switch import-export control on (Note: we need this special mechanism for
// compilation for the VxWorks operating system!)                                         
//----------------------------------------------------------------------------
#ifdef BUILD_MdhProxy
  #define __OWNER
#endif





//##ModelId=3AFAAF7801CF
typedef MrBitField< MDH_NUMBEROFEVALINFOMASK * BITPERLONGS  > MdhBitField;


/***************************************************************************\
*
*  Definition of constants
*
*  Note: the #define SIZEOF_sRXU_INSTR_ACQ in the header file
*        MrServers/MrHardwareControl/MC4C40/RXU/DSP_RXU.h has to be adapted manually
*        whenever the size of the measurement data header is changed!
*        Due to an imcompatibiliy between the host compiler and the DSP
*        compiler, this cannot be done automatically.
*
\****************************************************************************/

/*--------------------------------------------------------------------------*/
/*  Definition of EvalInfoMask:                                             */
/*--------------------------------------------------------------------------*/
const MdhBitField MDH_ACQEND            ((unsigned long)0);
const MdhBitField MDH_RTFEEDBACK        (1);
const MdhBitField MDH_HPFEEDBACK        (2);
const MdhBitField MDH_ONLINE            (3);
const MdhBitField MDH_OFFLINE           (4);

const MdhBitField MDH_LASTSCANINCONCAT  (8);       // Flag for last scan in concatination

const MdhBitField MDH_RAWDATACORRECTION (10);      // Correct the rawadata with the rawdata correction factor
const MdhBitField MDH_LASTSCANINMEAS    (11);      // Flag for last scan in measurement
const MdhBitField MDH_SCANSCALEFACTOR   (12);      // Flag for scan specific additional scale factor
const MdhBitField MDH_2NDHADAMARPULSE   (13);      // 2nd RF exitation of HADAMAR
const MdhBitField MDH_REFPHASESTABSCAN  (14);      // reference phase stabilization scan         
const MdhBitField MDH_PHASESTABSCAN     (15);      // phase stabilization scan
const MdhBitField MDH_D3FFT             (16);      // execute 3D FFT         
const MdhBitField MDH_SIGNREV           (17);      // sign reversal
const MdhBitField MDH_PHASEFFT          (18);      // execute phase fft     
const MdhBitField MDH_SWAPPED           (19);      // swapped phase/readout direction
const MdhBitField MDH_POSTSHAREDLINE    (20);      // shared line               
const MdhBitField MDH_PHASCOR           (21);      // phase correction data    
const MdhBitField MDH_PATREFSCAN        (22);      // additonal scan for PAT reference line/partition
const MdhBitField MDH_PATREFANDIMASCAN  (23);      // additonal scan for PAT reference line/partition that is also used as image scan
const MdhBitField MDH_REFLECT           (24);      // reflect line              
const MdhBitField MDH_NOISEADJSCAN      (25);      // noise adjust scan --> Not used in NUM4        
const MdhBitField MDH_SHARENOW          (26);      // all lines are acquired from the actual and previous e.g. phases
const MdhBitField MDH_LASTMEASUREDLINE  (27);      // indicates that the current line is the last measured line of all succeeding e.g. phases
const MdhBitField MDH_FIRSTSCANINSLICE  (28);      // indicates first scan in slice (needed for time stamps)
const MdhBitField MDH_LASTSCANINSLICE   (29);      // indicates  last scan in slice (needed for time stamps)
const MdhBitField MDH_TREFFECTIVEBEGIN  (30);      // indicates the begin time stamp for TReff (triggered measurement)
const MdhBitField MDH_TREFFECTIVEEND    (31);      // indicates the   end time stamp for TReff (triggered measurement)

//-----------------------------------------------------------------------------
// Definition of EvalInfoMask for COP:
//-----------------------------------------------------------------------------
#define	MDH_COP_ACQEND            0x00000001
#define MDH_COP_RTFEEDBACK        0x00000002
#define MDH_COP_HPFEEDBACK        0x00000004
#define	MDH_COP_ONLINE            0x00000008
#define	MDH_COP_OFFLINE           0x00000010

//-----------------------------------------------------------------------------
// Defines for the misc value
//-----------------------------------------------------------------------------
#define MDH_COILSELECT_MSK   0x0000000f


#define DUMP_EVALINFOMASK(stream, val)                             \
  if (val & MDH_ACQEND)            stream << "MDH_ACQEND ";        \
  if (val & MDH_RTFEEDBACK)        stream << "MDH_RTFEEDBACK ";    \
  if (val & MDH_HPFEEDBACK)        stream << "MDH_HPFEEDBACK ";    \
  if (val & MDH_ONLINE)            stream << "MDH_ONLINE ";        \
  if (val & MDH_OFFLINE)           stream << "MDH_OFFLINE ";       \
  if (val & MDH_LASTSCANINCONCAT)  stream << "MDH_LASTSCANINCONCAT ";   \
  if (val & MDH_RAWDATACORRECTION) stream << "MDH_RAWDATACORRECTION ";  \
  if (val & MDH_LASTSCANINMEAS)    stream << "MDH_LASTSCANINMEAS ";     \
  if (val & MDH_SCANSCALEFACTOR)   stream << "MDH_SCANSCALEFACTOR ";    \
  if (val & MDH_2NDHADAMARPULSE)   stream << "MDH_2NDHADAMARPULSE ";    \
  if (val & MDH_REFPHASESTABSCAN)  stream << "MDH_REFPHASESTABSCAN ";   \
  if (val & MDH_PHASESTABSCAN)     stream << "MDH_PHASESTABSCAN "; \
  if (val & MDH_D3FFT)             stream << "MDH_D3FFT ";         \
  if (val & MDH_SIGNREV)           stream << "MDH_SIGNREV ";       \
  if (val & MDH_PHASEFFT)          stream << "MDH_PHASEFFT ";      \
  if (val & MDH_SWAPPED)           stream << "MDH_SWAPPED ";       \
  if (val & MDH_POSTSHAREDLINE)    stream << "MDH_POSTSHAREDLINE ";\
  if (val & MDH_PHASCOR)           stream << "MDH_PHASCOR ";       \
  if (val & MDH_PATREFSCAN)        stream << "MDH_PATREFSCAN ";    \
  if (val & MDH_PATREFANDIMASCAN)  stream << "MDH_PATREFANDIMASCAN ";    \
  if (val & MDH_REFLECT)           stream << "MDH_REFLECT ";       \
  if (val & MDH_NOISEADJSCAN)      stream << "MDH_NOISEADJSCAN ";  \
  if (val & MDH_SHARENOW)          stream << "MDH_SHARENOW ";      \
  if (val & MDH_LASTMEASUREDLINE)  stream << "MDH_LASTMEASUREDLINE ";   \
  if (val & MDH_FIRSTSCANINSLICE)  stream << "MDH_FIRSTSCANINSLICE ";   \
  if (val & MDH_LASTSCANINSLICE)   stream << "MDH_LASTSCANINSLICE ";    \
  if (val & MDH_TREFFECTIVEBEGIN)  stream << "MDH_TREFFECTIVEBEGIN ";   \
  if (val & MDH_TREFFECTIVEEND)    stream << "MDH_TREFFECTIVEEND ";




// Class MdhProxy
//##ModelId=35B06919028E
class MdhProxy 
{

  public:
    //Returns the number of the used coilselect.
    //(Counting starts with zero.)
    //##ModelId=3F407F6F0117
    unsigned short getUsedCoilSelect() const
    {
      return (m_mdh->ushCoilSelect & MDH_COILSELECT_MSK);
    }

    //Sets the number of the used coilselect.
    //(Counting starts with zero.)
    //##ModelId=3F407FA60293
    void setUsedCoilSelect(const unsigned short ushCoilSelect)
    {
      m_mdh->ushCoilSelect = (m_mdh->ushCoilSelect & ~MDH_COILSELECT_MSK)  | (ushCoilSelect & MDH_COILSELECT_MSK);
    }

    //Returns total DMA length as sum of the DMA lengths of 
    //all pci_rx receivers on 1 MRIR.
    //##ModelId=3DFD963D024A
     unsigned long getTotalDMALength() const
     {
        //-------------------------------------------------------------------------
        // TODO????: A new element ulTotalDMALength must be added into sMDH
        //           and its value must be returned here.
        //-------------------------------------------------------------------------
        return getDMALength();
     }

    //Set total DMA length. Total DMA length should be the 
    //sum of the DMA lengths of all pci_rx receivers on 1 
    //MRIR.
    //##ModelId=3DFD96570189
     void setTotalDMALength(const unsigned long ulDMALength)
     {
        //-------------------------------------------------------------------------
        // TODO????: A new element ulTotalDMALength must be added into sMDH
        //           and its value must be set here.
        //-------------------------------------------------------------------------
        setDMALength(ulDMALength);
     }


	//##ModelId=35B07D3F0046
      MdhProxy (sMDH *mdhStartAddr)
          : m_EvalInfoMask(mdhStartAddr->aulEvalInfoMask)
      {
          m_mdh = mdhStartAddr;
      }

	//##ModelId=3DFD986301FB
      virtual ~MdhProxy() { };

  //##ModelId=3DFD98630237
      MdhProxy & operator=(const MdhProxy &right)
      {
        if (this != &right)
        {
          memcpy((void *)m_mdh, right.m_mdh, sizeof(*m_mdh));
          m_EvalInfoMask = right.m_EvalInfoMask;
        }
        return (*this);
      }

	//##ModelId=3EFFF4050085
      sMDH * getMdhData() const
      {
        return (m_mdh);
      }

	//##ModelId=3506D228037A
      unsigned long getDMALength () const
      {
        return (m_mdh->ulFlagsAndDMALength) & 0x0FFFFFFFL;
      }

	//##ModelId=35B4847B0376
      void setDMALength (const unsigned long ulDMALength)
      {
        m_mdh->ulFlagsAndDMALength = (ulDMALength & 0x0FFFFFFFL);
      }

	//##ModelId=3506D252019A
      long getMeasUID () const
      {
        return m_mdh->lMeasUID;
      }

	//##ModelId=35B48F9601D0
      void setMeasUID (const long lMeasUID)
      {
        m_mdh->lMeasUID = lMeasUID;
      }

	//##ModelId=3506D27B0207
      unsigned long getScanCounter () const
      {
        return m_mdh->ulScanCounter;
      }

	//##ModelId=35B48FB2039D
      void setScanCounter (const unsigned long ulScanCounter)
      {
        m_mdh->ulScanCounter = ulScanCounter;
      }

	//##ModelId=3506D29F03C1
      unsigned long getTimeStamp () const
      {
        return m_mdh->ulTimeStamp;
      }

	//##ModelId=36F3504B0049
      void setTimeStamp (const unsigned long ulTimeStamp)
      {
        m_mdh->ulTimeStamp = ulTimeStamp;
      }

	//##ModelId=35B48FC302E3
      void setPMUTimeStamp (const unsigned long ulPMUTimeStamp)
      {
        m_mdh->ulPMUTimeStamp = ulPMUTimeStamp;
      }

	//##ModelId=36F3504A0228
      unsigned long getPMUTimeStamp () const
      {
        return m_mdh->ulPMUTimeStamp;
      }

	//##ModelId=35053724006E
      MdhBitField getEvalInfoMask () const
      {
        return m_EvalInfoMask;
      }

	//##ModelId=35B48FEA03BB
      void setEvalInfoMask (const MdhBitField &rEvalInfoMask)
      {
        m_EvalInfoMask = rEvalInfoMask;
      }

	//##ModelId=3B3063A6001A
      unsigned long getEvalInfoMaskCop () const
      {
        return m_EvalInfoMask.getLong(0);
      }

	//##ModelId=3619FDFE005A
      void addToEvalInfoMask (const MdhBitField &rEvalInfoMask)
      {
        m_EvalInfoMask |= rEvalInfoMask;
      }

	//##ModelId=3619FE2300FD
      void deleteFromEvalInfoMask (const MdhBitField &rEvalInfoMask)
      {
        m_EvalInfoMask &= ~rEvalInfoMask;
      }

	//##ModelId=365BC8C40310
      void toggleEvalInfoMask (const MdhBitField &rEvalInfoMask)
      {
        m_EvalInfoMask ^= rEvalInfoMask;
      }

	//##ModelId=35069A2300C5
      unsigned short getNoOfColumns () const
      {
        return m_mdh->ushSamplesInScan;
      }

	//##ModelId=35B48FFA03B4
      void setNoOfColumns (const unsigned short ushSamplesInScan)
      {
        m_mdh->ushSamplesInScan = ushSamplesInScan;
      }

	//##ModelId=350699280269
      unsigned short getNoOfChannels () const
      {
        return m_mdh->ushUsedChannels;
      }

	//##ModelId=35B4902603B8
      void setNoOfChannels (const unsigned short ushUsedChannels)
      {
        m_mdh->ushUsedChannels = ushUsedChannels;
      }

	//##ModelId=35B2D7CE02C5
      sSliceData getSliceData () const
      {
        return m_mdh->sSD;
      }

	//##ModelId=3614F3500370
      void setSliceData (const sSliceData &rSliceData)
      {
        memcpy(&m_mdh->sSD, &rSliceData, sizeof(m_mdh->sSD));
      }

	//##ModelId=3505369400D5
      unsigned short getClin () const
      {
        return m_mdh->sLC.ushLine;
      }

	//##ModelId=35B4905A0222
      void setClin (const unsigned short ushLine)
      {
        m_mdh->sLC.ushLine = ushLine;
      }

	//##ModelId=35B715D70191
      unsigned short getCacq (void ) const
      {
        return m_mdh->sLC.ushAcquisition;
      }

	//##ModelId=35B715F30231
      void setCacq (const unsigned short ushAcquisition)
      {
        m_mdh->sLC.ushAcquisition = ushAcquisition;
      }

	//##ModelId=3505315303B6
      unsigned short getCslc () const
      {
        return m_mdh->sLC.ushSlice;
      }

	//##ModelId=35B49076027C
      void setCslc (const unsigned short ushSlice)
      {
        m_mdh->sLC.ushSlice = ushSlice;
      }

	//##ModelId=355B2CCB0202
      unsigned short getCpar () const
      {
        return m_mdh->sLC.ushPartition;
      }

	//##ModelId=35B490900298
      void setCpar (const unsigned short ushPartition)
      {
        m_mdh->sLC.ushPartition = ushPartition;
      }

	//##ModelId=355B2D3B027C
      unsigned short getCeco () const
      {
        return m_mdh->sLC.ushEcho;
      }

	//##ModelId=35B490A40387
      void setCeco (const unsigned short ushEcho)
      {
        m_mdh->sLC.ushEcho = ushEcho;
      }

	//##ModelId=355B2D710215
      unsigned short getCphs () const
      {
        return m_mdh->sLC.ushPhase;
      }

	//##ModelId=35B490B102B3
      void setCphs (const unsigned short ushPhase)
      {
        m_mdh->sLC.ushPhase = ushPhase;
      }

	//##ModelId=355B2D710305
      unsigned short getCrep () const
      {
        return m_mdh->sLC.ushRepetition;
      }

	//##ModelId=35B490BF014B
      void setCrep (const unsigned short ushRepetition)
      {
        m_mdh->sLC.ushRepetition = ushRepetition;
      }

	//##ModelId=355B2D7103CE
      unsigned short getCset () const
      {
        return m_mdh->sLC.ushSet;
      }

	//##ModelId=35B490CC0352
      void setCset (const unsigned short ushSet)
      {
        m_mdh->sLC.ushSet = ushSet;
      }

	//##ModelId=355B2D7200B8
      unsigned short getCseg () const
      {
        return m_mdh->sLC.ushSeg;
      }

	//##ModelId=35B490D60158
      void setCseg (const unsigned short ushSeg)
      {
        m_mdh->sLC.ushSeg = ushSeg;
      }

	//##ModelId=35B71619025E
      unsigned short getCida () const
      {
        return m_mdh->sLC.ushIda;
      }

  //##ModelId=35B7162402F0
      void setCida (const unsigned short ushValue)
      {
        m_mdh->sLC.ushIda = ushValue;
      }

	//##ModelId=3AF6BCAA0224
      unsigned short getCidb () const
      {
        return m_mdh->sLC.ushIdb;
      }

	//##ModelId=3AF6BCAA024C
      void setCidb (const unsigned short ushValue)
      {
        m_mdh->sLC.ushIdb = ushValue;
      }

	//##ModelId=3AF6BCAE019D
      unsigned short getCidc () const
      {
        return m_mdh->sLC.ushIdc;
      }

	//##ModelId=3AF6BCAE01CF
      void setCidc (const unsigned short ushValue)
      {
        m_mdh->sLC.ushIdc = ushValue;
      }

	//##ModelId=3AF6BCB00363
      unsigned short getCidd () const
      {
        return m_mdh->sLC.ushIdd;
      }

	//##ModelId=3AF6BCB0038B
      void setCidd (const unsigned short ushValue)
      {
        m_mdh->sLC.ushIdd = ushValue;
      }

	//##ModelId=3AF6BCB20211
      unsigned short getCide () const
      {
        return m_mdh->sLC.ushIde;
      }

	//##ModelId=3AF6BCB20243
      void setCide (const unsigned short ushValue)
      {
        m_mdh->sLC.ushIde = ushValue;
      }

  //##ModelId=35E686560358
      unsigned short getPreCutOff (void ) const
      {
        return m_mdh->sCutOff.ushPre;
      }

	//##ModelId=35E686C90213
      void setPreCutOff (const unsigned short ushPreCutOff)
      {
        m_mdh->sCutOff.ushPre = ushPreCutOff;
      }

	//##ModelId=35E6867A007F
      unsigned short getPostCutOff (void ) const
      {
        return m_mdh->sCutOff.ushPost;
      }

	//##ModelId=35E686CC0145
      void setPostCutOff (const unsigned short ushPostCutOff)
      {
        m_mdh->sCutOff.ushPost = ushPostCutOff;
      }

    //Obtains the free parameter at the given index. 
    //RETURN: false if index is out of range, true otherwise
	//##ModelId=37B7D7040140
      bool getFreeParameterByIndex (unsigned short index, 	//  (IN): index into array of free parameters
      unsigned short &value	//  (OUT): value at index
      ) const
      {
        if(index < MDH_FREEHDRPARA)
        {
          value  = m_mdh->aushFreePara[index];
          return true;
        }
        else
          return false;  
      }

    //Sets the free parameter at the given index. 
    //RETURN: false if index is out of range, true otherwise
	//##ModelId=37B7DB9F0330
      bool setFreeParameterByIndex (unsigned short index, 	//  (IN): index into array of free parameters
      unsigned short value	//  (IN): value at index
      ) const
      {
        if(index < MDH_FREEHDRPARA)
        {
          m_mdh->aushFreePara[index] = value;
          return true;
        }
        else
          return false;  
      }

	//##ModelId=365BCB1E0293
      unsigned long getKSpaceCentreColumn (void ) const
      {
        return (unsigned long) m_mdh->ushKSpaceCentreColumn;
      }

	//##ModelId=365BCB4B003F
      void setKSpaceCentreColumn (const unsigned short ushCentreColumn)
      {
        m_mdh->ushKSpaceCentreColumn = ushCentreColumn;
      }

	//##ModelId=36700B520393
      bool isKSpaceCentreLine (void ) const
      {
        return ((getClin() == getKSpaceCentreLineNo()) && (getClin() != 0));
      }

	//##ModelId=36700B7C01C7
      bool isKSpaceCentrePartition (void ) const
      {
        return ((getCpar() == getKSpaceCentrePartitionNo()) && (getCpar() != 0));
      }

	//##ModelId=35B492E80055
      void swap (void )
      {
        //---------------------------------------------------------------------------
        // The measurement data header will be automatically swapped on the data
        // acquisition side. Since that is a 32 bit swapping (which does not take
        // into account the actual data structure), we need to "pre-swapp" all
        // parameter which are not 32 bit wide.
        //---------------------------------------------------------------------------
        swapPairOfShorts(m_mdh->ushSamplesInScan, m_mdh->ushUsedChannels);

        swapPairOfShorts(m_mdh->sLC.ushLine,       m_mdh->sLC.ushAcquisition);
        swapPairOfShorts(m_mdh->sLC.ushSlice,      m_mdh->sLC.ushPartition);
        swapPairOfShorts(m_mdh->sLC.ushEcho,       m_mdh->sLC.ushPhase);
        swapPairOfShorts(m_mdh->sLC.ushRepetition, m_mdh->sLC.ushSet);
        swapPairOfShorts(m_mdh->sLC.ushSeg,        m_mdh->sLC.ushIda);
        swapPairOfShorts(m_mdh->sLC.ushIdb,        m_mdh->sLC.ushIdc);
        swapPairOfShorts(m_mdh->sLC.ushIdd,        m_mdh->sLC.ushIde);

        swapPairOfShorts(m_mdh->sCutOff.ushPre, m_mdh->sCutOff.ushPost);
            
        swapPairOfShorts(m_mdh->ushKSpaceCentreColumn, m_mdh->ushCoilSelect);
            
        swapPairOfShorts(m_mdh->ushKSpaceCentreLineNo, m_mdh->ushKSpaceCentrePartitionNo);

        int iLoop = 0;
        for (iLoop = 0; iLoop < MDH_NUMBEROFICEPROGRAMPARA; iLoop += 2)
        {
            swapPairOfShorts(m_mdh->aushIceProgramPara[iLoop], m_mdh->aushIceProgramPara[iLoop + 1]);
        }
            
        for (iLoop = 0; iLoop < MDH_FREEHDRPARA; iLoop += 2)
        {
            swapPairOfShorts(m_mdh->aushFreePara[iLoop], m_mdh->aushFreePara[iLoop + 1]);
        }
      }

    //Dump compressed, e.g. do not dump some zeros, dump loop 
    //counters in one line.
	//##ModelId=35B2FAA6037F
      virtual void dump (ostream& os, bool bCompressed = false)
      {

        os << STREAM_HEX_W32_NL_XX( m_mdh->ulFlagsAndDMALength);
        os << STREAM_DEC_W32_NL_XX( m_mdh->lMeasUID );
        os << STREAM_DEC_W32_NL_XX( m_mdh->ulScanCounter );
        os << STREAM_HEX_W32_NL_XX( m_mdh->ulTimeStamp );
        os << STREAM_HEX_W32_NL_XX( m_mdh->ulPMUTimeStamp );
        os << STREAM_HEX_W32_NL_XX( m_mdh->aulEvalInfoMask[0] );
        os << STREAM_HEX_W32_NL_XX( m_mdh->aulEvalInfoMask[1] );
        os << STREAM_HEX_W32_NL_XX( m_mdh->ulTimeSinceLastRF );
        DUMP_EVALINFOMASK(os, m_EvalInfoMask ) os << "\n";
        os << STREAM_DEC_W32_NL_XX( m_mdh->ushSamplesInScan );
        os << STREAM_DEC_W32_NL_XX( m_mdh->ushUsedChannels );

        if (!bCompressed)
        {
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushLine );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushAcquisition );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushSlice );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushPartition );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushEcho );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushPhase );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushRepetition );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushSet );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushSeg );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushIda );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushIdb );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushIdc );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushIdd );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sLC.ushIde );

            os << STREAM_DEC_W32_NL_XX( m_mdh->sCutOff.ushPre );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sCutOff.ushPost );

            os << STREAM_DEC_W32_NL_XX( m_mdh->ushKSpaceCentreColumn );
            os << STREAM_DEC_W32_NL_XX( m_mdh->ushCoilSelect);

            os << STREAM_DEC_W32_NL_XX( m_mdh->fReadOutOffcentre );
              
            os << STREAM_DEC_W32_NL_XX( m_mdh->ushKSpaceCentreLineNo );
            os << STREAM_DEC_W32_NL_XX( m_mdh->ushKSpaceCentrePartitionNo);

            int ii = 0;
            for (ii = 0; ii < MDH_NUMBEROFICEPROGRAMPARA; ++ii)
            {
                if (m_mdh->aushIceProgramPara[ii])
                os << STREAM_HEX_W32_NL_XX( m_mdh->aushIceProgramPara[ii] );
            }

            for (ii = 0; ii < MDH_FREEHDRPARA; ii ++)
            {
                os << STREAM_HEX_W32_NL_XX( m_mdh->aushFreePara[ii] );
            }

            os << STREAM_DEC_W32_NL_XX( m_mdh->sSD.sSlicePosVec.flSag );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sSD.sSlicePosVec.flTra );
            os << STREAM_DEC_W32_NL_XX( m_mdh->sSD.sSlicePosVec.flCor );
            double adRotMatrix[3][3];
            getRotMatrix (adRotMatrix, m_mdh->sSD);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[0][0]);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[0][1]);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[0][2]);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[1][0]);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[1][1]);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[1][2]);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[2][0]);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[2][1]);
            os << STREAM_DEC_W32_NL_XX(adRotMatrix[2][2]);
        }
        else
        {
            os << "\ncacq=" << m_mdh->sLC.ushAcquisition 
                << "  clin=" << m_mdh->sLC.ushLine
                << "  cseg=" << m_mdh->sLC.ushSeg
                << "  ceco=" << m_mdh->sLC.ushEcho
                << "  cslc=" << m_mdh->sLC.ushSlice
                << "  cpar=" << m_mdh->sLC.ushPartition
                << "  cset=" << m_mdh->sLC.ushSet
                << "  cphs=" << m_mdh->sLC.ushPhase
                << "  CIda=" << m_mdh->sLC.ushIda
                << "  CIdb=" << m_mdh->sLC.ushIdb
                << "  CIdc=" << m_mdh->sLC.ushIdc
                << "  CIdd=" << m_mdh->sLC.ushIdd
                << "  CIde=" << m_mdh->sLC.ushIde
                << "  crep=" << m_mdh->sLC.ushRepetition 
                << "\n\n";

            if (m_mdh->sCutOff.ushPre)
                os << STREAM_DEC_W32_NL_XX( m_mdh->sCutOff.ushPre );
            if (m_mdh->sCutOff.ushPost)
                os << STREAM_DEC_W32_NL_XX( m_mdh->sCutOff.ushPost );

            os << STREAM_DEC_W32_NL_XX( m_mdh->ushKSpaceCentreColumn );

            if (m_mdh->ushCoilSelect)
                os << STREAM_DEC_W32_NL_XX( m_mdh->ushCoilSelect);

            os << STREAM_DEC_W32_NL_XX( m_mdh->fReadOutOffcentre );
              
            os << STREAM_DEC_W32_NL_XX( m_mdh->ushKSpaceCentreLineNo );
            os << STREAM_DEC_W32_NL_XX( m_mdh->ushKSpaceCentrePartitionNo);
              
            int ii = 0;
            for (ii = 0; ii < MDH_NUMBEROFICEPROGRAMPARA; ++ii)
            {
                if (m_mdh->aushIceProgramPara[ii])
                os << STREAM_HEX_W32_NL_XX( m_mdh->aushIceProgramPara[ii] );
            }

            for (ii = 0; ii < MDH_FREEHDRPARA; ++ii)
            {
                if (m_mdh->aushFreePara[ii])
                os << STREAM_HEX_W32_NL_XX( m_mdh->aushFreePara[ii] );
            }

            os << "         m_mdh->sSD.sSlicePosVec = ( " << m_mdh->sSD.sSlicePosVec.flSag
                                                << " , " << m_mdh->sSD.sSlicePosVec.flCor
                                                << " , " << m_mdh->sSD.sSlicePosVec.flTra << " )\n";
            double adRotMatrix[3][3];
            getRotMatrix (adRotMatrix, m_mdh->sSD);
            os << " Gp = " << adRotMatrix[0][0] << " * Gsag + " <<
                                adRotMatrix[0][1] << " * Gcor + " <<
                                adRotMatrix[0][2] << " * Gtra\n";
            os << " Gr = " << adRotMatrix[1][0] << " * Gsag + " <<
                                adRotMatrix[1][1] << " * Gcor + " <<
                                adRotMatrix[1][2] << " * Gtra\n";
            os << " Gs = " << adRotMatrix[2][0] << " * Gsag + " <<
                                adRotMatrix[2][1] << " * Gcor + " <<
                                adRotMatrix[2][2] << " * Gtra\n";
        }

        os << STREAM_DEC_W32_NL_XX( m_mdh->ulChannelId );

        os << endl;

      }

	//##ModelId=367A7FC201D9
      void setPhaseFT (bool flag)
      {
        m_EvalInfoMask.setState(MDH_PHASEFFT, flag);
      }

	//##ModelId=367A7FC2021F
      bool performPhaseFT (void ) const
      {
        return (m_EvalInfoMask.isState(MDH_PHASEFFT));
      }

	//##ModelId=367A829402D2
      void setPartitionFT (bool flag)
      {
        m_EvalInfoMask.setState(MDH_D3FFT, flag);
      }

	//##ModelId=367A8294030E
      bool performPartitionFT (void ) const
      {
        return (m_EvalInfoMask.isState(MDH_D3FFT));
      }

	//##ModelId=367A82DD018C
      void setNoiseAdjustScan (bool flag)
      {
        m_EvalInfoMask.setState(MDH_NOISEADJSCAN, flag);
      }

	//##ModelId=367A82DD01C8
      bool isNoiseAdjustScan (void ) const
      {
        return (m_EvalInfoMask.isState(MDH_NOISEADJSCAN));
      }

    //Set the variable fReadOutOffcenter in the MDH-structure.
	//##ModelId=36C838CE03A6
      void setReadOutOffcentre (float value)
      {
        m_mdh->fReadOutOffcentre = value;
      }

    //Return the variable fReadOutOffcenter in the 
    //MDH-structure.
	//##ModelId=36C8391802B2
      float getReadOutOffcentre () const
      {
        return m_mdh->fReadOutOffcentre;
      }

    //Set the MDH_SHAREDNOW bit in the EvalInfoMask if the 
    //parameter is true otherwise unset it.
	//##ModelId=36C8395C02D8
      void setShareNow (bool flag)
      {
        m_EvalInfoMask.setState(MDH_SHARENOW, flag);
      }

    //Returns true if the MDH_SHARENOW bit is set in the 
    //EvalInfoMask.
	//##ModelId=36C8398802F0
      bool isShareNow () const
      {
        return (m_EvalInfoMask.isState(MDH_SHARENOW));
      }

    //Set the MDH_LASTMEASUREDLINE bit in the EvalInfoMask if 
    //theparameter is true.
	//##ModelId=36C839A101BF
      void setLastMeasuredLine (bool flag)
      {
        m_EvalInfoMask.setState(MDH_LASTMEASUREDLINE, flag);
      }

    //Returns true if MDH_LASTMEASUREDLINE bit is set in the 
    //EvalInfoMask.
	//##ModelId=36C839A10219
      bool isLastMeasuredLine () const
      {
        return (m_EvalInfoMask.isState(MDH_LASTMEASUREDLINE));
      }

    //Set the MDH_POSTSHAREDLINE bit in the EvalInfoMask if 
    //the parameter is true.
	//##ModelId=370CAC520385
      void setPostSharedLine (bool flag)
      {
        m_EvalInfoMask.setState(MDH_POSTSHAREDLINE, flag);
      }

    //Returns true if MDH_POSTSHAREDLINE bit is set in the 
    //EvalInfoMask.
	//##ModelId=370CAC5203C1
      bool isPostSharedLine () const
      {
        return (m_EvalInfoMask.isState(MDH_POSTSHAREDLINE));
      }

    //Set the MDH_FIRSTSCANINSLICE bit in the EvalInfoMask if 
    //the parameter is true.
	//##ModelId=37244DB803AA
      void setFirstScanInSlice (bool flag)
      {

        if (flag == true)
        {
          m_EvalInfoMask.setState(MDH_FIRSTSCANINSLICE, true);
          m_EvalInfoMask.setState(MDH_LASTSCANINSLICE, false);
        }
        else
          m_EvalInfoMask.setState(MDH_FIRSTSCANINSLICE, false);
      }

    //Returns true if MDH_FIRSTSCANINSLICE bit is set in the 
    //EvalInfoMask.
	//##ModelId=37244DB803DC
      bool isFirstScanInSlice () const
      {
        return (m_EvalInfoMask.isState(MDH_FIRSTSCANINSLICE));
      }

    //Set the MDH_LASTSCANINSLICE bit in the EvalInfoMask if 
    //the parameter is true.
	//##ModelId=37244E300081
      void setLastScanInSlice (bool flag)
      {
        if (flag == true)
        {
          m_EvalInfoMask.setState(MDH_LASTSCANINSLICE, true);
          m_EvalInfoMask.setState(MDH_FIRSTSCANINSLICE, false);
        }
        else
          m_EvalInfoMask.setState(MDH_LASTSCANINSLICE, false);
      }

    //Returns true if MDH_LASTSCANINSLICE bit is set in the 
    //EvalInfoMask.
	//##ModelId=37244E3000B4
      bool isLastScanInSlice () const
      {
        return (m_EvalInfoMask.isState(MDH_LASTSCANINSLICE));
      }

    //Set the MDH_TREFFECTIVEBEGIN bit in the EvalInfoMask if 
    //the parameter is true.
	//##ModelId=378A02490138
      void setTREffectiveBegin (bool flag)
      {
        if (flag == true)
        {
          m_EvalInfoMask.setState(MDH_TREFFECTIVEBEGIN, true);
          m_EvalInfoMask.setState(MDH_TREFFECTIVEEND, false);
        }
        else
          m_EvalInfoMask.setState(MDH_TREFFECTIVEBEGIN, false);
      }

    //Returns true if MDH_TREFFECTIVEBEGIN bit is set in the 
    //EvalInfoMask.
	//##ModelId=378A02490174
      bool isTREffectiveBegin () const
      {
        return (m_EvalInfoMask.isState(MDH_TREFFECTIVEBEGIN));
      }

    //Set the MDH_TREFFECTIVEEND bit in the EvalInfoMask if 
    //the parameter is true.
	//##ModelId=378A04350348
      void setTREffectiveEnd (bool flag)
      {
        if (flag == true)
        {
          m_EvalInfoMask.setState(MDH_TREFFECTIVEEND, true);
          m_EvalInfoMask.setState(MDH_TREFFECTIVEBEGIN, false);
        }
        else
          m_EvalInfoMask.setState(MDH_TREFFECTIVEEND, false);
      }

    //Returns true if MDH_TREFFECTIVEEND bit is set in the 
    //EvalInfoMask.
	//##ModelId=378A0435037A
      bool isTREffectiveEnd () const
      {
        return (m_EvalInfoMask.isState(MDH_TREFFECTIVEEND));
      }

	//##ModelId=38033018004B
      void getRotMatrix (double adRotMatrix[3][3], const sSliceData &SliceData) const
      {

        /* cout << "mdh::getRotMatrix: running..." << endl;
        cout << "mdh::getRotMatrix: aflQuaternion = " << SliceData.aflQuaternion[0] << ", " <<
                                                         SliceData.aflQuaternion[1] << ", " <<
                                                         SliceData.aflQuaternion[2] << ", " <<
                                                         SliceData.aflQuaternion[3] << endl; */

        double adQuaternion[4];
        adQuaternion[0] = SliceData.aflQuaternion[0];
        adQuaternion[1] = SliceData.aflQuaternion[1];
        adQuaternion[2] = SliceData.aflQuaternion[2];
        adQuaternion[3] = SliceData.aflQuaternion[3];
        quat2mat (adQuaternion, adRotMatrix);

        /* cout << "mdh::getRotMatrix: Gp = " << adRotMatrix[0][0] << " * Gsag + " <<
                                              adRotMatrix[0][1] << " * Gcor + " <<
                                              adRotMatrix[0][2] << " * Gtra\n";
        cout << "mdh::getRotMatrix: Gr = " << adRotMatrix[1][0] << " * Gsag + " <<
                                              adRotMatrix[1][1] << " * Gcor + " <<
                                              adRotMatrix[1][2] << " * Gtra\n";
        cout << "mdh::getRotMatrix: Gs = " << adRotMatrix[2][0] << " * Gsag + " <<
                                              adRotMatrix[2][1] << " * Gcor + " <<
                                              adRotMatrix[2][2] << " * Gtra\n";
        cout << "mdh::getRotMatrix: ...finished" << endl; */

      }

    //The passed RotMatrix is used to label the image.
    //Beware: This is not the RotMatrix the sequence handles
    //normally, describing the transition from Gp, Gr and Gs 
    //to
    //Gx, Gy and Gz.
    //Instead the transition between Gp, Gr and Gs to the 
    //patient
    //axes Sag, Cor and Tra is needed here.
    //Use fGSLCalcPRS to determine the correct matrix, unless
    //your sequence calculates the directions of Gp, Gr and Gs
    //itself, e.g. in interactive scanning.
	//##ModelId=380330180087
      static void setRotMatrix (const double  adRotMatrix[3][3], sSliceData &SliceData)
      {

        /* cout << "mdh::setRotMatrix: running..." << endl;
        cout << "mdh::setRotMatrix: Gp = " << adRotMatrix[0][0] << " * Gsag + " <<
                                              adRotMatrix[0][1] << " * Gcor + " <<
                                              adRotMatrix[0][2] << " * Gtra\n";
        cout << "mdh::setRotMatrix: Gr = " << adRotMatrix[1][0] << " * Gsag + " <<
                                              adRotMatrix[1][1] << " * Gcor + " <<
                                              adRotMatrix[1][2] << " * Gtra\n";
        cout << "mdh::setRotMatrix: Gs = " << adRotMatrix[2][0] << " * Gsag + " <<
                                              adRotMatrix[2][1] << " * Gcor + " <<
                                              adRotMatrix[2][2] << " * Gtra\n"; */

        double adQuaternion[4];
        mat2quat (adRotMatrix, adQuaternion);

        /* cout << "mdh::setRotMatrix: adQuaternion = " << adQuaternion[0] << ", " <<
                                                        adQuaternion[1] << ", " <<
                                                        adQuaternion[2] << ", " <<
                                                        adQuaternion[3] << endl; */

        SliceData.aflQuaternion[0] = (float) adQuaternion[0];
        SliceData.aflQuaternion[1] = (float) adQuaternion[1];
        SliceData.aflQuaternion[2] = (float) adQuaternion[2];
        SliceData.aflQuaternion[3] = (float) adQuaternion[3];

        /* cout << "mdh::setRotMatrix: ...finished" << endl; */

      }

    //Set the MDH_SWAPPED bit in the EvalInfoMask if the 
    //parameter is true.
	//##ModelId=3806E13F0192
      void setPRSwapped (bool flag)
      {
        m_EvalInfoMask.setState(MDH_SWAPPED, flag);
      }

    //Returns true if MDH_SWAPPED bit is set in the 
    //EvalInfoMask.
	//##ModelId=3806E13F01D8
      bool isPRSwapped () const
      {
        return (m_EvalInfoMask.isState(MDH_SWAPPED));
      }

    //Set the MDH_PHASESTABSCAN bit in the EvalInfoMask if 
    //the parameter is true.
	//##ModelId=387DE13B00EB
      void setPhaseStabScan (bool flag)
      {
        m_EvalInfoMask.setState(MDH_PHASESTABSCAN, flag);
      }

    //Returns true if MDH_PHASESTABSCAN bit is set in the 
    //EvalInfoMask.
	//##ModelId=387DE13B0127
      bool isPhaseStabScan () const
      {
        return (m_EvalInfoMask.isState(MDH_PHASESTABSCAN));
      }

    //Set the MDH_REFPHASESTABSCAN bit in the EvalInfoMask if 
    //the parameter is true.
	//##ModelId=387DE1D6004E
      void setRefPhaseStabScan (bool flag)
      {
        m_EvalInfoMask.setState(MDH_REFPHASESTABSCAN, flag);
      }

    //Returns true if MDH_PHASESTABSCAN bit is set in the 
    //EvalInfoMask.
	//##ModelId=387DE1D60080
      bool isRefPhaseStabScan () const
      {
        return (m_EvalInfoMask.isState(MDH_REFPHASESTABSCAN));
      }

    //Returns the time since last RF pulse. Relevant for 
    //sequences which measure more than one scan inside the 
    //kernel or th eTE time of the protocol does not 
    //correspond with the actual time of the scan.
	//##ModelId=387DE2E50062
      unsigned long getTimeSinceLastRF () const
      {
        return m_mdh->ulTimeSinceLastRF;
      }

	//##ModelId=387DE2E50094
      void setTimeSinceLastRF (unsigned long time)
      {
        m_mdh->ulTimeSinceLastRF = time;
      }

    //Returns true if current scan should be used for image 
    //calculation (i.e. is not of type MDH_REFPHASESTABSCAN, 
    //MDH_PHASESTABSCAN or MDH_PHASCOR).
	//##ModelId=38E34E310174
      bool isImagingScan () const
      {
        return ( !(m_EvalInfoMask.isState(MDH_REFPHASESTABSCAN) ||
                   m_EvalInfoMask.isState(MDH_PHASESTABSCAN)    ||
                   m_EvalInfoMask.isState(MDH_PHASCOR)          ||
                   m_EvalInfoMask.isState(MDH_NOISEADJSCAN))            );
      }

    //Returns the number of the K-spcae centre line.
    //(Counting starts with zero.)
	//##ModelId=38FB2478004C
      unsigned short getKSpaceCentreLineNo () const
      {
        return m_mdh->ushKSpaceCentreLineNo;
      }

    //Sets the number of the K-spcae centre line.
    //(Counting starts with zero.)
	//##ModelId=38FB2478009C
      void setKSpaceCentreLineNo (const unsigned short ushLineNo)
      {
        m_mdh->ushKSpaceCentreLineNo = ushLineNo;
      }

    //Returns the number of the K-spcae centre partition.
    //(Counting starts with zero.)
	//##ModelId=38FB24FE01FD
      unsigned short getKSpaceCentrePartitionNo () const
      {
        return m_mdh->ushKSpaceCentrePartitionNo;
      }

    //Sets the number of the K-spcae centre partition.
    //(Counting starts with zero.)
	//##ModelId=38FB24FE022F
      void setKSpaceCentrePartitionNo (const unsigned short ushPartNo)
      {
        m_mdh->ushKSpaceCentrePartitionNo = ushPartNo;
      }

    //Returns true if flag is set which indicates, that an 
    //additional scale factor for this scan shall be applied.
	//##ModelId=39A0F79D02E8
      bool isScanScaleFactor () const
      {
        return (m_EvalInfoMask.isState(MDH_SCANSCALEFACTOR));
      }

    //Set flag which indicates, that an additional scale 
    //factor for this scan shall be applied if parameter is 
    //true.
	//##ModelId=39A0F7E90111
      void setScanScaleFactor (bool flag)
      {
        m_EvalInfoMask.setState(MDH_SCANSCALEFACTOR, flag);
      }

    //Returns true if flag is set which indicates, that 2nd 
    //Hadamar pulse was applied.
	//##ModelId=39A0F83B0141
      bool is2ndHadamarPulse () const
      {
        return (m_EvalInfoMask.isState(MDH_2NDHADAMARPULSE));
      }

    //Set flag which indicates, that 2nd Hadamar pulse was 
    //applied if parameter is true.
	//##ModelId=39A0F867013A
      void set2ndHadamarPulse (bool flag)
      {
        m_EvalInfoMask.setState(MDH_2NDHADAMARPULSE, flag);
      }

	//##ModelId=39CA314D0110
      void setLastScanInMeas (bool flag)
      {
        m_EvalInfoMask.setState(MDH_LASTSCANINMEAS, flag);
      }

	//##ModelId=39CA31870092
      bool isLastScanInMeas (void ) const
      {
        return (m_EvalInfoMask.isState(MDH_LASTSCANINMEAS));
      }

    //Set the MDH_RAWDATACORRECTION bit in the EvalInfoMask 
    //if the parameter is true.
	//##ModelId=3A1FBBED0091
      void setRawDataCorrection (bool flag)
      {
        m_EvalInfoMask.setState(MDH_RAWDATACORRECTION, flag);
      }

    //Returns true if MDH_RAWDATACORRECTION bit is set in the 
    //EvalInfoMask.
	//##ModelId=3A1FBBED010A
      bool isRawDataCorrection () const
      {
        return (m_EvalInfoMask.isState(MDH_RAWDATACORRECTION));
      }

	//##ModelId=3AF6BE4B006B
      unsigned short getIceProgramPara (unsigned short ushIndex) const
      {
        return (m_mdh->aushIceProgramPara[ushIndex]);
      }

	//##ModelId=3AF6BE4B009D
      void setIceProgramPara (unsigned short ushIndex, unsigned short ushValue)
      {
        m_mdh->aushIceProgramPara[ushIndex] = ushValue;
      }

    //Set the MDH_PATFSCAN bit in the EvalInfoMask if the 
    //parameter is true.
	//##ModelId=3B31F4A0023A
      void setPATRefScan (bool flag)
      {
        m_EvalInfoMask.setState(MDH_PATREFSCAN, flag);
      }

    //Returns true if MDH_PATREFSCAN bit is set in the 
    //EvalInfoMask.
	//##ModelId=3B31F4A00277
      bool isPatRefScan () const
      {
        return (m_EvalInfoMask.isState(MDH_PATREFSCAN));
      }

	//##ModelId=3BFA37E80221
      void setPATRefAndImaScan (bool flag)
      {
        m_EvalInfoMask.setState(MDH_PATREFANDIMASCAN, flag);
      }

	//##ModelId=3BFA380D0206
      bool isPatRefAndImaScan () const
      {
        return (m_EvalInfoMask.isState(MDH_PATREFANDIMASCAN));
      }

	//##ModelId=3BA210E60054
      void setLastScanInConcat (bool flag)
      {
        m_EvalInfoMask.setState(MDH_LASTSCANINCONCAT, flag);        
      }

	//##ModelId=3BA2115802A7
      bool isLastScanInConcat () const
      {
        return (m_EvalInfoMask.isState(MDH_LASTSCANINCONCAT));
      }

    // Additional Public Declarations
	//##ModelId=3DFD98640008
      unsigned short getCnone() const 
      { 
        return 0;
      }
  protected:
    // Additional Protected Declarations

  private:

	//##ModelId=35B49ABF0250
      void swapPairOfShorts (unsigned short &ushA, unsigned short &ushB)
      {
        unsigned short ushBuffer;

        ushBuffer = ushA;
        ushA = ushB;
        ushB = ushBuffer;
      }

	//##ModelId=3803367E03B7
      static void quat2mat (const double adQuaternion[4], double adRotMatrix[3][3])
      {
        double ds, dxs, dys, dzs, dwx, dwy, dwz, dxx, dxy, dxz, dyy, dyz, dzz;

        ds = 2.0 / (adQuaternion[MDH_QW] * adQuaternion[MDH_QW] +
                    adQuaternion[MDH_QX] * adQuaternion[MDH_QX] +
                    adQuaternion[MDH_QY] * adQuaternion[MDH_QY] +
                    adQuaternion[MDH_QZ] * adQuaternion[MDH_QZ]);

        dxs = adQuaternion[MDH_QX] *  ds; dys = adQuaternion[MDH_QY] *  ds; dzs = adQuaternion[MDH_QZ] *  ds;
        dwx = adQuaternion[MDH_QW] * dxs; dwy = adQuaternion[MDH_QW] * dys; dwz = adQuaternion[MDH_QW] * dzs;
        dxx = adQuaternion[MDH_QX] * dxs; dxy = adQuaternion[MDH_QX] * dys; dxz = adQuaternion[MDH_QX] * dzs;
        dyy = adQuaternion[MDH_QY] * dys; dyz = adQuaternion[MDH_QY] * dzs; dzz = adQuaternion[MDH_QZ] * dzs;

        adRotMatrix[0][0] = 1.0 - (dyy + dzz);
        adRotMatrix[0][1] =        dxy + dwz ;
        adRotMatrix[0][2] =        dxz - dwy ;
        adRotMatrix[1][0] =        dxy - dwz ;
        adRotMatrix[1][1] = 1.0 - (dxx + dzz);
        adRotMatrix[1][2] =        dyz + dwx ;
        adRotMatrix[2][0] =        dxz + dwy ;
        adRotMatrix[2][1] =        dyz - dwx ;
        adRotMatrix[2][2] = 1.0 - (dxx + dyy);
      }


	//##ModelId=380337240027
      static void mat2quat (const double adRotMatrix[3][3], double adQuaternion[4])
      {
        double ds;

        if ((ds = adRotMatrix[0][0] + adRotMatrix[1][1] + adRotMatrix[2][2]) > 0.0)
        {
            ds = sqrt (1.0 + ds);
            adQuaternion[MDH_QW] = 0.5 * ds;
            ds    = 0.5 / ds;
            adQuaternion[MDH_QX] = (adRotMatrix[1][2] - adRotMatrix[2][1]) * ds;
            adQuaternion[MDH_QY] = (adRotMatrix[2][0] - adRotMatrix[0][2]) * ds;
            adQuaternion[MDH_QZ] = (adRotMatrix[0][1] - adRotMatrix[1][0]) * ds;
        }
        else
        {
            if (adRotMatrix[1][1] > adRotMatrix[0][0])
            {
            if (adRotMatrix[2][2] > adRotMatrix[1][1])
            {
                ds = sqrt ((adRotMatrix[2][2] - (adRotMatrix[0][0] + adRotMatrix[1][1])) + 1.0);
                adQuaternion[MDH_QZ] = 0.5 * ds;
                ds    = 0.5 / ds;
                adQuaternion[MDH_QW] = (adRotMatrix[0][1] - adRotMatrix[1][0]) * ds;
                adQuaternion[MDH_QX] = (adRotMatrix[2][0] + adRotMatrix[0][2]) * ds;
                adQuaternion[MDH_QY] = (adRotMatrix[2][1] + adRotMatrix[1][2]) * ds;
            }
            else
            {
                ds = sqrt ((adRotMatrix[1][1] - (adRotMatrix[2][2] + adRotMatrix[0][0])) + 1.0);
                adQuaternion[MDH_QY] = 0.5 * ds;
                ds    = 0.5 / ds;
                adQuaternion[MDH_QW] = (adRotMatrix[2][0] - adRotMatrix[0][2]) * ds;
                adQuaternion[MDH_QZ] = (adRotMatrix[1][2] + adRotMatrix[2][1]) * ds;
                adQuaternion[MDH_QX] = (adRotMatrix[1][0] + adRotMatrix[0][1]) * ds;
            }
            }
            else
            {
            if (adRotMatrix[2][2] > adRotMatrix[0][0])
            {
                ds = sqrt ((adRotMatrix[2][2] - (adRotMatrix[0][0] + adRotMatrix[1][1])) + 1.0);
                adQuaternion[MDH_QZ] = 0.5 * ds;
                ds    = 0.5 / ds;
                adQuaternion[MDH_QW] = (adRotMatrix[0][1] - adRotMatrix[1][0]) * ds;
                adQuaternion[MDH_QX] = (adRotMatrix[2][0] + adRotMatrix[0][2]) * ds;
                adQuaternion[MDH_QY] = (adRotMatrix[2][1] + adRotMatrix[1][2]) * ds;
            }
            else
            {
                ds = sqrt ((adRotMatrix[0][0] - (adRotMatrix[1][1] + adRotMatrix[2][2])) + 1.0);
                adQuaternion[MDH_QX] = 0.5 * ds;
                ds    = 0.5 / ds;
                adQuaternion[MDH_QW] = (adRotMatrix[1][2] - adRotMatrix[2][1]) * ds;
                adQuaternion[MDH_QY] = (adRotMatrix[0][1] + adRotMatrix[1][0]) * ds;
                adQuaternion[MDH_QZ] = (adRotMatrix[0][2] + adRotMatrix[2][0]) * ds;
            }
            }
        }
      }

    // Data Members for Class Attributes

	//##ModelId=35B07BF00275
      sMDH *m_mdh;

	//##ModelId=3AFB964B01F6
      MdhBitField m_EvalInfoMask;

    // Additional Private Declarations

	//##ModelId=3DFD98640080
      MdhProxy(const MdhProxy &right);

};

#endif
