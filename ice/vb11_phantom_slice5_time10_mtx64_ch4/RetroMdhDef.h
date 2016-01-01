#ifndef __RetroMDHDef_H
#define __RetroMDHDef_H 1

//const MdhBitField MDH_LASTPHASE          (5);
//const MdhBitField MDH_ENDOFMEAS          (6);
//const MdhBitField MDH_REPEATHEARTBEAT    (7);
//const MdhBitField MDH_ABORTSCANNOW       (9);

const MdhBitField MDH_LASTPHASE           (45);
const MdhBitField MDH_ENDOFMEAS           (46);
const MdhBitField MDH_REPEATTHISHEARTBEAT (47);
const MdhBitField MDH_REPEATPREVHEARTBEAT (48);
const MdhBitField MDH_ABORTSCANNOW        (49);
const MdhBitField MDH_LASTHEARTBEAT       (50);
const MdhBitField MDH_DUMMYSCAN           (51);
const MdhBitField MDH_ARRDETDISABLED      (52);

const unsigned short MDHFREE_MYTIMESTAMP (0);
const unsigned short MDHFREE_RRDURATION  (1);
const unsigned short MDHFREE_EXSYCOUNTER (2);
const unsigned short MDHFREE_CLIN        (3);


#define RETRO_DUMP_EVALINFOMASK(stream, val)                        \
  if (val & MDH_LASTPHASE)         stream << "MDH_LASTPHASE ";      \
  if (val & MDH_ENDOFMEAS)         stream << "MDH_ENDOFMEAS ";      \
  if (val & MDH_REPEATTHISHEARTBEAT)   stream << "MDH_REPEATTHISHEARTBEAT ";\
  if (val & MDH_REPEATPREVHEARTBEAT)   stream << "MDH_REPEATPREVHEARTBEAT ";\
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
                            
#endif
