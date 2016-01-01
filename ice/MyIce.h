#ifdef VA15
  #include "mdh-VA15.h"
#else
  #include "mdh-VA21.h"
#endif

#define LEN_STR 256
#define PI 3.141592654
#define BOOL short
#define TRUE  1
#define FALSE 0

typedef struct
{
  float re, im;
} FCOMPLEX;

///////////////// MyIce OBJECTS //////////////////////////////
// Objects are allocated space for multi-dimensional data.
// `fifo' objects are complex floats representing ADC reads.
// `raw' objects are complex floats for multi-dimensional data.
// `ima' objects are short integers for 2-dimensional images.
///////////////// FIFO structure /////////////////////////////
typedef struct
{
  long lDimX;         // length of ADC read (with oversampling)
  long lDimC;         // number of channels
  FCOMPLEX *FCData;   // address of ADC data
  long lDimXOp;       // length to use for operations  (enables quick "clipping")
  FCOMPLEX *FCDataOp; // address to use for operations (enables quick "clipping")
} FIFO;
///////////////// raw object structure //////////////////////
typedef struct
{
  long lDimX;       // x (COL)
  long lDimY;       // y (LIN)
  long lDimZ;       // z (SLC)
  long lDimC;       // channels
  long lLength;     // lDimX * lDimY * lDimZ * lDimC
  FCOMPLEX *FCData; // complex data
} ICE_RAW;
///////////////// image object structure ////////////////////
typedef struct
{
  long lDimX;       // x (COL)
  long lDimY;       // y (LIN)
  long lLength;     // lDimX * lDimY
  short *sData;     // image data
} ICE_IMA;

////////////// MyIce Access Specifiers //////////////////////
// These access specifiers are not really like the ICE ones.
// MyIce access specifiers are pointers to an element within
// an object (above).
//    X   The X location never specified, because there are
//        no operations for individual pixels, and a ADC will
//        always give an X vector.  Thus, an X vector is most
//        basic unit here.  The access pointer to the actual
//        data will always be at X=0
//    Y,Z are always specified as single values; sub-ranges
//        cannot be specified.
//    C   Channel is implicit.  It is not specified.
//
// Example:    As_raw = MyIce_InitRaw(Ob_raw, lY, lZ);
//
// creates a pointer to data within Ob_raw at position
// (x,y,z) = (0,y,z), and all operations performed using the
// `access specifier' are repeated across channels.  Unlike
// the actual ICE specifiers, the length of MyIce specifiers
// is function-dependent (e.g., DimX for FTX and DimX*DimY for FTY).
//
// Unlike real ICE, there is no such things as an image access
// specifier.  Image operations use the 2D objects (ICE_IMA) as
// shown above.
//
typedef struct
{
  long lDimX;       // X (COL)
  long lDimY;       // Y (LIN)
  long lDimZ;       // Z (SLC)
  long lDimC;       // C (channel)
  long lOffsetY;    // Y (LIN) offset
  long lOffsetChan; // spacing between channel data (lDimX * lDimY * lDimZ)
  FCOMPLEX *FCData; // pointer to data in Object
  ICE_RAW *Object;  // pointer to Object
} ICE_RAW_AS;

enum
{
  AMPLITUDE, PHASE, REAL, IMAGINARY
} enumImageTypes;

// Prototypes
BOOL MyIce_CreateRaw( ICE_RAW *Object, short lDimX, short lDimY, short lDimZ, short lDimC );
BOOL MyIce_CreateIma( ICE_IMA *Object, short lDimX, short lDimY );
BOOL MyIce_InitRaw(ICE_RAW *Object, ICE_RAW_AS *Specifier, long lY, long lZ);
BOOL MyIce_CopyLine(ICE_RAW_AS *As_dest, ICE_RAW_AS *As_source);
BOOL MyIce_ReflectLine( FIFO *sFifo, sMDH *sMdh );
BOOL MyIce_FTX( FIFO *sFifo );
BOOL MyIce_FTY( ICE_RAW_AS *As_raw );
BOOL MyIce_ModifyY( ICE_RAW_AS *As_raw, long lOffset, long lLength);
void MyIce_ClipFifo( FIFO *sFifo );
void swap_x( FCOMPLEX *FCData, long lDim );
BOOL MyIce_AccumulateFifo(ICE_RAW_AS *As_raw, FIFO *sFifo, BOOL Add);
BOOL MyIce_ExtractComplex(ICE_RAW_AS *As_mag, ICE_RAW_AS *As_raw, long lType, float fScaleFactor);
BOOL MyIce_CombineChannels(ICE_IMA *Object, ICE_RAW_AS *As_raw);
BOOL MyIce_NormOrientation(ICE_IMA *Object, BOOL swap_PE);
BOOL MyIce_SendIma( ICE_IMA *Object, FILE *file );
void MyIce_PresetRaw( ICE_RAW *Object, float real, float imag );
void MyIce_PresetIma( ICE_IMA *Object, short sValue );
BOOL MyIce_WriteRawToFile(ICE_RAW_AS *As_raw, char *BshortFileName);
void four1(float data[], int, int isign);
void normalize_vector( ICE_RAW_AS *As );

