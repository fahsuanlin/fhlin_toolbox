#include <stdio.h>
#include <string.h>
#include <math.h>
#include <varargs.h>
#include "MyIce.h"       // structures like FIFO
#include "MrProtocol.h"  // a list of quantities from MrProt.asc

#define DEBUG 0        // 0 = no output of MDH, 1 = essential output, 2 = everything
#define STREAM_RAW 0   // don't reconstruct images; just stream to a file "raw.bfloat"

// Prototypes for function in this file.
int read_MrProt(char *sMeasOut_name );
char *psNextNonWhite( char *ps );
void swap_32( void *ptr );
int Replace_Extension( char *file_name, char *extension, char *new_file_name );

main( argc, argv)
int argc;
char *argv[];
{
  FILE *file_in, *file_raw;
  char BshortFileName[LEN_STR];
  FCOMPLEX *FCData, *fcomplex_vector();
  FIFO sFifo;
  long dummy[8];
  int j;
  long lError;
  long lNxOverSamp, lLengthFifoData;
  sMDH sMdh;
  BOOL ok;

  if ( argc != 2 )
    {
      printf("Syntax:       read file.out\n");
      printf("  assumes existing file.asc containing MrProt parameters.\n");
      exit(1);
    }

  // Read necessary parameters from the ascii file
  if ( read_MrProt(argv[1]) ) exit(1);

  // Make the bshort header file name;
  if ( Replace_Extension(argv[1], "hdr", BshortFileName) )
    {
      printf("\nError constructing the output file name header.\n");
      exit(1);
    }
  // Open the bshort header file for writing.
  // This will be available in IceFake_prepare through the protocol (MrProt).
  if ( !(MrProt.FileBshortOut = fopen(BshortFileName,"w")) )
    {
      printf("\nError: cannot open the output header file.\n");
      exit(1);
    }

  if ( STREAM_RAW )
    { // Stream raw data to file "raw.bfloat"
      if ( !(file_raw = fopen("raw.hdr","w")) )
	{
	  printf("\nError: cannot open the raw data header file.\n");
	  exit(1);
	}
      // Write the xds header file.
      fprintf( file_raw, "%d %d %d %d \n",
	       MrProt.lPhaseEncodingLines * MrProt.lFlyBack, // Y
	       MrProt.lBaseResolution * 4,                   // X * 2 for oversampling * 2 for complex data
	       MrProt.lNumberOfChannels*MrProt.lSlices*MrProt.lTimePoints, // channels * slices * (time + 1 ref)
	       1);
      fclose(file_raw);
      // Now open the raw bfloat file.
      if ( !(file_raw = fopen("raw.bfloat","w")) )
	{
	  printf("\nError: cannot open the raw data bfloat file.\n");
	  exit(1);
	}
      if ( MrProt.lFlyBack == 1 )
	printf("\nStream Raw data:   (x, y, z, t) \r\t\t\t\t = (%d, %d, %d, %d) with %d channels\n",
	       MrProt.lBaseResolution*2,MrProt.lPhaseEncodingLines,MrProt.lSlices,
	       MrProt.lTimePoints,MrProt.lNumberOfChannels);
      else
	printf("\nStream Raw data:   (x, y, z, t) \r\t\t\t\t = (%d, %d x 2, %d, %d) with %d channels\n",
	       MrProt.lBaseResolution*2,MrProt.lPhaseEncodingLines,MrProt.lSlices,
	       MrProt.lTimePoints,MrProt.lNumberOfChannels);
    }
  else
    { // Compute images only when raw data streaming is turned off.

      ///////////////////////////////////////////////////////////////////////////
      ////////////////////////// Call of Prepare Function ///////////////////////
      ///////////////////////////////////////////////////////////////////////////
      // Do ICE preparation for image computations
      ok = IceFake_prepare();
      if ( !ok )
	{
	  printf("\nError returned from function IceFake_prepare.\n");
	  exit(1);
	}
      // Close the open header file, and open a file for bshort data.
      fclose(MrProt.FileBshortOut);
      
      // Make the header file name: BSHORT for image data
      if ( Replace_Extension(argv[1], "bshort", BshortFileName) )
	{
	  printf("\nError constructing the output bshort file name.\n");
	  exit(1);
	}

      // Open the output file for writing.
      // This will be available in IceFake_online (..., etc.) through the protocol (MrProt).
      if ( !(MrProt.FileBshortOut = fopen(BshortFileName,"w")) )
	{
	  printf("\nError: cannot open the output file.\n");
	  exit(1);
	}
    }

  //
  // Allocate complex floating point data for each ADC read.
  //
  lNxOverSamp     = 2 * MrProt.lBaseResolution;    // Actual n
  lLengthFifoData = lNxOverSamp * MrProt.lNumberOfChannels;
  sFifo.FCData    = fcomplex_vector(lLengthFifoData);


  ///////////////////////////////////////////////////////////////////////////
  ////////////////////// Begin reading the input file ///////////////////////
  ///////////////////////////////////////////////////////////////////////////
  // Open the file for reading.
  if ( !(file_in = fopen(argv[1],"r")) )
    {
      printf("\nError: cannot open the input file.\n");
      exit(1);
    }
  // There are 32 bytes on top (uninteresting, as far as I can tell).
  lError = fread( (char *)dummy, sizeof(long), 8, file_in) != 8;
  if ( lError )
    {
      printf("\nError reading the top 32 bytes (error = %d).\n", lError);
      exit(1);
    }
  if ( DEBUG == 2 )
    {
      for (j=0; j<8; j++)
	printf("dummy[%d] = %d\n",j,dummy[j]);
    }
  //
  // Begin the loop of MDH, FIFO, MDH, FIFO, ...
  //
  while ( fread( (char *)(&sMdh.ulDMALength), sizeof(sMDH), 1, file_in) == 1 )
    {
      if ( DEBUG )
	{
	  printf(" =================== MDH %d =======================\n",sMdh.ulScanCounter);
	  printf("# samples in scan   = %d\n",sMdh.ushSamplesInScan);
	  if ( sMdh.ushUsedChannels != 1 )
	    printf("# channels = %d, channel ID = %d\n",sMdh.ushUsedChannels,sMdh.ulChannelId);
	  // Special flags:
	  printf("flags: ");
#ifdef VA15
	  if ( sMdh.ulEvalInfoMask & MDH_PHASCOR )               printf("PhaseCor ");
	  if ( sMdh.ulEvalInfoMask & MDH_FIRSTSCANINSLICE )      printf("FirstInSlice ");
	  if ( sMdh.ulEvalInfoMask & MDH_LASTSCANINSLICE )       printf("LastInSlice ");
	  if ( sMdh.ulEvalInfoMask & MDH_REFLECT )               printf("Reflect ");
	  if ( sMdh.aulEvalInfoMask[0] & MDH_REFPHASESTABSCAN )  printf("RefNav");
	  if ( sMdh.aulEvalInfoMask[0] & MDH_PHASESTABSCAN )     printf("Nav");
#else
	  if ( sMdh.aulEvalInfoMask[0] & MDH_PHASCOR )           printf("PhaseCor ");
	  if ( sMdh.aulEvalInfoMask[0] & MDH_FIRSTSCANINSLICE )  printf("FirstInSlice ");
	  if ( sMdh.aulEvalInfoMask[0] & MDH_LASTSCANINSLICE )   printf("LastInSlice ");
	  if ( sMdh.aulEvalInfoMask[0] & MDH_REFLECT )           printf("Reflect ");
	  if ( sMdh.aulEvalInfoMask[0] & MDH_REFPHASESTABSCAN )  printf("RefNav");
	  if ( sMdh.aulEvalInfoMask[0] & MDH_PHASESTABSCAN )     printf("Nav");
#endif
	  printf("\n");
	  //	  printf(" --------------- LOOP COUNTERS -----------------\n");
	  printf("REP = %d, SLC = %d, SEG = %d, LIN = %d\n",
		 sMdh.sLC.ushRepetition,sMdh.sLC.ushSlice,sMdh.sLC.ushSeg,sMdh.sLC.ushLine);
	  printf("ACQ = %d, PAR = %d, ECO = %d, PHS = %d, SET = %d\n",
		 sMdh.sLC.ushAcquisition,sMdh.sLC.ushPartition,sMdh.sLC.ushEcho,sMdh.sLC.ushPhase,sMdh.sLC.ushSet);
#ifdef VA15
	  printf("FRE = %d\n",sMdh.sLC.ushFree);
#else
	  printf("FRE = %d %d %d %d %d\n",sMdh.sLC.ushIda,
		 sMdh.sLC.ushIdb,sMdh.sLC.ushIdc,sMdh.sLC.ushIdd,sMdh.sLC.ushIde);
#endif
	  if ( DEBUG == 2 )
	    {
	      printf("DMA length          = %d\n",sMdh.ulDMALength);
	      printf("measurement user ID = %d\n",sMdh.lMeasUID);
	      printf("time stamp          = %d\n",sMdh.ulTimeStamp);
	      printf("PMU time stamp      = %d\n",sMdh.ulPMUTimeStamp);
	      printf(" ----------------------------------------------\n");
	      printf("filled zeros (pre)  = %d\n",sMdh.sCutOff.ushPre);
	      printf("filled zeros (post) = %d\n",sMdh.sCutOff.ushPost);
	      printf("center line of echo = %d\n",sMdh.ushKSpaceCentreColumn);
	      printf("swapping variable   = %d\n",sMdh.ushDummy);
	      printf("Readout offcenter   = %f\n",sMdh.fReadOutOffcentre);
	      printf("time since last RF  = %d\n",sMdh.ulTimeSinceLastRF);
	      printf("k-space center line = %d\n",sMdh.ushKSpaceCentreLineNo);
	      printf("k-space center part = %d\n",sMdh.ushKSpaceCentrePartitionNo);
	      printf("free parameter[0]   = %d\n",sMdh.aushFreePara[0]);
	      printf("free parameter[1]   = %d\n",sMdh.aushFreePara[1]);
	      printf("free parameter[2]   = %d\n",sMdh.aushFreePara[2]);
	      printf("free parameter[3]   = %d\n",sMdh.aushFreePara[3]);
	      printf("free parameter[4]   = %d\n",sMdh.aushFreePara[4]);
	      printf("free parameter[5]   = %d\n",sMdh.aushFreePara[5]);
	      printf("free parameter[6]   = %d\n",sMdh.aushFreePara[6]);
	      printf("free parameter[7]   = %d\n",sMdh.aushFreePara[7]);
	      printf("free parameter[8]   = %d\n",sMdh.aushFreePara[8]);
	      printf("free parameter[9]   = %d\n",sMdh.aushFreePara[9]);
	      printf("free parameter[10]  = %d\n",sMdh.aushFreePara[10]);
	      printf("free parameter[11]  = %d\n",sMdh.aushFreePara[11]);
	      printf("free parameter[12]  = %d\n",sMdh.aushFreePara[12]);
	      printf("free parameter[13]  = %d\n",sMdh.aushFreePara[13]);
	      printf("slice position      = %f %f %f\n",sMdh.sSD.sSlicePosVec.flSag,
		     sMdh.sSD.sSlicePosVec.flCor,
		     sMdh.sSD.sSlicePosVec.flTra);
	      printf("slice rot. matrix   = %f %f %f %f\n",sMdh.sSD.aflQuaternion[0],
		     sMdh.sSD.aflQuaternion[1],
		     sMdh.sSD.aflQuaternion[2],
		     sMdh.sSD.aflQuaternion[3]);
	    }
	}
      //
      // An extra MDH at the end indicates the end of file.
      //
#ifdef VA15
      if ( sMdh.ulEvalInfoMask     & MDH_ACQEND )
	break;
#else
      if ( sMdh.aulEvalInfoMask[0] & MDH_ACQEND )
      	break;
#endif

      //
      // Error checking: the number of ADC samples should be lNxOverSamp (oversampling).
      //
      if ( sMdh.ushSamplesInScan != lNxOverSamp )
	{
	  printf(" ******** Consistency error in ADC %d *************\n",sMdh.ulScanCounter);
	  printf(" ******** ADC samples (%d) != expected samples (%d)\n\n",
		 sMdh.ushSamplesInScan, lNxOverSamp);
	}

      // Set the fifo length according to the data length in the 1st channel.
      if ( sMdh.ulChannelId == 0 )
	{
	  sFifo.lDimX = sFifo.lDimXOp = sMdh.ushSamplesInScan;
	  sFifo.lDimC = sMdh.ushUsedChannels;
	  sFifo.FCDataOp = sFifo.FCData;  // reset the operations pointer
	}
      else
	{
	  // Other channels should have the same FIFO length.
	  if ( sMdh.ushSamplesInScan != sFifo.lDimX )
	    {
	      printf("\nError!! Different ADC lengths in different channels!\n");
	      exit(1);
	    }
	}
      // Put the data into the Fifo array according to the channel ID.
      FCData = sFifo.FCData + sFifo.lDimX * sMdh.ulChannelId;
      
      // Read the complex floating point data.
      lError = fread( (char *)(FCData), sizeof(FCOMPLEX), sFifo.lDimX, file_in)	!= sFifo.lDimX;
      if ( lError )
	{
	  printf("\nError reading data for ADC %d.\n",sMdh.ulScanCounter);
	  break;
	}


      // Process data only after all channels have been read.
      if ( sMdh.ulChannelId == sMdh.ushUsedChannels - 1 )
	{
	  if ( STREAM_RAW )
	    {
	      // Simply write out the data for raw streaming.
	      lError = fwrite((char *)(sFifo.FCData), sizeof(FCOMPLEX), lLengthFifoData, file_raw) != lLengthFifoData;
	      if ( lError )
		{
		  printf("\nError streaming the raw data (points in last write = %d).\n", lError);
		  return FALSE;
		}
	    }
	  else
	    {
	      //
	      // Call the "online" IceFake function when all channels have been read.
	      // Note that the structure of the raw data file (e.g., "meas.out")
	      // separates channels with headers (sMdh), but all channels are 1st combined
	      // here in order to simulate the way it is done on the scanner, where
	      // one call of the online function has all the channel data.
	      //
	      ok = IceFake_online( &sMdh, &sFifo );
	      if ( !ok )
		{
		  printf("\nError returned from IceFake_online.\n");
		  exit(1);
		}
	    }
	}
    }

  ok = IceFake_offline();
  printf("\n\n");

  exit(0);
}

int read_MrProt(char *sMeasOut_name )
{
  char sMrProt_name[LEN_STR];
  char sLine[LEN_STR], sParameter[LEN_STR], sValue[LEN_STR], *psRemainder;
  int lNumber, lRepetitions, lRampMode;
  FILE *MrProt_file;
  
  // Convert the input file name (.out) to a file of type .asc
  if ( Replace_Extension(sMeasOut_name, "asc", sMrProt_name) ) return(1);

  // Open the file for reading.
  if ( !(MrProt_file = fopen(sMrProt_name,"r")) )
    {
      printf("\nError: cannot open the MrProt file (extension .asc).\n");
      return(1);
    }

  lRepetitions = 0;
  MrProt.lSegments = 1;
  MrProt.lNumberOfChannels = 0;
  MrProt.swap_PE = FALSE;
  MrProt.lFlyBack = 1;
  MrProt.lRampMode = 0;  // trapezoidal = default
  MrProt.lFIDNav = 0;
  // Read each line of the file
  while ( fgets(sLine, LEN_STR, MrProt_file) != NULL )
    {
      //
      // if ( sLine[0] == 35 )
      // continue;
      //        else if ( sLine[0] == 0 )
      // break;
      //
      //
      // Each line is of the type:
      //      parameter = value
      //
      sscanf(sLine,"%s",sParameter);                                   // Pick off parameter name
      psRemainder = psNextNonWhite( sLine + strlen(sParameter) );      // Move to "=" character
      sscanf(psRemainder,"%s",sValue);
      psRemainder = psNextNonWhite( psRemainder + strlen(sValue) );    // The remainder is the value string
      sscanf(psRemainder,"%s",sValue);
      //
      // Pick the values of important parameters.
      //
      lNumber = 1;
      if ( !strcmp(sParameter,"sKSpace.lBaseResolution") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lBaseResolution));
      else if ( !strcmp(sParameter,"sKSpace.lPhaseEncodingLines") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lPhaseEncodingLines));
      else if ( !strcmp(sParameter,"sFastImaging.lSegments") )
	{
	  lNumber = sscanf(psRemainder,"%d",&(MrProt.lSegments));
	  //	  if ( MrProt.lSegments > 1 ) MrProt.lFlyBack = 2;
	}
      else if ( !strcmp(sParameter,"sSliceArray.lSize") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lSlices));
      else if ( !strcmp(sParameter,"lRepetitions") )
	lNumber = sscanf(psRemainder,"%d",&lRepetitions);
      else if ( !strcmp(sParameter,"lScanTimeSec") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lScanTimeSec));
      else if ( !strcmp(sParameter,"lTotalScanTimeSec") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lTotalScanTimeSec));
      else if ( !strcmp(sParameter,"alTE[0]") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lTE));
      else if ( !strcmp(sParameter,"alTR[0]") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lTR));
      else if ( !strcmp(sParameter,"sWiPMemBlock.alFree[4]") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lDummyScans));
      else if ( !strcmp(sParameter,"sWiPMemBlock.alFree[14]") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lADCDuration));
      else if ( !strcmp(sParameter,"sWiPMemBlock.alFree[15]") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lRampTime));
      else if ( !strcmp(sParameter,"sWiPMemBlock.alFree[16]") )
	lNumber = sscanf(psRemainder,"%d",&(MrProt.lFlatTime));
      else if ( !strcmp(sParameter,"sWiPMemBlock.alFree[17]") )
	{
	  lNumber = sscanf(psRemainder,"%d",&(MrProt.lFIDNav));
	  if ( MrProt.lFIDNav != 1 )
	    MrProt.lFIDNav = 0;
	  else
	    MrProt.lFIDNav = 2;
	}
      else if ( !strcmp(sParameter,"sRXSPEC.aFFT_SCALE[0].flFactor") )
	{
	  lNumber = sscanf(psRemainder,"%f",&(MrProt.fScaleFT));
	  MrProt.lNumberOfChannels++;
	  MrProt.fScaleFT /= 4;
	}
      else if ( !strcmp(sParameter,"m_aflRegridADCDuration") )
	{
	  psRemainder++; // step one space to get past '[' character
	  lNumber = sscanf(psRemainder,"%d",&(MrProt.lADCDuration));
	}
      else if ( !strcmp(sParameter,"m_alRegridRampupTime") )
	{
	  psRemainder++; // step one space to get past '[' character
	  lNumber = sscanf(psRemainder,"%d",&(MrProt.lRampTime));
	}
      else if ( !strcmp(sParameter,"m_alRegridFlattopTime") )
	{
	  psRemainder++; // step one space to get past '[' character
	  lNumber = sscanf(psRemainder,"%d",&(MrProt.lFlatTime));
	}
      else if ( !strcmp(sParameter,"sSliceArray.asSlice[0].dInPlaneRot") )
	MrProt.swap_PE = TRUE;
      else if ( !strcmp(sParameter,"sRXSPEC.aFFT_SCALE[1].flFactor") )
	MrProt.lNumberOfChannels++;
      else if ( !strcmp(sParameter,"sRXSPEC.aFFT_SCALE[2].flFactor") )
	MrProt.lNumberOfChannels++;
      else if ( !strcmp(sParameter,"sRXSPEC.aFFT_SCALE[3].flFactor") )
	MrProt.lNumberOfChannels++;
      else if ( !strcmp(sParameter,"sRXSPEC.aFFT_SCALE[4].flFactor") )
	MrProt.lNumberOfChannels++;
      else if ( !strcmp(sParameter,"sRXSPEC.aFFT_SCALE[5].flFactor") )
	MrProt.lNumberOfChannels++;
      else if ( !strcmp(sParameter,"sRXSPEC.aFFT_SCALE[6].flFactor") )
	MrProt.lNumberOfChannels++;
      else if ( !strcmp(sParameter,"sRXSPEC.aFFT_SCALE[7].flFactor") )
	MrProt.lNumberOfChannels++;
      else if ( !strcmp(sParameter,"m_alRegridMode") )
	{
	  if ( !strcmp(sValue,"[4") )
	    MrProt.lRampMode = 1;  // sinusoidal ramps
	}
      if ( lNumber != 1 )
	{
	  printf("\nError reading a parameter value from the MrProt file (extension .asc).\n");
	  return(1);
	}
    }
  fclose(MrProt_file);

  MrProt.lTimePoints = lRepetitions+1;
  MrProt.lNyPerSeg   = MrProt.lPhaseEncodingLines / MrProt.lSegments;

  return(0);
}

char *psNextNonWhite( char *ps )
{
  while ( *ps == ' ' || *ps == 9 ) ps++;
  return( ps );
}

void swap_32( void *ptr )
{
  unsigned char uc, *ucptr;

  //
  // ucptr= (unsigned char*)ptr;
  // uc= *ucptr;     *ucptr= *(ucptr+3); *(ucptr+3)= uc;
  // uc= *(ucptr+1); *ucptr= *(ucptr+2); *(ucptr+2)= uc;
  //
  ucptr= (unsigned char*)ptr;
  uc= *ucptr;     *ucptr= *(ucptr+3); *(ucptr+3)= uc;
  uc= *(ucptr+1); *(ucptr+1) = *(ucptr+2); *(ucptr+2)= uc;

  return;
}

int Replace_Extension( char *file_name, char *extension, char *new_file_name )
{
  char *cptr;

  strcpy(new_file_name,file_name);
  if ( (cptr=strrchr(new_file_name,'.')) )
    strcpy(cptr+1,extension);
  else
    {
      printf("\nError: the file name has no extension!\n");
      return(1);
    }
  return(0);
}
