function sMDH=ice_read_mdh(fp)

% % typedef struct
% % {
% %   unsigned short  ushLine;                  /* line index                   */
% %   unsigned short  ushAcquisition;           /* acquisition index            */
% %   unsigned short  ushSlice;                 /* slice index                  */
% %   unsigned short  ushPartition;             /* partition index              */
% %   unsigned short  ushEcho;                  /* echo index                   */	
% %   unsigned short  ushPhase;                 /* phase index                  */
% %   unsigned short  ushRepetition;            /* measurement repeat index     */
% %   unsigned short  ushSet;                   /* set index                    */
% %   unsigned short  ushSeg;                   /* segment index  (for TSE)     */
% %   unsigned short  ushIda;                   /* IceDimension a index         */
% %   unsigned short  ushIdb;                   /* IceDimension b index         */
% %   unsigned short  ushIdc;                   /* IceDimension c index         */
% %   unsigned short  ushIdd;                   /* IceDimension d index         */
% %   unsigned short  ushIde;                   /* IceDimension e index         */
% % } sLoopCounter;                             /* sizeof : 28 byte             */
% % 
% % typedef struct
% % {
% %   float  flSag;
% %   float  flCor;
% %   float  flTra;
% % } sVector;
% % 
% % 
% % typedef struct
% % {
% %   sVector  sSlicePosVec;                    /* slice position vector        */
% %   float    aflQuaternion[4];                /* rotation matrix as quaternion*/
% % } sSliceData;                               /* sizeof : 28 byte             */
% % /*--------------------------------------------------------------------------*/
% % /*  Definition of cut-off data                                              */
% % /*--------------------------------------------------------------------------*/
% % typedef struct
% % {
% %   unsigned short  ushPre;               /* write ushPre zeros at line start */
% %   unsigned short  ushPost;              /* write ushPost zeros at line end  */
% % } sCutOffData;
% % 
% % 
% % 
% % /*--------------------------------------------------------------------------*/
% % /*  Definition of measurement data header                                   */
% % /*--------------------------------------------------------------------------*/
% % typedef struct
% % {
% %   unsigned long  ulDMALength;                  // DMA length [bytes] must be                        4 byte                                               // first parameter                        
% %   long           lMeasUID;                     // measurement user ID                               4     
% %   unsigned long  ulScanCounter;                // scan counter [1...]                               4
% %   unsigned long  ulTimeStamp;                  // time stamp [2.5 ms ticks since 00:00]             4
% %   unsigned long  ulPMUTimeStamp;               // PMU time stamp [2.5 ms ticks since last trigger]  4
% %   unsigned long  aulEvalInfoMask[MDH_NUMBEROFEVALINFOMASK]; // evaluation info mask field           8
% %   unsigned short ushSamplesInScan;             // # of samples acquired in scan                     2
% %   unsigned short ushUsedChannels;              // # of channels used in scan                        2   =32
% %   sLoopCounter   sLC;                          // loop counters                                    28   =60
% %   sCutOffData    sCutOff;                      // cut-off values                                    4           
% %   unsigned short ushKSpaceCentreColumn;        // centre of echo                                    2
% %   unsigned short ushDummy;                     // for swapping                                      2
% %   float          fReadOutOffcentre;            // ReadOut offcenter value                           4
% %   unsigned long  ulTimeSinceLastRF;            // Sequence time stamp since last RF pulse           4
% %   unsigned short ushKSpaceCentreLineNo;        // number of K-space centre line                     2
% %   unsigned short ushKSpaceCentrePartitionNo;   // number of K-space centre partition                2
% %   unsigned short aushIceProgramPara[MDH_NUMBEROFICEPROGRAMPARA]; // free parameter for IceProgram   8   =88
% %   unsigned short aushFreePara[MDH_FREEHDRPARA];// free parameter                          4 * 2 =   8   
% %   sSliceData     sSD;                          // Slice Data                                       28   =124
% %   unsigned long	 ulChannelId;                  // channel Id must be the last parameter             4
% %   } sMDH; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.ulDMALength=fread(fp,1,'ulong');
sMDH.lMeasUID=fread(fp,1,'long');
sMDH.ulScanCounter=fread(fp,1,'ulong');
sMDH.ulTimeStamp=fread(fp,1,'ulong');
sMDH.ulPMUTimeStamp=fread(fp,1,'ulong');
sMDH.aulEvalInfoMask=fread(fp,2,'ulong');    %8-byte, 2 elements
sMDH.ushSamplesInScan=fread(fp,1,'ushort');
sMDH.ushUsedChannels=fread(fp,1,'ushort');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.sLC.ushLine=fread(fp,1,'ushort');                %28-byte loop counter
sMDH.sLC.ushAcquisition=fread(fp,1,'ushort');
sMDH.sLC.ushSlice=fread(fp,1,'ushort');
sMDH.sLC.ushPartition=fread(fp,1,'ushort');
sMDH.sLC.ushEcho=fread(fp,1,'ushort');
sMDH.sLC.ushPhase=fread(fp,1,'ushort');
sMDH.sLC.ushRepetition=fread(fp,1,'ushort');
sMDH.sLC.ushSet=fread(fp,1,'ushort');
sMDH.sLC.ushSeg=fread(fp,1,'ushort');
sMDH.sLC.ushIda=fread(fp,1,'ushort');
sMDH.sLC.ushIdb=fread(fp,1,'ushort');
sMDH.sLC.ushIdc=fread(fp,1,'ushort');
sMDH.sLC.ushIdd=fread(fp,1,'ushort');
sMDH.sLC.ushIde=fread(fp,1,'ushort');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.sCutOff.ushPre=fread(fp,1,'ushort');
sMDH.sCutOff.ushPost=fread(fp,1,'ushort');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.ushKSpaceCentreColumn=fread(fp,1,'ushort');
sMDH.ushDummy=fread(fp,1,'ushort');
sMDH.fReadOutOffcentre=fread(fp,1,'float');
sMDH.ulTimeSinceLastRF=fread(fp,1,'ulong');
sMDH.ushKSpaceCentreLineNo=fread(fp,1,'ushort');
sMDH.ushKSpaceCentrePartitionNo=fread(fp,1,'ushort');
sMDH.aushIceProgramPara=fread(fp,4,'ushort');
sMDH.aushFreePara=fread(fp,4,'ushort');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.sSD.sSlicePosVec.flSag=fread(fp,1,'float');
sMDH.sSD.sSlicePosVec.flCor=fread(fp,1,'float');
sMDH.sSD.sSlicePosVec.flTra=fread(fp,1,'float');
sMDH.sSD.aflQuaternion=fread(fp,4,'float');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.ulChannelId=fread(fp,1,'ulong');