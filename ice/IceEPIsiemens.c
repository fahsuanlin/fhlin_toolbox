#include <stdio.h>
#include <string.h>
#include <math.h>
#include <varargs.h>
#include "../MyIce.h"
#include "../MrProtocol.h"
#include "IceEPIsiemens.h"

// EPI phase corrections (global)
float EPI_Phase_Slope;
float EPI_Phase_Offset;
long lADC_Expected, lADC_Actual;

#ifdef VA15

#define ODD_LINE  (sMdh->ulEvalInfoMask & MDH_REFLECT)
#define LAST_SCAN (sMdh->ulEvalInfoMask & MDH_LASTSCANINSLICE)
#define PHASE_CORR (sMdh->ulEvalInfoMask & MDH_PHASCOR)

#else

#define ODD_LINE   (sMdh->aulEvalInfoMask[0] & MDH_REFLECT)
#define LAST_SCAN  (sMdh->aulEvalInfoMask[0] & MDH_LASTSCANINSLICE)
#define PHASE_CORR (sMdh->aulEvalInfoMask[0] & MDH_PHASCOR)

#endif


BOOL IceFake_prepare()
{
  BOOL ok = TRUE;

  // Find the number of expected ADC reads.  This will enable consistency checks.
  lADC_Expected = MrProt.lSegments * ( MrProt.lNyPerSeg + 3 )
    * MrProt.lSlices * MrProt.lTimePoints;
  lADC_Actual = 0;

  // if ( !check_validity() ) return FALSE;

  init_attributes();    

  // Create the raw data vector.  This should handle everything but repetitions (time points).
  MyIce_CreateRaw(&Ob_raw,
		  m_NxRaw,     // COL
		  m_NyFT,      // LIN
		  m_Nz,        // SLC
		  m_NChan);    // CHAN
  // Create a reference vector for EPI phase correction data.
  MyIce_CreateRaw(&Ob_ref,
		  m_NxRaw,     // COL
		  2,           // LIN: either even or ordd
		  m_Nz,        // SLC
		  m_NChan);    // CHAN
  // Create an object for magnitude images in separate channels.
  MyIce_CreateRaw(&Ob_mag,
		  m_NxImage,   // COL
		  m_NyImage,   // LIN
		  1,           // SLC
		  m_NChan);    // CHAN

  // Create an image object (combined across channels)
  // This can only be 2-dimensional.
  MyIce_CreateIma(&Ob_ima,
		  m_NxImage,   // COL
		  m_NxImage);  // LIN
  // Create the image mosaic object.
  // This can only be 2-dimensional.
  MyIce_CreateIma(&Ob_mos,
		  m_1dPanels * m_DimPanel,   // COL
		  m_1dPanels * m_DimPanel);  // LIN
  
  // Initialize the regridding algorithm.
  ok = Trapezoid_init(MrProt.lRampTime,     // time for one ramp of trapezoid
		      MrProt.lFlatTime,     // flat time of trapezoid
		      MrProt.lADCDuration,  // ADC duration
		      2*m_NxRaw,            // # x points to resample
		      MrProt.lRampMode);    // sinusiodal ramps? (logical variable)
  if ( !ok )
    {
      printf("\nError initializing re-gridding algorithm.\n");
      return FALSE;
    }
  
  // Write the xds header file.
  fprintf( MrProt.FileBshortOut, "%d %d %d %d \n",
	   m_1dPanels * m_DimPanel,     // Y
	   m_1dPanels * m_DimPanel,     // X
	   MrProt.lTimePoints,          // time
	   1);

  //
  // Output expectations.
  printf("Raw data:   (x, y, z, t) \r\t\t\t = (%d, %d, %d, %d) with %d channels\n",
	 m_NxRaw, m_NyRaw, m_Nz, MrProt.lTimePoints,m_NChan);
  printf("Image data: (x, y, z, t) \r\t\t\t = (%d, %d, %d, %d)\n",
	 m_NxImage, m_NyImage, m_Nz, MrProt.lTimePoints);
  printf("Mosaics:    (x, y, t) \r\t\t\t = (%d, %d, %d)\n\n",
	 m_1dPanels * m_DimPanel, m_1dPanels * m_DimPanel, MrProt.lTimePoints);

  return TRUE;
}

BOOL IceFake_online(sMDH *sMdh, FIFO *sFifo)
{
  BOOL ok;
  short do_what;
  static long lNumberVolumes=0;

  // Keep track of the number of ADCs.
  lADC_Actual++;

  // Handle Mdh flags for filling of header parameters
  ok = react_on_flags(sMdh, &do_what);
  if ( !ok ) return FALSE;

  switch (do_what)
    {
    case DO_PER_IMAGE:                    // do for each image with 2D encoding
      ok = do_per_line(sMdh, sFifo);      // last line in image
      if ( !ok ) return FALSE;
      ok = do_per_image(sMdh);            // FT in Y
      if ( !ok ) return FALSE;
      break;
    case DO_PER_IMAGE_VOLUME:             // do for each complete volume (nx, ny, nz)
      ok = do_per_line(sMdh, sFifo);      // last line in image
      if ( !ok ) return FALSE;
      ok = do_per_image(sMdh);            // FT in Y, fill mosaic
      if ( !ok ) return FALSE;
      ok = do_per_image_volume(sMdh);     // send mosaic to database
      if ( !ok ) return FALSE;
      lNumberVolumes++;
      printf("\rCompleted Volumes: %d",lNumberVolumes);
      fflush(stdout);
      break;
    case DO_IGNORE:
      break;
    default:                // do for each line that is not a special one (e.g., end of image)
      ok = do_per_line(sMdh, sFifo);    // re-grid and FT in X
      if ( !ok ) return FALSE;
    }
  return TRUE;
}

BOOL IceFake_offline()
{
  //
  // Make sure that the actual ADC reads equals the expected number.
  //
  if ( lADC_Actual != lADC_Expected )
    {
      printf(" ******** Consistency error in totals **************************\n");
      printf(" ******** Actual # ADCs (%d) did NOT match expected # ADCs (%d).\n",
	     lADC_Actual, lADC_Expected);
      return FALSE;
    }
  else
    {
      printf("\nNumber of ADCs acquired = %d\n",lADC_Actual);
      return TRUE;
    }
}

void init_attributes()
{
  long lTest, lNext;

  m_NxRaw   = MrProt.lBaseResolution;
  m_NyRaw   = MrProt.lPhaseEncodingLines;
  m_Nz      = MrProt.lSlices;
  m_NChan   = MrProt.lNumberOfChannels;
  m_NxImage = MrProt.lBaseResolution;
  m_NyImage = MrProt.lPhaseEncodingLines;
  m_NyFT    = MrProt.lPhaseEncodingLines;
  if ( !is_power_of_2( m_NyFT, &lTest, &lNext) ) m_NyFT = lNext;

  // The mosaic image will satisfy
  // 1) each panel will be square   and satisfy # pixels = 2^n in x and y
  // 2) the # panels will be square (e.g., total panels =1,2,4,9,16,25,36,...)
  //
  // CHOOSE THE SIZE OF THE PANELS:
  //
  // Find the larger of the 2 image dimensions.
  m_DimPanel = m_NxImage;
  if (m_DimPanel < m_NyImage) m_DimPanel = m_NyImage;
  // Increase this dimension (if necessary) to satisy 2^n.
  lTest=1;
  while (lTest < m_DimPanel) lTest=lTest<<1;  // bit shift: 1->2->4->8->...
  m_DimPanel = lTest;
  //
  // CHOOSE THE NUMBER OF PANELS
  //
  lTest = 1;
  while (lTest*lTest < m_Nz ) lTest++;
  m_1dPanels = lTest;

  //  printf("1d Panels = %ld, dim of panel = %ld\n",m_1dPanels,m_DimPanel);
  
  return;
}

// react on incoming flags and handle them for using this information
BOOL react_on_flags(sMDH *sMdh, short *do_what)
{
  static long lSlice = 0;

  // This is image data (2D encoding).
  if ( LAST_SCAN )
    {
      if ( lSlice == m_Nz - 1 )
	// This is the last line in an image volume.
	*do_what = DO_PER_IMAGE_VOLUME;
      else
	// This is the last line in an image.
	*do_what = DO_PER_IMAGE;
    }
  else
    // This is not the last line in an image.
    *do_what = DO_PER_LINE;
  //
  // lSlice keeps track of the volumes.  This allows the slice
  // counter (sMDH->ushSlice) to mark the anatomical (rather
  // than chronological) slice number.
  //
  if ( LAST_SCAN )
    lSlice++;
  if ( lSlice == m_Nz ) lSlice=0;

  return TRUE;
}

BOOL do_per_line(sMDH *sMdh, FIFO *sFifo)
{
  BOOL ok;
  ICE_RAW_AS As_raw;
  long lOffset, lY, lZ;

  // Regrid data.

  ok = Trapezoid_regrid( sFifo );
  if ( !ok )
    {
      printf("\nERROR regridding!\n");
      return FALSE;
    }
  
  // reflect Data if required
  if ( !MyIce_ReflectLine(sFifo, sMdh) ) return FALSE;
  
  // No "shake-in" of data into FT buffer is necessary prior to X FT for magnitude images.
  ok = MyIce_FTX( sFifo );    // in-place FT in X

  // Correct the roll-off due to the regridding convolution.
  ok  = Trapezoid_rolloff( sFifo );
  if ( !ok )
    {
      printf("\nERROR applying the roll-off correction for regridding.\n ");
      return FALSE;           
    }

  MyIce_ClipFifo(sFifo);   // clip out center part (remove oversampling);
  
  // Put the line into either the reference or data object.
  lZ = sMdh->sLC.ushSlice;
  if ( PHASE_CORR )  // reference data (3 lines) for EPI phase correction
    {
      lY = sMdh->sLC.ushSeg;  // these lines use the segment counter (0 or 1)
      //                 object specifier   Y,  Z
      ok = MyIce_InitRaw(&Ob_ref, &As_raw, lY, lZ);
      if ( !ok )
	{
	  printf("\nERROR initializing operations for accumulation (do_per_line)!\n");
	  return FALSE;
	}
      // Handle averages
      //                   (destination, source, logical)
      ok = MyIce_AccumulateFifo(&As_raw, sFifo, sMdh->sLC.ushAcquisition);
      if ( !ok )
	{
	  printf("\nERROR accumulating raw data!\n");
	  return FALSE;
	}
      // Calculate the EPI phase correction after getting the 3rd line.
      if ( sMdh->sLC.ushAcquisition == 1 )
	{
	  calc_EPI_phase_correction( sMdh->sLC.ushSlice );
	  // Clear the reference object for the next data.
	  MyIce_PresetRaw(&Ob_ref, 0., 0.);  // zero out ref data
	}
    }
  else
    {
      lOffset = (m_NyFT - m_NyImage) / 2;
      lY = sMdh->sLC.ushLine + lOffset;
      //                 object specifier   Y,  Z
      ok = MyIce_InitRaw(&Ob_raw, &As_raw, lY, lZ);
      if ( !ok )
	{
	  printf("\nERROR initializing operations for accumulation (do_per_line)!\n");
	  return FALSE;
	}
      // Handle averages
      //                   (destination, source, logical)
      ok = MyIce_AccumulateFifo(&As_raw, sFifo, sMdh->sLC.ushAcquisition);
      if ( !ok )
	{
	  printf("\nERROR accumulating raw data!\n");
	  return FALSE;
	}

      if ( ODD_LINE )
	{
	  ok = apply_epi_phase_correction( &As_raw );
	  if ( !ok )
	     {
	       printf("\nERROR attempting to apply phase correction to EPI lines.\n");
	       return FALSE;           
	     }
	}
    }
  
  return TRUE;
}

BOOL do_per_image(sMDH *sMdh)
{
  ICE_RAW_AS As_raw, As_mag;
  BOOL ok;
  long lOffset;

  // Access specifier to one slice in raw data.
  //
  //                 Object  Specifier Y,       Z
  ok = MyIce_InitRaw(&Ob_raw, &As_raw, 0, (long)sMdh->sLC.ushSlice);
  if ( !ok )
    {
      printf("\nERROR initializing raw specifier prior to y FT!\n");
      return FALSE;
    }

  // In-place FT in Y
  ok = MyIce_FTY( &As_raw );
  if ( !ok )
    {
      printf("\nERROR performing Y FT!\n");
      return FALSE;
    }

  // Handle reduced Y FOV (fewer y lines).
  // Modify As_raw for ExtractComplex (take centered part):
  lOffset = (m_NyFT - m_NyImage) / 2;
  if ( lOffset < 0 )
    {
      printf("\nERROR: PhaseFT length smaller than number of image lines!\n");
      return FALSE;
    }
  // The following function clips Y and alters the data array (if necessary).
  ok = MyIce_ModifyY(&As_raw, lOffset, m_NyImage);
  if ( !ok )
    {
      printf("\nERROR modifying As_raw for ExtractComplex!");
      return FALSE;
    }

  // Access specifier to magnitude data.
  // This must point to a multi-channel object, even though channels
  // aren't explicit here.
  //
  //                 Object  Specifier Y, Z
  ok = MyIce_InitRaw(&Ob_mag, &As_mag, 0, 0);
  if ( !ok )
    {
      printf("\nERROR initializing specifier to multi-channel magnitude object!\n");
      return FALSE;
    }
  // Extract pixel data.
  //                       (destination, source, type, scale factor)
  ok = MyIce_ExtractComplex(&As_mag, &As_raw, AMPLITUDE, MrProt.fScaleFT);
  if ( !ok )
    {
      printf("\nERROR during ExtractComplex.\n");
      return FALSE;
    }

  // Combine the channels.
  MyIce_PresetIma(&Ob_ima, 0.);  // zero out raw data
  ok = MyIce_CombineChannels(&Ob_ima, &As_mag);
  if ( !ok )
    {
      printf("\nERROR during CombineChannels.\n");
      return FALSE;
    }

  // Rotate and/or mirror to put into standard radiological orientation.
  ok = MyIce_NormOrientation(&Ob_ima, MrProt.swap_PE);

  // Put the new image into the mosaic of slices.
  update_mosaic( sMdh->sLC.ushSlice );
  
  return TRUE;
}  

BOOL do_per_image_volume(sMDH *sMdh)
{
  ICE_RAW_AS As_raw;
  BOOL ok;

  // Send the mosaic image to the file.
  if ( !MyIce_SendIma(&Ob_mos, MrProt.FileBshortOut) )
    {
      printf("\nERROR sending image to Host!\n");
      return FALSE;
    }

  //                 Object  Specifier Y, Z
  ok = MyIce_InitRaw(&Ob_raw, &As_raw, 0, 0);
  if ( !ok )
    {
      printf("\nERROR initializing raw specifier prior to WriteRawToFile.\n");
      return FALSE;
    }
  // Write the full raw data object to a file.
  if ( MyIce_WriteRawToFile( &As_raw, "raw.bfloat") ) return(1);

  MyIce_PresetRaw(&Ob_raw, 0., 0.);  // zero out raw data
  MyIce_PresetRaw(&Ob_mag, 0., 0.);  // zero out raw data
  MyIce_PresetIma(&Ob_ima, 0);       // zero out image
  MyIce_PresetIma(&Ob_mos, 0);       // zero out image

  return TRUE;
}  

BOOL update_mosaic(long lSlice)
{
  BOOL ok;
  long lxPanel, lyPanel, lxStart, lyStart, jx, jy, j;
  short *pIma, *pMos;

  // Find the right panel.
  lxPanel = lSlice % m_1dPanels;
  lyPanel = lSlice / m_1dPanels;
  // Find the x and y starting location withing the mosaic.
  lxStart = lxPanel * m_DimPanel + ( m_DimPanel - m_NxImage ) / 2;
  lyStart = lyPanel * m_DimPanel + ( m_DimPanel - m_NyImage ) / 2;
  // Insert the image into the multi-slice mosaic.
  pIma = (short*)Ob_ima.sData;
  pMos = (short*)Ob_mos.sData;
  pMos+= lyStart * m_1dPanels*m_DimPanel + lxStart;
  for (jy=0; jy<m_NyImage; jy++)
    {
      // Copy a line from the image to the mosaic.
      for (jx=0; jx<m_NxImage; jx++, pIma++, pMos++)
        *pMos = *pIma;
      pMos -= m_NxImage;              // go back to the start of the line
      pMos += m_1dPanels*m_DimPanel;  // advance one full mosaic length
    }

  return TRUE;
}

// Linear and normalize the navigator
BOOL apply_epi_phase_correction( ICE_RAW_AS *As )
{
  FCOMPLEX *FCData, FC, FCTemp;
  int jChan, jX;
  BOOL ok;
  float x, phi;

  for (jChan=0; jChan<As->lDimC; jChan++)
    {
      // Find the correct navigator line for this segment
      FCData = As->FCData + jChan * As->lOffsetChan;
      for (jX=0; jX<As->lDimX; jX++)
	{
	  x = jX - As->lDimX/2 + 0.5;
	  phi = x * EPI_Phase_Slope + EPI_Phase_Offset;
	  FC.re = cos((double)phi);
	  FC.im = sin((double)phi);
	  FCTemp.re = FCData[jX].re * FC.re - FCData[jX].im*FC.im;
	  FCTemp.im = FCData[jX].re * FC.im + FCData[jX].im*FC.re;
	  FCData[jX] = FCTemp;
        }
    }
  return TRUE;
}

BOOL MyIce_SendRaw( ICE_RAW *Object )
{
  long lError;
  FILE *file;

  //  printf("************** sending raw object **************\n");
  //  printf("length = %d\n",Object->lLength);

  file = fopen("test.hdr","w");
  // Write the xds header file.
  fprintf( file, "%d %d %d %d \n",
	   Object->lDimY,         // Y
	   Object->lDimX * 2,     // X
	   MrProt.lSlices,        // time
	   1);
  fclose(file);

  file = fopen("test.bfloat","w");
  lError = fwrite((char *)(Object->FCData), sizeof(FCOMPLEX), Object->lLength,file) != Object->lLength;
  if ( lError )
    {
      printf("\nError writing the bshort output file (points in last write = %d).\n", lError);
      return FALSE;
    }
  fclose(file);

  return TRUE;
}

BOOL is_power_of_2( long lInput, long *lLastPower, long *lNextPower )
{
  long lTest, j, lFound=0;

  lTest  = 1;
  do
    if ( (lTest*=2) == lInput ) lFound = lTest;
  while ( lTest < lInput );

  if ( lFound )
    {
      *lLastPower = lInput/2;
      *lNextPower = 2*lInput;
      return(TRUE);
    }
  else
    {
      *lLastPower = lTest/2;
      *lNextPower = lTest;
      return(FALSE);
    }
}

BOOL calc_EPI_phase_correction( long lSlice )
{
  ICE_RAW_AS As_even, As_odd;
  FCOMPLEX *FCEven, *FCOdd, *P0, *P1, FCSum, FC;
  BOOL ok;
  float slope_even, slope_odd, offset_diff, x, phi;
  int jX, jChan;

  //                  object  specifier  Y, Z
  ok  = MyIce_InitRaw(&Ob_ref, &As_even, 0, lSlice);
  ok &= MyIce_InitRaw(&Ob_ref, &As_odd,  1, lSlice);
  if ( !ok )
    {
      printf("ERROR initializing even and odd lines in do_per_ref_volume.\n");
      return FALSE;
    }

  for (jChan=0; jChan<As_even.lDimC; jChan++)
    {
      // Find the correct line for this channel.
      FCEven = As_even.FCData + jChan * As_even.lOffsetChan;
      FCOdd  = As_odd.FCData  + jChan * As_odd.lOffsetChan;
      // Find the slope of the even line.
      FCSum.re = FCSum.im = 0.;
      for (jX=0, P0=FCEven; jX<As_even.lDimX-1; jX++, P0++)
	{
	  P1 = P0 + 1;
	  FCSum.re += P1->re * P0->re + P1->im * P0->im;
	  FCSum.im += P1->re * P0->im - P1->im * P0->re;
        }
      slope_even = compute_phase( FCSum );
      // Find the slope of the odd line.
      FCSum.re = FCSum.im = 0.;
      for (jX=0, P0=FCOdd; jX<As_odd.lDimX-1; jX++, P0++)
	{
	  P1 = P0 + 1;
	  FCSum.re += P1->re * P0->re + P1->im * P0->im;
	  FCSum.im += P1->re * P0->im - P1->im * P0->re;
        }
      slope_odd = compute_phase( FCSum );

      // Find the offset between the two lines.
      FCSum.re = FCSum.im = 0.;
      for (jX=0, P0=FCEven, P1=FCOdd;
	   jX<As_even.lDimX;
	   jX++, P0++, P1++)
	{
	  FCSum.re += P1->re * P0->re + P1->im * P0->im;
	  FCSum.im += P1->re * P0->im - P1->im * P0->re;
        }
      offset_diff = compute_phase( FCSum );
    }  

  EPI_Phase_Slope  = slope_odd  - slope_even;
  EPI_Phase_Offset = offset_diff;

  // Hardwire the phase offset
  EPI_Phase_Offset = 0.;

  return TRUE;
}
