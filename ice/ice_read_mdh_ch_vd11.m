function sMDH=ice_read_mdh_ch_vd11(fp)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sMDH.ulDMALength=fread(fp,1,'ulong');
sMDH.lMeasUID=fread(fp,1,'long');
sMDH.ulScanCounter=fread(fp,1,'ulong');
sMDH.ulReserved1=fread(fp,1,'ulong');
sMDH.ulSequenceTime=fread(fp,1,'ulong');
sMDH.ulUnused2=fread(fp,1,'ulong');
sMDH.ushChannelID=fread(fp,1,'ushort');
sMDH.ushUnused3=fread(fp,1,'ushort');
sMDH.ulCRC=fread(fp,1,'ulong');