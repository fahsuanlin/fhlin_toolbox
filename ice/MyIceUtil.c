#include <stdio.h>
#include <string.h>
#include <math.h>
#include <varargs.h>
#include "MyIce.h"
#include "MyIceUtil.h"


BOOL Trapezoid_init(long lRamp,
		    long lFlat,
		    long lADC,
		    long lNx,
		    long lSinusoidal_Ramps)
{
  float *kRaw;
  float delta_time, time, renormalize, k, kn, kNew, x;
  int maxNeigh, j, jn;
  double regrid_width = 3.5, regrid_sigma = 4.91;

  Trapezoid.NxRegrid = lNx;

  // Determine the k-space coordinates as defined by the a sampling scheme
  // that starts at time lDelaySampling and continues for time lADCDuration
  // as a trapezoidal waveform plays out using the ramp and flat time as passed.
  if ( lSinusoidal_Ramps )
    renormalize = (float)(lFlat) + 4./M_PI*(float)(lRamp)*sin(M_PI/2.*((float)lADC/2.-(float)lFlat/2.)/(float)(lRamp));
  else
    renormalize = lADC - (float)( (lADC-lFlat)*(lADC-lFlat) ) / 4./(float)lRamp;
  renormalize /= (float)(Trapezoid.NxRegrid-1);
  delta_time = (float)(lADC) / (float)(Trapezoid.NxRegrid-1);

  kRaw = float_vector(Trapezoid.NxRegrid);
  // Assign positive k-space values.  Note that the max value is (Trapezoid.NxRegrid-1)/2.
  for (j=Trapezoid.NxRegrid/2; j<Trapezoid.NxRegrid; j++)
    {
      time = delta_time * ( j-Trapezoid.NxRegrid/2 + 0.5 );
      if ( time < lFlat/2 )
        kRaw[j] = time;
      else
	{
	  if ( lSinusoidal_Ramps )
	    kRaw[j] = (float)(lFlat)/2. + 2./M_PI*(float)(lRamp)*sin(M_PI/2.*(float)(time-lFlat/2.)/(float)(lRamp));
	  else
	    kRaw[j] = time - (float)( (time-lFlat/2)*(time-lFlat/2) ) /2./(float)lRamp;
	}
      kRaw[j] /= renormalize;
    }
  // Reflect the line to assign negative k-space values.
  for (j=0; j<Trapezoid.NxRegrid/2; j++)
    kRaw[j] = - kRaw[Trapezoid.NxRegrid-j-1];

  //
  // Locate the neighbors for each k-space point that fall within a given width.
  //
  Trapezoid.regrid_numberNeighbors = short_vector(Trapezoid.NxRegrid);
  Trapezoid.regrid_density         = float_vector(Trapezoid.NxRegrid);
  Trapezoid.regrid_rolloff         = fcomplex_vector(Trapezoid.NxRegrid);
  Trapezoid.regrid_workingSpace    = fcomplex_vector(Trapezoid.NxRegrid);
  for ( j=0; j<Trapezoid.NxRegrid; j++ )
    {
      //
      // Define the roll-off function.
      //
      x = -0.5 + (float)j/(float)(Trapezoid.NxRegrid-1);   // Because delta_k = 1, DELTA_x = 1/delta_k = 1
      Trapezoid.regrid_rolloff[j] = inverse_Kaiser_Bessel((double)x, regrid_width, regrid_sigma);
      //
      // Locate the neighbors for each k-space point that fall within a given width.
      //
      k = kRaw[j];
      kNew = j - Trapezoid.NxRegrid/2 + 0.5;   // e.g., -63.5 to 63.5 for 128 steps, in uniform 1-unit increments
      Trapezoid.regrid_numberNeighbors[j] = 0;
      Trapezoid.regrid_density[j] = 0.;
      for (jn=0; jn<Trapezoid.NxRegrid; jn++)
        {
          kn = kRaw[jn];
          if ( fabs((double)(k-kn)) <= regrid_width/2. )
            Trapezoid.regrid_density[j] += Kaiser_Bessel( (double)(k-kn), regrid_width, regrid_sigma );
          if ( fabs((double)(kNew-kn)) <= regrid_width/2. )
            Trapezoid.regrid_numberNeighbors[j]++;
        }
    }
  // Find the maximum number of neighbors, in order to allocate memory.
  maxNeigh = -1;
  for (j=0; j<Trapezoid.NxRegrid; j++)
    {
      if ( Trapezoid.regrid_numberNeighbors[j] > maxNeigh ) maxNeigh = Trapezoid.regrid_numberNeighbors[j];
    }
  // Allocate 2D matrices.
  Trapezoid.regrid_neighbor = short_matrix(Trapezoid.NxRegrid,maxNeigh);
  Trapezoid.regrid_convolve = float_matrix(Trapezoid.NxRegrid,maxNeigh);
  // Fill the 2D matrices.
  for (j=0; j<Trapezoid.NxRegrid; j++)
    {
      // Initialize with zeroes.
      for (jn=0; jn<maxNeigh; jn++)
        {
          Trapezoid.regrid_neighbor[j][jn]  = 0;
          Trapezoid.regrid_convolve[j][jn] = 0.;
        }
      // Repeat the above block of code, and store matrix data.
      kNew = j - Trapezoid.NxRegrid/2 + 0.5;   // e.g., -63.5 to 63.5 for 128 steps, in uniform 1-unit increments
      Trapezoid.regrid_numberNeighbors[j] = 0;
      for (jn=0; jn<Trapezoid.NxRegrid; jn++)
        {
          kn = kRaw[jn];
          if ( fabs((double)(kNew-kn)) <= regrid_width/2. )
            {
              Trapezoid.regrid_neighbor[j][Trapezoid.regrid_numberNeighbors[j]] = jn;
              Trapezoid.regrid_convolve[j][Trapezoid.regrid_numberNeighbors[j]] = Kaiser_Bessel( (double)(kNew-kn), regrid_width, regrid_sigma );
              Trapezoid.regrid_numberNeighbors[j]++;
            }
        }
    }
  free((char *)kRaw);  

  return TRUE;
}

BOOL Trapezoid_regrid(FIFO *sFifo)
{
  BOOL ok;
  FCOMPLEX *LineBase, *P0, sum;
  long lLenX, lOffset, jNew, jn, jOrig, jChan;

  // Find the length of the vectors.
  lLenX = sFifo->lDimXOp;
  ok = lLenX == Trapezoid.NxRegrid;
  if ( !ok )
    {
      printf("\nERROR: length of line for regridding does not match regrid function!\n");
      return FALSE;
    }

  // There is always an implicit loop over channels.
  for (jChan=0; jChan<sFifo->lDimC; jChan++)
    {
      // Set the offset for each channel.
      // Step by lDimX, not lDimXOp, since the original array is intact.
      lOffset = jChan * sFifo->lDimX;
      // The offset starts at the shifted location (FCDataOp).
      LineBase = sFifo->FCDataOp + lOffset;

      // Make a copy of the line.
      for (jNew=0, P0 = LineBase; jNew<lLenX; jNew++, P0++)
	{
	  Trapezoid.regrid_workingSpace[jNew].re = P0->re;
	  Trapezoid.regrid_workingSpace[jNew].im = P0->im;
	}

      // Perform the regridding.
      for (jNew=0; jNew<lLenX; jNew++)
	{
	  sum.re = sum.im = 0.;
	  for (jn=0; jn<Trapezoid.regrid_numberNeighbors[jNew]; jn++)
	    {
	      jOrig = Trapezoid.regrid_neighbor[jNew][jn];
	      P0 = Trapezoid.regrid_workingSpace + jOrig;
	      sum.re += P0->re / Trapezoid.regrid_density[jOrig] * Trapezoid.regrid_convolve[jNew][jn];
	      sum.im += P0->im / Trapezoid.regrid_density[jOrig] * Trapezoid.regrid_convolve[jNew][jn];
	    }
	  P0 = LineBase + jNew;
	  P0->re = sum.re;
	  P0->im = sum.im;
	}
    }
  return TRUE;
}

BOOL Trapezoid_rolloff(FIFO *sFifo)
{
  BOOL ok;
  FCOMPLEX *LineBase, *P0, div, data;
  float denom;
  long lLenX, jChan, j, lOffset;

  // Find the length of the vectors.
  lLenX = sFifo->lDimXOp;
  ok = lLenX == Trapezoid.NxRegrid;
  if ( !ok )
    {
      printf("\nERROR: length of line for regridding does not match regrid function!\n");
      return FALSE;
    }

  // There is always an implicit loop over channels.
  for (jChan=0; jChan<sFifo->lDimC; jChan++)
    {
      // Set the offset for each channel.
      // Step by lDimX, not lDimXOp, since the original array is intact.
      lOffset = jChan * sFifo->lDimX;
      // The offset starts at the shifted location (FCDataOp).
      LineBase = sFifo->FCDataOp + lOffset;
      // Multiply the line by the rolloff function.
      for ( j=0, P0=LineBase;
	    j<lLenX; j++, P0++ )
	{
	  div    = Trapezoid.regrid_rolloff[j];
	  data   = *P0;
	  denom  = div.re * div.re + div.im * div.im;
	  P0->re = ( data.re * div.re + data.im * div.im ) / denom;
	  P0->im = ( data.im * div.re - data.re * div.im ) / denom;
	}
    }
   return TRUE;
}

float Kaiser_Bessel( double x, double W, double beta )
{
  double bess;
  double arg;

  arg = 1. - 4.*x*x/W/W;

  if ( arg < 0. )
    return(0.);
  else
    {
      arg = beta * sqrt(arg);
      bess = bessi0( arg );
      return( bess/W );
    }
}

FCOMPLEX inverse_Kaiser_Bessel( double x, double W, double beta )
{
  FCOMPLEX invKB;
  double arg;
  double dsinc;

  arg = PI*PI * W*W * x*x - beta*beta;
  if ( arg >= 0. )
    {
      arg = sqrt( arg );
      if ( arg < 1.0e-4 )
      	dsinc = 1.0 ;
      else
        dsinc = sin( arg ) / arg;
      invKB.re = dsinc * beta / sinh(beta);
      invKB.im = 0.;
    }
  else
    {
      arg *= -1.;
      arg = sqrt( arg );
      if ( arg < 1.0e-4 )
      	dsinc = 1.0;
      else
        dsinc = sinh( arg ) / arg;
      invKB.re = 0.;
      invKB.im = dsinc * beta / sinh(beta);  // make sure result = 1 when x = 0
    }
  return( invKB );
}

double bessi0( double x )
{
  double ax, ans, y;

  if ( (ax=fabs(x)) < 3.75 )
    {
      y=x/3.75;
      y*=y;
      ans=1.0+y*(3.5156229+y*(3.0899424+y*(1.2067492
      +y*(0.2659732+y*(0.360768e-1+y*0.45813e-2)))));
    }
  else
    {
      y=3.75/ax;
      ans=(exp(ax)/sqrt(ax))*(0.39894228+y*(0.1328592e-1
      +y*(0.225319e-2+y*(-0.157565e-2+y*(0.916281e-2
      +y*(-0.2057706e-1+y*(0.2635537e-1+y*(-0.1647633e-1
      +y*0.392377e-2))))))));
    }
  return ans;
}

// Compute the phase of complex number.  Use the interval -PI to PI.
float compute_phase(FCOMPLEX FC)
{
  float phase;

  if ( FC.re != 0. )
    {
      phase = atan((double)(FC.im/FC.re));
      if ( FC.re < 0. ) phase += PI;
      if ( phase > PI ) phase -= 2*PI;
     }
  else
    {
      if ( FC.im == 0. )
        phase = 0.;
      else if ( FC.im > 0. )
        phase = PI/2.;
      else
        phase = - PI/2.;
    }
  return(phase);
}

short *short_vector(long length)
{
  short *vec;
  vec = (short *)malloc((unsigned)(length*sizeof(short)));
  if ( !vec )
    {
      printf("\nError: allocation failed in short_vector.\n");
      exit(1);
    }
  return(vec);
}
float *float_vector(long length)
{
  float *vec;
  vec = (float *)malloc((unsigned)(length*sizeof(float)));
  if ( !vec )
    {
      printf("\nError: allocation failed in float_vector.\n");
      exit(1);
    }
  return(vec);
}
FCOMPLEX *fcomplex_vector(long length)
{
  FCOMPLEX *vec;
  vec = (FCOMPLEX *)malloc((unsigned)(2*length*sizeof(float)));
  if ( !vec )
    {
      printf("\nError: allocation failed in float_vector.\n");
      exit(1);
    }
  return(vec);
}

short **short_matrix(long length1, long length2)
{
  short **mat;
  long j;

  mat = (short **)malloc((unsigned)(length1*sizeof(short*)));
  if ( !mat )
    {
      printf("\nError: allocation failed in short_matrix.\n");
      exit(1);
    }
  for (j=0; j<length1; j++)
    {
      mat[j] = (short *)malloc((unsigned)(length2*sizeof(short)));
      if ( !mat[j] )
        {
          printf("\nError: allocation failed in short_matrix.\n");
          exit(1);
        }
    }
  return(mat);
}
void free_short_matrix(short **mat, long length1)
{
  long j;

  for (j=length1-1; j>=0; j--)
    free((char *)(mat[j]));
  free((char *)mat);
}  

void free_fcomplex_vector(vec)
FCOMPLEX *vec;
{
  free((char *)vec);
}

void free_float_vector(vec)
float *vec;
{
  free((char *)vec);
}

float **float_matrix(long length1, long length2)
{
  float **mat;
  long j;

  mat = (float **)malloc((unsigned)(length1*sizeof(float*)));
  if ( !mat )
    {
      printf( "Error: allocation failed in float_matrix.\n");
      exit(1);
    }
  for (j=0; j<length1; j++)
    {
      mat[j] = (float *)malloc((unsigned)(length2*sizeof(float)));
      if ( !mat[j] )
        {
          printf("\nError: allocation failed in float_matrix.\n");
          exit(1);
        }
    }
  return(mat);
}
void free_float_matrix(float **mat, long length1)
{
  long j;

  for (j=length1-1; j>=0; j--)
    free((char *)(mat[j]));
  free((char *)mat);
}  
