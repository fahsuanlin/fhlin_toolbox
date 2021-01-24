typedef struct
{
  long NxRegrid;                 // # points to regrid
  float *regrid_density;         // local density of points (per point)
  short *regrid_numberNeighbors; // # of neighbors inside convolution kernel (per point)
  float **regrid_convolve;       // weighting factor for each neighbor (per point, per neighbor)
  short **regrid_neighbor;       // list of neighboring points (per point,per neighbor)
  FCOMPLEX *regrid_rolloff;      // rolloff correction factor (per point)
  FCOMPLEX *regrid_workingSpace; // space for copying each line (per point)
} REGRID;

REGRID Trapezoid;

// Prototypes
BOOL Trapezoid_init(long lRamp, long lFlat, long lADC, long lNx, long lSinusoidal_Ramps);
BOOL Trapezoid_regrid(FIFO *sFifo);
BOOL Trapezoid_rolloff(FIFO *sFifo);
float Kaiser_Bessel( double x, double W, double beta );
FCOMPLEX inverse_Kaiser_Bessel( double x, double W, double beta );
double bessi0( double x );
float compute_phase(FCOMPLEX FC);
short *short_vector(long length);
float *float_vector(long length);
FCOMPLEX *fcomplex_vector(long length);
short **short_matrix(long length1, long length2);
void free_short_matrix(short **mat, long length1);
float **float_matrix(long length1, long length2);
void free_float_matrix(float **mat, long length1);
void free_fcomplex_vector(FCOMPLEX *vec);
void free_float_vector(float *vec);
