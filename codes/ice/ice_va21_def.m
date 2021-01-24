% % #define MDH_ACQEND            (1<<0)
% % #define MDH_RTFEEDBACK        (1<<1)
% % #define MDH_HPFEEDBACK        (1<<2)
% % #define MDH_ONLINE            (1<<3)
% % #define MDH_OFFLINE           (1<<4)
% % 
% % #define MDH_LASTSCANINCONCAT  (1<<8)       // Flag for last scan in concatination
% % 
% % #define MDH_RAWDATACORRECTION (1<<10)      // Correct the rawadata with the rawdata correction factor
% % #define MDH_LASTSCANINMEAS    (1<<11)      // Flag for last scan in measurement
% % #define MDH_SCANSCALEFACTOR   (1<<12)      // Flag for scan specific additional scale factor
% % #define MDH_2NDHADAMARPULSE   (1<<13)      // 2nd RF exitation of HADAMAR
% % #define MDH_REFPHASESTABSCAN  (1<<14)      // reference phase stabilization scan         
% % #define MDH_PHASESTABSCAN     (1<<15)      // phase stabilization scan
% % #define MDH_D3FFT             (1<<16)      // execute 3D FFT         
% % #define MDH_SIGNREV           (1<<17)      // sign reversal
% % #define MDH_PHASEFFT          (1<<18)      // execute phase fft     
% % #define MDH_SWAPPED           (1<<19)      // swapped phase/readout direction
% % #define MDH_POSTSHAREDLINE    (1<<20)      // shared line               
% % #define MDH_PHASCOR           (1<<21)      // phase correction data    
% % #define MDH_PATREFSCAN        (1<<22)      // additonal scan for PAT reference line/partition
% % #define MDH_PATREFANDIMASCAN  (1<<23)      // additonal scan for PAT reference line/partition that is also used as image scan
% % #define MDH_REFLECT           (1<<24)      // reflect line              
% % #define MDH_NOISEADJSCAN      (1<<25)      // noise adjust scan --> Not used in NUM4        
% % #define MDH_SHARENOW          (1<<26)      // all lines are acquired from the actual and previous e.g. phases
% % #define MDH_LASTMEASUREDLINE  (1<<27)      // indicates that the current line is the last measured line of all succeeding e.g. phases
% % #define MDH_FIRSTSCANINSLICE  (1<<28)      // indicates first scan in slice (needed for time stamps)
% % #define MDH_LASTSCANINSLICE   (1<<29)      // indicates  last scan in slice (needed for time stamps)
% % #define MDH_TREFFECTIVEBEGIN  (1<<30)      // indicates the begin time stamp for TReff (triggered measurement)
% % #define MDH_TREFFECTIVEEND    (1<<31)      // indicates the   end time stamp for TReff (triggered measurement)

MDH_ACQEND=bitshift(1,0);
MDH_RTFEEDBACK=bitshift(1,1);
MDH_HPFEEDBACK=bitshift(1,2);
MDH_ONLINE=bitshift(1,3);
MDH_OFFLINE=bitshift(1,4);
MDH_LASTSCANINCONCAT=bitshift(1,8);
MDH_RAWDATACORRECTION=bitshift(1,10);
MDH_LASTSCANINMEAS=bitshift(1,11);
MDH_SCANSCALEFACTOR=bitshift(1,12);
MDH_2NDHADAMARPULSE=bitshift(1,13);
MDH_REFPHASESTABSCAN=bitshift(1,14);
MDH_PHASESTABSCAN=bitshift(1,15);
MDH_D3FFT=bitshift(1,16);
MDH_SIGNREV=bitshift(1,17);
MDH_PHASEFFT=bitshift(1,18);
MDH_SWAPPED=bitshift(1,19);
MDH_POSTSHAREDLINE=bitshift(1,20);
MDH_PHASCOR=bitshift(1,21);
MDH_PATREFSCAN=bitshift(1,22);
MDH_PATREFANDIMASCAN=bitshift(1,23);
MDH_REFLECT=bitshift(1,24);
MDH_NOISEADJSCAN=bitshift(1,25);
MDH_SHARENOW=bitshift(1,26);
MDH_LASTMEASREDLINE=bitshift(1,27);
MDH_FIRSTSCANINSLICE=bitshift(1,28);
MDH_LASTSCANINSLICE=bitshift(1,29);
MDH_TREFFECTIVEBEGIN=bitshift(1,30);
MDH_TREEFECTIVEEND=bitshift(1,31);

ver_idea='VA21';