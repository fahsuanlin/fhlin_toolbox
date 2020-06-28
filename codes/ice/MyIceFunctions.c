// This files contains all "MyIce" functions,
// which are functions designed to replicate
// Siemens Ice functions like Ice.Ft.  By utilizing
// these functions within another c program that
// is designed like an online Ice program, recon
// can performed on a standalone system (e.g., Linux)
// from raw data file (meas.out) and headers (MrProt.asc).

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <varargs.h>
#include "MyIce.h"

FCOMPLEX *fcomplex_vector(long lLength);
void free_fcomplex_vector(FCOMPLEX *vector);
double ham_sinc( double x );


BOOL MyIce_CreateRaw( ICE_RAW *Object,
		      short lDimX,
		      short lDimY,
		      short lDimZ,
		      short lDimC )
{
  long j;

  Object->lDimX = lDimX;
  Object->lDimY = lDimY;
  Object->lDimZ = lDimZ;
  Object->lDimC = lDimC;
  Object->lLength = lDimX * lDimY * lDimZ * lDimC;

  Object->FCData = fcomplex_vector(Object->lLength);

  MyIce_PresetRaw( Object, 0., 0. );

  return TRUE;
}

BOOL MyIce_CreateIma( ICE_IMA *Object,
		      short lDimX,
		      short lDimY )
{
  short *short_vector();
  long j;

  Object->lDimX = lDimX;
  Object->lDimY = lDimY;
  Object->lLength = lDimX * lDimY;
  Object->sData = short_vector(Object->lLength);

  MyIce_PresetIma( Object, 0 );

  return TRUE;
}

BOOL MyIce_InitRaw(ICE_RAW *Object, ICE_RAW_AS *As, long lY, long lZ)
{
  long lOffset;
  
  // Specified points must be in range in each dimension.
  if ( lY < 0 || lY >= Object->lDimY )
    {
      printf("\nError: Raw access specifier is out of range in Y.\n");
      return FALSE;
    }
  if ( lZ < 0 || lZ >= Object->lDimZ )
    {
      printf("\nError: Raw access specifier is out of range in Z.\n");
      return FALSE;
    }

  As->Object = Object;
  As->lDimX  = Object->lDimX;
  if ( lY == 0 )
    {
      // give Y full dimension to indicate image boundary.
      As->lDimY = Object->lDimY;
      if ( lZ == 0 )
	// give Z full dimension to indicate volume boundary.
	As->lDimZ = Object->lDimZ;
      else
	As->lDimZ = 1;
    }
  else
    // For calls in the middle of an image (y!=0), set y and z dimensions to 1.
    As->lDimY = As->lDimZ = 1;
  As->lDimC = Object->lDimC;

  // Set the data location for the given (x,y) pair in the 1st channel
  lOffset = Object->lDimX * ( Object->lDimY * lZ + lY );
  As->FCData = Object->FCData + lOffset;

  // Set the offset between channels.
  As->lOffsetChan = Object->lDimX * Object->lDimY * Object->lDimZ;

  // Y offset always starts as zero.
  As->lOffsetY = 0;

  return TRUE;
}

void MyIce_PresetRaw( ICE_RAW *Object, float real, float imag )
{
  long j;
  for (j=0; j<Object->lLength; j++)
    {
      Object->FCData[j].re = real;
      Object->FCData[j].im = imag;
    }
}

void MyIce_PresetIma( ICE_IMA *Object, short sValue )
{
  long j;
  for (j=0; j<Object->lLength; j++)
    Object->sData[j] = sValue;
}

void MyIce_ClipFifo( FIFO *sFifo )
{
  // Reduce the operations length to 1/2 the original length.
  sFifo->lDimXOp = sFifo->lDimX/2;
  // Move the operations pointer by 1/2 the reduced length.
  sFifo->FCDataOp = sFifo->FCData + sFifo->lDimXOp/2;
}

BOOL MyIce_CopyLine( ICE_RAW_AS *As_dest, ICE_RAW_AS *As_source )
{
  FCOMPLEX *FCData_dest, *FCData_source;
  int jChan, jX, jY, lOffset;

  // Make sure the dimensions are the same.
  if ( As_dest->lDimX != As_source->lDimX )
    {
      printf("\nError: Destination and source X dimensions are not equal in MyIce_Copy.\n");
      return FALSE;
    }
  else if ( As_dest->lDimC != As_source->lDimC )
    {
      printf("\nError: Destination and source channel dimensions (%d, %d) nare not equal in MyIce_Copy.\n",
	     As_dest->lDimC, As_source->lDimC);
      return FALSE;
    }
  // There is always an implicit loop over channels.
  for (jChan=0; jChan<As_dest->lDimC; jChan++)
    {
      // Set the offset for each channel.
      lOffset       = jChan * As_dest->lOffsetChan;
      FCData_dest   = As_dest->FCData   + lOffset;  // offset for destination
      lOffset       = jChan * As_source->lOffsetChan;
      FCData_source = As_source->FCData + lOffset;  // offset for source
      for ( jX=0; jX<As_dest->lDimX; jX++ )
	FCData_dest[jX] = FCData_source[jX];
    }
}

BOOL MyIce_ReflectLine( FIFO *sFifo, sMDH *sMdh )
{
  long lSwap1, lSwap2, jX, jChan, lOffset;
  FCOMPLEX FCBuffer, *FCData;

#ifdef VA15
  if ( sMdh->ulEvalInfoMask & MDH_REFLECT )
#else
  if ( sMdh->aulEvalInfoMask[0] & MDH_REFLECT )
#endif
    {
      // There is always an implicit loop over channels.
      for (jChan=0; jChan<sFifo->lDimC; jChan++)
	{
	  // Set the offset for each channel.
	  // Step by lDimX, not lDimXOp, since the original array is intact
	  lOffset = jChan * sFifo->lDimX;
	  // The offset starts at the shifted location (FCDataOp).
	  FCData = sFifo->FCDataOp + lOffset;
	  // Simply time-reverse the data line;
	  for (jX=0; jX < sFifo->lDimXOp/2; jX++)
	    {
	      lSwap1 = jX ;
	      lSwap2 = sFifo->lDimXOp  - jX - 1;
	      FCBuffer = FCData[lSwap1] ;
	      FCData[lSwap1] = FCData[lSwap2] ;
	      FCData[lSwap2] = FCBuffer;
	    }
	}
    }
  return TRUE;
}

BOOL MyIce_FTX( FIFO *sFifo )
{
  FCOMPLEX *FCData;
  float *fData;
  long jChan, lOffset;

  // There is always an implicit loop over channels.
  for (jChan=0; jChan<sFifo->lDimC; jChan++)
    {
      // Set the offset for each channel.
      // Step by lDimX, not lDimXOp, since the original array is intact.
      lOffset = jChan * sFifo->lDimX;
      // The offset starts at the shifted location (FCDataOp).
      FCData = sFifo->FCDataOp + lOffset;

      // Reorder the data on input to "wrap-around" order.
      swap_x( FCData, sFifo->lDimXOp );

      // Transform the data.
      fData = &FCData->re;
      four1( fData-1, (int)sFifo->lDimXOp, -1 );

      // The data comes out of the fft routine in wrap-around order.
      swap_x( FCData, sFifo->lDimXOp );
    }

  return TRUE;
}

BOOL MyIce_FTY( ICE_RAW_AS *As )
{
  FCOMPLEX *FCTemp1D, *FCData;
  float *fData;
  long jX, jY, jChan, lOffset, index, index_new;
  
  //
  // Allocate a temporary array for tranposing the data.
  //
  FCTemp1D = fcomplex_vector(As->lDimY);

  // There is always an implicit loop over channels.
  for (jChan=0; jChan<As->lDimC; jChan++)
    {
      // Set the offset for each channel.
      lOffset = jChan * As->lOffsetChan;
      FCData = As->FCData + lOffset;
      //
      // Loop over the X lines.
      //
      for ( jX=0; jX<As->lDimX; jX++ )
	{
	  // Make a 1D Y vector
	  for ( jY=0; jY<As->lDimY; jY++ )
	    {
	      index        = (jY+As->lOffsetY) * As->lDimX + jX;
	      FCTemp1D[jY] = FCData[index];
	    }
	  
	  // 1D Transform
	  // Reorder the data on input to "wrap-around" order.
	  swap_x( FCTemp1D, As->lDimY );
	  // Transform the data.
	  fData = &FCTemp1D->re;
	  four1( fData-1, (int)As->lDimY, -1 );
	  // The data comes out of the fft routine in wrap-around order.
	  swap_x( FCTemp1D, As->lDimY );
	  
	  // Put the transformed data back into the original matrix.
	  for ( jY=0; jY<As->lDimY; jY++ )
	    {
	      index         = (jY+As->lOffsetY) * As->lDimX + jX;
	      FCData[index] = FCTemp1D[jY];
	    }
	}
    }
  free_fcomplex_vector(FCTemp1D);

  return TRUE;
}

BOOL MyIce_ModifyY( ICE_RAW_AS *As, long lOffsetY, long lLength)
{
  long jX, jY, jY1, jYRel, jChan;
  long lWidth=5, lY, lYLow, lYHigh, index, lOffset;
  float fYNew, fYScale, coeff[11], sum_coeff;
  FCOMPLEX *FCData, *FCTempData, FCSumY;

  // This function changes the Object data.

  // If nothing is to be done here, simply return.
  if ( lOffsetY == 0 && lLength == As->lDimY )
    return TRUE;

  // This function can only clip.
  if ( lOffsetY < 0 || lLength > As->lDimY )
    {
      printf("\nError: Y can be clipped, but not extended!  See MyIce_ModifyY.\n");
      return FALSE;
    }

  // The Y dimension better not be 0.
  if ( As->lDimY == 0 )
    {
      printf("\nError: 0-length access specifier in Y.  Use ModifyY only on image boundaries.\n");
      return FALSE;
    }

  fYScale = (float)lLength / (float)(As->lDimY);
  /*
  ** Allocate space for the new data matrix.
  */
  FCTempData = fcomplex_vector(As->lDimX*As->lDimY);
  // There is always an implicit loop over channels.
  for (jChan=0; jChan<As->lDimC; jChan++)
    {
      // Set the offset for each channel.
      lOffset = jChan * As->lOffsetChan;
      FCData = As->FCData + lOffset;
      for (jX=0; jX<As->lDimX*As->lDimY; jX++)
	FCTempData[jX] = FCData[jX];  // make a copy of the channel data
      for (jY=0; jY<As->lDimY; jY++)
	{
	  fYNew = 1. / fYScale * jY;
	  // Define coefficients for weighting of neighbors
	  lYLow  = floor((double)fYNew);
	  lYHigh = ceil((double)fYNew);
	  for (jY1=lYHigh-lWidth, jYRel=0; jY1<lYLow+lWidth; jY1++, jYRel++)
	    coeff[jYRel] = ham_sinc((double)(fYNew-jY1));
	  // Loop over x.
	  for (jX=0; jX<As->lDimX; jX++)
	    {
	      // For each Y (above loop), sum contributions from neighboring Ys.
	      for (jY1=lYHigh-lWidth, jYRel=0, FCSumY.re=FCSumY.im=sum_coeff=0.;
		   jY1<lYLow +lWidth;
		   jY1++, jYRel++)
		{
		  lY = jY1;
		  if ( lY < 0 )         lY += As->lDimY;  // wrap around in Y
		  if ( lY >= As->lDimY) lY -= As->lDimY;
		  index = lY*As->lDimX + jX;  // neighbor
		  FCSumY.re += coeff[jYRel] * FCTempData[index].re;
		  FCSumY.im += coeff[jYRel] * FCTempData[index].im;
		  sum_coeff += coeff[jYRel];
		}
	      index = jY*As->lDimX + jX;  // original array
	      FCData[index].re = FCSumY.re;
	      FCData[index].im = FCSumY.im;
	    }
	}
    }
  free_fcomplex_vector(FCTempData);
  //  As->lOffsetY = lOffsetY;
  As->lDimY    = lLength;

  return TRUE;
}

double ham_sinc( x )
double x;
{
  double ham;
  
  if ( fabs(x) < 1.0e-5 )
    ham = 1.0;
  else
    {
      ham = sin(PI*x)/(PI*x);
      ham *= 0.54 + 0.46 * cos(2.*PI*x/10.);
    }
  return(ham);
}

void swap_x( FCOMPLEX *FCData, long lDim )
{
  FCOMPLEX FCBuffer;
  long j, lSwap1, lSwap2;

  // Swap x line segments.
  for (j=0; j<lDim/2; j++)
    {
      lSwap1 = j;
      lSwap2 = lSwap1 + lDim/2;
      FCBuffer       = FCData[lSwap1];
      FCData[lSwap1] = FCData[lSwap2];
      FCData[lSwap2] = FCBuffer;
    }
}

BOOL MyIce_AccumulateFifo(ICE_RAW_AS *As, FIFO *sFifo, BOOL Add)
{
  long lOffset, jChan, jX;
  FCOMPLEX *FCData_raw, *FCData_fifo;
  float fAvThis, fAvNext, fWeightOld, fWeightNew;

  if ( sFifo->lDimXOp != As->lDimX )
    {
      printf("\nError: Fifo X and raw data dimensions differ in MyIce_AccumulateFifo.\n");
      return FALSE;
    }

  // There is always an implicit loop over channels.
  for (jChan=0; jChan<As->lDimC; jChan++)
    {
      // Set the offset for each channel.
      lOffset = jChan * As->lOffsetChan;    // offset for raw data array
      FCData_raw = As->FCData + lOffset;
      // Step by lDimX, not lDimXOp, since the original array is intact.
      lOffset = jChan * sFifo->lDimX;               // offset for fifo
      FCData_fifo = sFifo->FCDataOp + lOffset;  // starts at FCDataOp

      if ( Add )
	{
	  // Add the source to the destination.
	  //
	  for (jX=0; jX<sFifo->lDimXOp; jX++)
	    {
	      FCData_raw[jX].re += FCData_fifo[jX].re;
	      FCData_raw[jX].im += FCData_fifo[jX].im;
	    }
	}
      else
	{
	  // Set the destination equal to the source.
	  for (jX=0; jX<sFifo->lDimXOp; jX++)
	    {
	      FCData_raw[jX].re = FCData_fifo[jX].re;
	      FCData_raw[jX].im = FCData_fifo[jX].im;
	    }
	}
    }
  return TRUE;
}

BOOL MyIce_ExtractComplex(ICE_RAW_AS *As_mag, ICE_RAW_AS *As_raw, long lType, float fScaleFactor)
{
  FCOMPLEX *FCData_mag, *FCData_raw;
  long jX, jY, jChan, lOffset, index_mag, index_raw;
  float rPixel, compute_phase();
  double x2, y2;

  // Make sure the dimensions are the same.
  if ( As_mag->lDimX != As_raw->lDimX )
    {
      printf("\nError: Magnitude and raw X dimensions are not equal in MyIce_ExtractComplex.\n");
      return FALSE;
    }
  else if ( As_mag->lDimY  != As_raw->lDimY )
    {
      printf("\nError: Magnitude and raw Y dimensions (%d, %d) are not equal in MyIce_ExtractComplex.\n",
	     As_mag->lDimY, As_raw->lDimY);
      return FALSE;
    }
  else if ( As_mag->lDimC != As_raw->lDimC )
    {
      printf("\nError: Magnitude and raw channel dimensions are not equal in MyIce_ExtractComplex.\n");
      return FALSE;
    }

  // There is always an implicit loop over channels.
  for (jChan=0; jChan<As_raw->lDimC; jChan++)
    {
      // Set the offset for each channel.
      lOffset = jChan * As_mag->lOffsetChan;  // offset for mag
      FCData_mag = As_mag->FCData + lOffset;
      // Set the offset for each channel.
      lOffset = jChan * As_raw->lOffsetChan;  // offset for raw
      FCData_raw = As_raw->FCData + lOffset;

      for ( jY=0; jY<As_mag->lDimY; jY++ )
	{
	  for ( jX=0; jX<As_mag->lDimX; jX++ )
	    {
	      index_mag = (jY + As_mag->lOffsetY) * As_mag->lDimX + jX;
	      index_raw = (jY + As_raw->lOffsetY) * As_raw->lDimX + jX;
	      switch (lType)
		{
		case REAL:
		  rPixel = FCData_raw[index_raw].re * fScaleFactor * 20000.;
		  break;
		case IMAGINARY:
		  rPixel = FCData_raw[index_raw].im * fScaleFactor * 20000.;
		  break;
		case PHASE:
		  rPixel = compute_phase( FCData_raw[index_raw] ) * 36000./PI;
		  break;
		case AMPLITUDE:  // amplitude
		  x2 = FCData_raw[index_raw].re * FCData_raw[index_raw].re;
		  y2 = FCData_raw[index_raw].im * FCData_raw[index_raw].im;
		  rPixel = sqrt((double)(x2 + y2)) * fScaleFactor * 20000.;
		  // printf("pixel = %d\n",sPixel);
		  break;
		default:
		  printf("\nThe requested image type is not supported.\n");
		  return FALSE;
		}
	      FCData_mag[index_mag].re = rPixel;
	      FCData_mag[index_mag].im = 0.;
	    }
	}
    }
  return TRUE;
}

BOOL MyIce_CombineChannels(ICE_IMA *Object, ICE_RAW_AS *As)
     // The Object is an image (IMA) type object with short data and 2 dimensions.
     // The Access Specifier should contain only real data (see ExtractComplex).
{
  FCOMPLEX *FCData;
  long jX, jY, jChan, lOffset, index;
  float rPixel;

  // Make sure the dimensions are the same.
  if ( As->lDimX != Object->lDimX )
    {
      printf("\nError: Magnitude and raw X dimensions are not equal in MyIce_ExtractComplex.\n");
      return FALSE;
    }
  else if ( As->lDimY > Object->lDimY )
    {
      printf("\nError: Y dimension of multi-channel data > Y dimension of image object.\n");
      return FALSE;
    }

  //
  // Sum over the image (x,y), combining channels.
  //
  for (jY=0; jY<As->lDimY; jY++)
    {
      for (jX=0; jX<As->lDimX; jX++)
	{
	  index = (jY+As->lOffsetY) * As->lDimX + jX;
	  rPixel = 0.;
	  for (jChan=0; jChan<As->lDimC; jChan++)
	    //	  for (jChan=1; jChan<2; jChan++)
	    {
	      // Set the offset for each channel.
	      lOffset = jChan * As->lOffsetChan;  // offset for channel
	      FCData  = As->FCData + lOffset;     // beginning of (x,y) data
	      if ( FCData[index].im != 0. )
		{
		  printf("\nError: Imaginary part of `real' object != 0 in CombineChannels.\n");
		  exit(1);
		}
	      // Combine using the sum of squares.
	      rPixel += FCData[index].re * FCData[index].re;
	    }
	  // SQRT, plus normalization for # channels.
	  rPixel = sqrt((double)rPixel) / sqrt((double)As->lDimC);
	  // Truncate into short integer.
	  // Let ExtractComplex take care of scaling.
	  Object->sData[index] = rPixel;
	}
    }
}

BOOL MyIce_SendIma( ICE_IMA *Object, FILE *file )
{
  long lError;

  //  printf("************** sending object **************\n");
  //  printf("length = %d\n",Object->lLength);
  lError = fwrite((char *)(Object->sData), sizeof(short), Object->lLength,file) != Object->lLength;
  if ( lError )
    {
      printf("\nError writing the bshort output file (points in last write = %d).\n", lError);
      return FALSE;
    }
  return TRUE;
}

BOOL MyIce_NormOrientation( ICE_IMA *Object, BOOL swap_PE )
{
  short sBuffer, sTemp1, sTemp2, sTemp3, sTemp4;
  long  jX, jY,  lSwap1, lSwap2, lSwap3, lSwap4;

  if ( !swap_PE )
    {
      // Mirror the data in x.
      sBuffer = 0;
      for ( jY=0; jY<Object->lDimY; jY++ )
  	{
  	  for ( jX=0; jX<Object->lDimX/2; jX++ )
  	    {
  	      lSwap1 = jY     * Object->lDimX + jX;
  	      lSwap2 = (jY+1) * Object->lDimX - jX - 1;
	      sBuffer = Object->sData[lSwap1];
	      Object->sData[lSwap1] = Object->sData[lSwap2];
	      Object->sData[lSwap2] = sBuffer;
  	    }
  	}
    }
  else
    {
      // Make sure the X and Y dimensions are the same.
      if ( Object->lDimX != Object->lDimY )
	{
	  printf("Error: x and y dimensions must be the same for an image rotation.\n");
	  return FALSE;
	}
      printf("rotate using dimension %ld\n",Object->lDimX);
      // Rotate the data.
      for ( jY=0; jY<Object->lDimY/2; jY++ )
	{
	  for ( jX=0; jX<Object->lDimX/2; jX++ )
	    {
	      lSwap1 =  jY*Object->lDimX + jX;
	      lSwap2 =  jX*Object->lDimY + (Object->lDimY-jY-1);                 /* x -> -y  , y -> x */
	      lSwap3 = (Object->lDimY-jY-1)*Object->lDimY +(Object->lDimX-jX-1); /* x -> -x  , y -> -y */
	      lSwap4 = (Object->lDimX-jX-1)*Object->lDimY + jY;                  /* x ->  y  , y -> -x */
	      sTemp1 = Object->sData[lSwap1]; sTemp2 = Object->sData[lSwap2];
	      sTemp3 = Object->sData[lSwap3]; sTemp4 = Object->sData[lSwap4];
	      // Angle = 90
	      //	      Object->sData[lSwap1] = sTemp2;
	      //	      Object->sData[lSwap2] = sTemp3;
	      //	      Object->sData[lSwap3] = sTemp4;
	      //	      Object->sData[lSwap4] = sTemp1;
	      // Angle = -90
	      Object->sData[lSwap1] = sTemp4;
	      Object->sData[lSwap2] = sTemp1;
	      Object->sData[lSwap3] = sTemp2;
	      Object->sData[lSwap4] = sTemp3;
	    }
	}
    }
  return TRUE;
}

#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr
void four1(float data[], int nn, int isign)
{
  int n,mmax,m,j,istep,i;
  double wtemp,wr,wpr,wpi,wi,theta;
  float tempr,tempi;
  
  n=nn << 1;
  j=1;
  for (i=1;i<n;i+=2) {
    if (j > i) {
      SWAP(data[j],data[i]);
      SWAP(data[j+1],data[i+1]);
    }
    m=n >> 1;
    while (m >= 2 && j > m) {
      j -= m;
      m >>= 1;
    }
    j += m;
  }
  mmax=2;
  while (n > mmax) {
    istep=2*mmax;
    theta=6.28318530717959/(isign*mmax);
    wtemp=sin(0.5*theta);
    wpr = -2.0*wtemp*wtemp;
    wpi=sin(theta);
    wr=1.0;
    wi=0.0;
    for (m=1;m<mmax;m+=2) {
      for (i=m;i<=n;i+=istep) {
	j=i+mmax;
	tempr=wr*data[j]-wi*data[j+1];
	tempi=wr*data[j+1]+wi*data[j];
	data[j]=data[i]-tempr;
	data[j+1]=data[i+1]-tempi;
	data[i] += tempr;
	data[i+1] += tempi;
      }
      wr=(wtemp=wr)*wpr-wi*wpi+wr;
      wi=wi*wpr+wtemp*wpi+wi;
    }
    mmax=istep;
  }
}
#undef SWAP

BOOL MyIce_WriteRawToFile(ICE_RAW_AS *As_raw, char *BfloatFileName)
{
  static int ntime = 1;
  char HdrFileName[LEN_STR];
  FILE *file;
  FCOMPLEX *FCData;
  long lDim, lError;

  // Make the bshort header file name;
  if ( Replace_Extension(BfloatFileName, "hdr", HdrFileName) )
    {
      printf("\nError constructing the output file name header %s.\n",HdrFileName);
      return FALSE;
    }
  // Open and write the header file.
  if ( !(file = fopen(HdrFileName,"w")) )
    {
      printf("Error opening file %s in WriteRawToFile.\n",HdrFileName);
      return FALSE;
    }
  fprintf(file,"%d %d %d %d\n",
	  As_raw->lDimY,                     // Y
	  As_raw->lDimX * 2,                 // X (complex)
	  As_raw->lDimZ*As_raw->lDimC*ntime, // Z * channels * time points
	  1);
  fprintf(file,"chan %d\n",As_raw->lDimC);
  fprintf(file,"z %d\n",As_raw->lDimZ);
  fprintf(file,"time %d\n",ntime);
  fclose(file);

  // Open the bfloat file.
  if ( ntime == 1 )
    lError = !(file = fopen(BfloatFileName,"w"));
  else
    lError = !(file = fopen(BfloatFileName,"a"));
  if ( lError )
    {
      printf("Error opening file %s in WriteRawToFile.\n",BfloatFileName);
      return FALSE;
    }

  lDim = As_raw->lDimX * As_raw->lDimY * As_raw->lDimZ * As_raw->lDimC;
  lError = fwrite((char *)(As_raw->FCData), sizeof(FCOMPLEX), lDim, file) != lDim;
  if ( lError )
    {
      printf("\nError writing the bshort output file (points in last write = %d).\n", lError);
      return FALSE;
    }
  fclose(file);

  ntime++;
  return TRUE;
}
