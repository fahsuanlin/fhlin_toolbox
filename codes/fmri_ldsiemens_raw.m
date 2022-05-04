function [k,im,h,varargout]=fmri_ldsiemens_raw(fn,matrix,varargin)
%
% fmri_ldsiemensraw	reads SIEMENS complex raw data
% 
% [k,im]=fmri_ldsiemensraw(fn,matrix)
%
% fn: filename (and path)
% matrix: matrix size
% k: k-space complex data
% im: fft reconstructed complex imag
%
% fhlin@oct. 27,2001


mode='15t';
h=[];
k=[];
im=[];

if(nargin==3)

mode=varargin{1};

end;

	data0=[];
	data1=[];
   
      matrix0=matrix;
   if(size(matrix,1)==1) matrix=fliplr(matrix); else matrix=flipud(matrix); end;

if(strcmp(mode,'3t'))
	h=read_header(fn);
	fid=fopen(fn,'r','ieee-be');
    
    no_rows=0;
    no_columns=0;
    ima_mat=0;
    head=0;

    fseek(fid,84,-1);
    [datatype, cnt]=fread(fid, 1, 'int32');
    fprintf('DataSetSubtype : ');

    if (datatype == 3)
        fprintf('Numaris 3 Rawdata\n');
        % Position Filepointer at G19.Acq2.Mr.NumberOfFourierLinesNominal
        % and read rows and columns

        fseek(fid, 2084,-1); % 1920+98(97+1)+36

        [matdim, cnt]=fread(fid, [1, 6], 'int32');
        no_rows=matdim(1);
        no_columns=matdim(5);

        % Position Filepointer at Start and read Header
        frewind(fid);
        [head cnt]=fread(fid, 6144 / 2, 'short');

        % Position Filepointer at Pixeldata and read Matrix
        fseek(fid, 6144, -1);

        % Data is read columnwise with fread 
        % although stored rowwise by Numaris

        [dummy, cnt]=fread(fid, [2*no_columns, no_rows], 'float');
        k=dummy(1:2:(2*no_columns),:)'+i*dummy(2:2:2*no_columns,:)';
        im=fft2(k);
    else
        fprintf('No Numaris Image !! (Type : %d)\n',datatype);
    end
    fprintf('Rows           : %d\n',no_rows);
    fprintf('Columns        : %d\n',no_columns);
    
else
   
   
	fp=fopen(fn,'r','ieee-le.l64');
	status=fseek(fp,0,1);
	f_length=ftell(fp);
	
	skip=f_length-prod(matrix)*(2*4);
	fseek(fp,0,-1);
	
	
	fseek(fp,skip,0);
	
	[data,count0]=fread(fp,prod(matrix)*2,'single');
	fclose(fp);


	re=data(1:2:end);
	re=reshape(re,matrix);
   im=data(2:2:end);
	im=reshape(im,matrix);
   
 	%reconstruct the data
   k=fftshift(transpose(re+im*j));
    
   [xx,yy]=meshgrid([1:matrix(1)],[1:matrix(2)]);
   
      sgn=ones(matrix0).*(-1);
      sgn=sgn.^(xx+yy);
    	k=k.*sgn;
      
   im=fft2(k);
	
	
	
end;


function header=read_header(fn);



fp=fopen(fn,'r','ieee-be');

header.study_year=fread(fp,1,'uint32');                 %0         u_int      SiemensStudyDateYYYY
header.study_month=fread(fp,1,'uint32');	        %4         u_int      SiemensStudyDateMM
header.study_day=fread(fp,1,'uint32');                  %8         u_int      SiemensStudyDateDD
header.acq_year=fread(fp,1,'uint32');                   %12        u_int      AcquisitionDateYYYY
header.acq_month=fread(fp,1,'uint32');                  %16        u_int      AcquisitionDateMM
header.date_day=fread(fp,1,'uint32');			%20        u_int      AcquisitionDateDD
header.image_year=fread(fp,1,'uint32');                 %24        u_int      ImageDateYYYY
header.image_month=fread(fp,1,'uint32');                %28        u_int      ImageDateMM
header.image_day=fread(fp,1,'uint32');                  %32        u_int      ImageDateDD
header.study_hour=fread(fp,1','uint32');                %36        u_int      SiemensStudyTimeHH
header.study_minute=fread(fp,1,'uint32');               %40        u_int      SiemensStudyTimeMM
header.study_second=fread(fp,1,'uint32');		%44        u_int      SiemensStudyTimeSS
header.acq_hour=fread(fp,1,'uint32');                   %52        u_int      AcquisitionTimeHH
header.acq_minute=fread(fp,1,'uint32');			%56        u_int      AcquisitionTimeMM
header.acq_second=fread(fp,1,'uint32');			%60        u_int      AcquisitionTimeSS
header.image_hour=fread(fp,1,'uint32');                 %68        u_int      ImageTimeHH
header.image_minute=fread(fp,1,'uint32');		%72        u_int      ImageTimeMM
header.image_second=fread(fp,1,'uint32');		%76        u_int      ImageTimeSS


fseek(fp,96,-1);
header.manufacturer=fread(fp,7,'char');			%96        char[7]    Manufacturer
fseek(fp,105,-1);
header.institution=fread(fp,25,'char');			%105       char[25]   InstitutionName
fseek(fp,186,-1);
header.annotation=fread(fp,4,'char');			%186       char[4]    Annotation
fseek(fp,281,-1);
header.model_name=fread(fp,15,'char');			%281       char[15]   ModelName
fseek(fp,412,-1);
header.lastmove_year=fread(fp,1,'uint32');		%412       u_int      LastMoveDateYYYY
fseek(fp,416,-1);
header.lastmove_month=fread(fp,1,'uint32');		%416       u_int      LastMoveDateMM
fseek(fp,420,-1);
header.lastmove_day=fread(fp,1,'uint32');		%420       u_int      LastMoveDateDD
fseek(fp,424,-1);
header.lastmove_hour=fread(fp,1,'uint32');		%424       u_int      LastMoveTimeHH
fseek(fp,428,-1);
header.lastmove_minute=fread(fp,1,'uint32');		%428       u_int      LastMoveTimeMM
fseek(fp,432,-1);
header.lastmove_second=fread(fp,1,'uint32');		%432       u_int      LastMoveTimeSS

fseek(fp,768,-1);
header.patientname=fread(fp,25,'char');			%768       char[25]   PatientName
fseek(fp,795,-1);
header.patientid=fread(fp,12,'char');			%795       char[12]   PatientID
fseek(fp,808,-1);
header.dob_year=fread(fp,1,'uint32');			%808       u_int      DOBYYYY
fseek(fp,812,-1);
header.dob_month=fread(fp,1,'uint32');			%812       u_int      DOBMM
fseek(fp,816,-1);
header.dob_day=fread(fp,1,'uint32');			%816       u_int      DOBDD
	
fseek(fp,851,-1);
header.patient_age=fread(fp,3,'char');			%851       char[3]    PatientAge
fseek(fp,854,-1);
header.patient_age_unit=fread(fp,1,'char');		%854       char       PatientAgeUnits      ('Y'=years)

fseek(fp,1052,-1);
header.reg_year=fread(fp,1,'uint32');			%1052      u_int      RegistrationDateYYYY
fseek(fp,1056,-1);
header.reg_month=fread(fp,1,'uint32');			%1056      u_int      RegistrationDateMM
fseek(fp,1060,-1);
header.reg_day=fread(fp,1,'uint32');			%1060      u_int      RegistrationDateDD
fseek(fp,1064,-1);
header.reg_hour=fread(fp,1,'uint32');			%1064      u_int      RegistrationTimeHH
fseek(fp,1068,-1);
header.reg_minute=fread(fp,1,'uint32');			%1068      u_int      RegistrationTimeMM
fseek(fp,1072,-1);
header.reg_second=fread(fp,1,'uint32');			%1072      u_int      RegistrationTimeSS

fseek(fp,1544,-1);
header.slicethickness=fread(fp,1,'double');		%1544      double     SliceThickness
fseek(fp,1560,-1);
header.TR=fread(fp,1,'double');				%1560      double     RepetitionTime
fseek(fp,1568,-1);
header.TE=fread(fp,1,'double');				%1568      double     EchoTime
fseek(fp,1592,-1);
header.frequency=fread(fp,1,'double');			%1592      double     FrequencyMHz
	
fseek(fp,1639,-1);
header.station=fread(fp,5,'char');			%1639      char[5]    Station
fseek(fp,1712,-1);
header.calibration_year=fread(fp,1,'uint32');		%1712      u_int      CalibrationDateYYYY
fseek(fp,1716,-1);
header.calibration_month=fread(fp,1,'uint32');		%1716      u_int      CalibrationDateMM
fseek(fp,1720,-1);
header.calibration_day=fread(fp,1,'uint32');		%1720      u_int      CalibrationDateDD
fseek(fp,1724,-1);
header.calibration_hour=fread(fp,1,'uint32');		%1724      u_int      CalibrationTimeHH
fseek(fp,1728,-1);
header.calibration_minute=fread(fp,1,'uint32');		%1728      u_int      CalibrationTimeMM
fseek(fp,1732,-1);
header.calibration_second=fread(fp,1,'uint32');		%1732      u_int      CalibrationTimeSS

fseek(fp,1767,-1);
header.receive_coil=fread(fp,16,'char');		%1767      char[16]   ReceivingCoil
fseek(fp,1828,-1);
header.nucleus=fread(fp,4,'char');			%1828      char[4]    ImagedNucleus
fseek(fp,2112,-1);
header.flipangle=fread(fp,1,'double');			%2112      double     FlipAngle
fseek(fp,2560,-1);
header.magnetfieldstrength=fread(fp,1,'double');	%2560      double     MagneticFieldStrength
fseek(fp,2864,-1);
header.matrix=fread(fp,1,'uint32');			%2864      u_int      DisplayMatrixSize

%2944      char[65]   SequencePrgName
%3009      char[65]   SequenceWkcName
%3074      char[9]    SequenceAuthor
%3083      char[8]    SequenceType

fseek(fp,3744,-1);
header.fov_row=fread(fp,1,'double');			%3744      double     FOVRow
fseek(fp,3752,-1);
header.fov_col=fread(fp,1,'double');			%3752      double     FOVColumn


%3768      double     CenterPointX
%3776      double     CenterPointY
%3784      double     CenterPointZ
%3792      double     NormalVectorX
%3800      double     NormalVectorY
%3808      double     NormalVectorZ
%3816      double     DistanceFromIsocenter
%3832      double     RowVectorX
%3840      double     RowVectorY
%3848      double     RowVectorZ
%3856      double     ColumnVectorX
%3864      double     ColumnVectorY
%3872      double     ColumnVectorZ
%3880      char[3]    OrientationSet1Top
%3884      char[3]    OrientationSet1Left
%3888      char[3]    OrientationSet1Back
%3892      char[3]    OrientationSet2Down
%3896      char[3]    OrientationSet2Right
%3900      char[3]    OrientationSet2Front

fseek(fp,3904,-1);
header.sequence_name=fread(fp,32,'char');		%3904      char[32]   SequenceName
fseek(fp,5000,-1);
header.pixel_row=fread(fp,1,'double');			%5000      double     PixelSizeRow
fseek(fp,5008,-1);
header.pixel_col=fread(fp,1,'double');			%5008      double     PixelSizeColumn

	
%5504      char[12]   TextPatientID
%5517      char       TextPatientSex
%5518      char[3]    TextPatientAge
%5521      char       TextPatientAgeUnits       ('Y'=years)
%5529      char[7]    TextPatientPosition
%5541      char[5]    TextImageNumberFlag       ('IMAGE'=image)
%5546      char[3]    TextImageNumber
%5559      char[2]    TextDateDD
%5562      char[3]    TextDateMM
%5566      char[4]    TextDateYYYY
%5571      char[2]    TextTimeHH
%5574      char[2]    TextTimeMM
%5577      char[2]    TextAcquisitionTimeFlag   ('TA'=acquisition time)
%5583      char[2]    TextAcquisitionTimeMM
%5586      char[2]    TextAcquisitionTimeSS
%5601      char[4]    TextAnnotation
%5655      char[25]   TextOrganization
%5682      char[5]    TextStation
%5695      char[3]    TextAcquisitionMatrixPhase
%5698      char       TextAcquisitionMatrixPhaseAxis  ('h'=horizontal,' '=vertical)
%5700      char[3]    TextAcquisitionMatrixFreq
%5703      char       TextAcquisitionMatrixFreqO      ('o'=o,' '=blank)
%5704      char       TextAcquisitionMatrixFreqS      ('s'=s,' '=blank)
%5706      char[8]    TextSequence
%5714      char[3]    TextFlipAngle
%5718      char[4]    TextScanNumberFlag        ('SCAN'=scan)
%5723      char[3]    TextScanNumberA
%5726      char[3]    TextScanNumberB
%5730      char[2]    TextRepetitionTimeFlag    ('TR'=tr)
%5734      char[7]    TextRepetitionTime
%5742      char[2]    TextEchoTimeFlag          ('TE'=te)
%5746      char[5]    TextEchoTime
%5752      char       TextEchoNumber
%5790      char[2]    TextSliceThicknessFlag    ('SL'=slice thickness)
%5794      char[7]    TextSliceThickness
%5802      char[2]    TextSlicePositionFlag     ('SP'=slice position)
%5806      char[7]    TextSlicePosition
%5814      char[3]    TextAngleFlag1	('Sag'=sagittal,'Cor'=coronal,'Tra'=transverse)
%5817      char       TextAngleFlag2            ('>'=gt,'<'=lt)
%5818      char[3]    TextAngleFlag3	('Sag'=sagittal,'Cor'=coronal,'Tra'=transverse)
%5821      char[4]    TextAngle
%5838      char[3]    TextFOVFlag               ('FoV'=field of view)
%5842      char[3]    TextFOVH
%5846      char[3]    TextFOVV
%5874      char[2]    TextTablePositionFlag     ('TP'=table position)
%5878      char[7]    TextTablePosition
%5938      char[5]    TextStudyNumberFlag       ('STUDY'=study)
%5943      char[2]    TextStudyNumber
%5956      char[2]    TextDOBDD
%5959      char[3]    TextDOBMM
%5963      char[4]    TextDOBYYYY
%5992      char[3]    TextStudyNumberFlag2      ('STU'=study)
%5996      char[3]    TextImageNumberFlag2      ('IMA'=study)
%5999      char[2]    TextStudyNumber2
%6002      char[2]    TextImageNumber2
%6013      char[5]    TextStudyImageNumber3
%6031      char[15]   TextModelName
%6058      char[25]   TextPatientName
%6085      char[2]    TextScanStartTimeHH
%6088      char[2]    TextScanStartTimeMM
%6091      char[2]    TextScanStartTimeSS


fclose(fp);

return;
