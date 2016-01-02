function sMDH=ice_read_mdh(fp)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.ulDMALength=fread(fp,1,'ulong');
sMDH.lMeasUID=fread(fp,1,'long');
sMDH.ulScanCounter=fread(fp,1,'ulong');
sMDH.ulTimeStamp=fread(fp,1,'ulong');
sMDH.ulPMUTimeStamp=fread(fp,1,'ulong');
sMDH.ushSystemType=fread(fp,1,'ushort');
sMDH.ushPTABPosDelay=fread(fp,1,'ushort');
sMDH.ulPTABPosX=fread(fp,1,'ulong');
sMDH.ulPTABPosY=fread(fp,1,'ulong');
sMDH.ulPTABPosZ=fread(fp,1,'ulong');
sMDH.ulReserved1=fread(fp,1,'ulong');
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
sMDH.ushCoilSelect=fread(fp,1,'ushort');
sMDH.fReadOutOffcentre=fread(fp,1,'float');
sMDH.ulTimeSinceLastRF=fread(fp,1,'ulong');
sMDH.ushKSpaceCentreLineNo=fread(fp,1,'ushort');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.ushKSpaceCentrePartitionNo=fread(fp,1,'ushort');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.sLC2.ushLine=fread(fp,1,'ushort');                %28-byte loop counter; 2nd time....
sMDH.sLC2.ushAcquisition=fread(fp,1,'ushort');
sMDH.sLC2.ushSlice=fread(fp,1,'ushort');
sMDH.sLC2.ushPartition=fread(fp,1,'ushort');
sMDH.sLC2.ushEcho=fread(fp,1,'ushort');
sMDH.sLC2.ushPhase=fread(fp,1,'ushort');
sMDH.sLC2.ushRepetition=fread(fp,1,'ushort');
sMDH.sLC2.ushSet=fread(fp,1,'ushort');
sMDH.sLC2.ushSeg=fread(fp,1,'ushort');
sMDH.sLC2.ushIda=fread(fp,1,'ushort');
sMDH.sLC2.ushIdb=fread(fp,1,'ushort');
sMDH.sLC2.ushIdc=fread(fp,1,'ushort');
sMDH.sLC2.ushIdd=fread(fp,1,'ushort');
sMDH.sLC2.ushIde=fread(fp,1,'ushort');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.aushIceProgramPara=fread(fp,4,'ushort');
sMDH.aushFreePara=fread(fp,4,'ushort');
sMDH.sSD.sSlicePosVec.flSag=fread(fp,1,'float');
sMDH.sSD.sSlicePosVec.flCor=fread(fp,1,'float');
sMDH.sSD.sSlicePosVec.flTra=fread(fp,1,'float');
sMDH.sSD.aflQuaternion=fread(fp,4,'float');
sMDH.ulChannelId=fread(fp,1,'ulong');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sMDH.ulReservedPara=fread(fp,2,'ulong');
sMDH.ushApplicationCounter=fread(fp,1,'ushort');
sMDH.ushApplicationMask=fread(fp,1,'ushort');
sMDH.ulCRC=fread(fp,1,'ulong');