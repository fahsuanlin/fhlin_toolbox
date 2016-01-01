//	-----------------------------------------------------------------------------
//	  Copyright (C) Siemens AG 1998  All Rights Reserved.
//	-----------------------------------------------------------------------------
//
//	 Project: NUMARIS/4
//	    File: \n4_servers1\pkg\MrServers\MrCv\seq\Kernels\NavMdhDef.h@@\main\4b11a\2
//	 Version:
//	  Author: kroeraf6
//	    Date: Wed 07/02/2003 07:07 PM
//
//	    Lang: C++
//
//	 Descrip: MR::Measurement::CSequence::libSeqUtil
//
//	 Classes:
//
//	-----------------------------------------------------------------------------

#ifndef __NavMDHDef_H
#define __NavMDHDef_H 1

// Constants which define the contents of the free part of the MDH buffer.

//Original code Jan 11, 2002:
//enum eMDHFreeShort  { MDH_FREESHORT_NAVIGATORNUMBER=0,
//                      MDH_FREESHORT_NAVIGATORCOUNT,
//                      MDH_FREESHORT_PERCENT_COMPLETE,
//                      MDH_FREESHORT_PERCENT_ACCEPTED,
//                      MDH_FREESHORT_FLAGS,
//                      MDH_FREESHORT_MAX_FEEDBACKTIME_MS };
                     
enum eMDHFreeShort  { MDH_FREESHORT_PERCENT_COMPLETE=0,
                      MDH_FREESHORT_PERCENT_ACCEPTED,
                      MDH_FREESHORT_FLAGS,
                      MDH_FREESHORT_MAX_FEEDBACKTIME_MS };

enum eMHDFlags     { MDH_FLAG_LASTRTSCAN = 0x0001,
                     MDH_FLAG_LASTHPSCAN = 0x0002,
                     MDH_FLAG_NOFEEDBACK = 0x0004,
                     MDH_FLAG_AFTERECHO  = 0x0008};

enum eBaseIceProg   { BASE_ICE_PROG_IceProgram2D = 1,
                      BASE_ICE_PROG_IceProgram2PointDixon2D,
                      BASE_ICE_PROG_IceProgram3D,
                      BASE_ICE_PROG_IceProgramDiffusion2D,
                      BASE_ICE_PROG_IceProgramOffline3D,
                      BASE_ICE_PROG_IceProgramOfflinePeFTbeforePaFT3D,
                      BASE_ICE_PROG_IceProgramOnline2D,
                      BASE_ICE_PROG_IceProgramOnlinePeFT3D,
                      BASE_ICE_PROG_IceProgramPaceOnline2D,
                      BASE_ICE_PROG_IceProgramPCAngio2D,
                      BASE_ICE_PROG_IceProgramPCAngio3D,
                      BASE_ICE_PROG_IceProF,
                      BASE_ICE_PROG_IceProgramPOCS2D,
                      BASE_ICE_PROG_IceProgramOfflinePOCS3D };
                             
#endif  // ifndef __NavMDHDef_H
