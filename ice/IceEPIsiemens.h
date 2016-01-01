#include "../MyIceUtil.h"

ICE_RAW Ob_raw;    // raw data (all dimensions except repetitions)
ICE_RAW Ob_ref;    // phase correction object for odd lines (2 lines of NxRaw)
ICE_RAW Ob_mag;    // magnitude images for each channel
ICE_IMA Ob_ima;    // image data combined across channels
ICE_IMA Ob_mos;    // final mosaic image data

long m_NxRaw;     // # x raw data points (NOT oversampled)
long m_NyRaw;     // # y raw data lines
long m_Nz;        // # slices
long m_NyFT;      // # y lines in y FT
long m_NChan;     // # channels

long m_NxImage;   // # x pixels in image
long m_NyImage;   // # y pixels in image
long m_1dPanels;  // # of mosaic panels in either x or y
long m_DimPanel;  // # x or y dimensions of 1 panel in mosaic
                      // Total Mosaic dimension = m_N1dPanels * m_DimPanel in both x & y
enum eThingsToDo
{
  DO_PER_LINE           = 1,
  DO_PER_IMAGE          = 2,
  DO_PER_IMAGE_VOLUME   = 3,
  DO_IGNORE             = 4
};

// Prototypes
void init_attributes();
BOOL react_on_flags(sMDH *sMdh, short *do_what);
BOOL do_per_line(sMDH *sMdh, FIFO *sFifo);
BOOL do_per_image(sMDH *sMdh);
BOOL do_per_image_volume(sMDH *sMdh);
BOOL compute_linear_correction();
BOOL update_mosaic(long lSlice);
BOOL apply_epi_phase_correction( ICE_RAW_AS *As );
BOOL MyIce_SendRaw( ICE_RAW *Object );
BOOL is_power_of_2( long lInput, long *lLastPower, long *lNextPower );
BOOL calc_EPI_phase_correction( long lSlice );
