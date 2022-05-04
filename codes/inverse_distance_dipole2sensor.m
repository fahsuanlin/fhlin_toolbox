function [dist]=inverse_distance_dipole2sensor(dipole_index,dipole_info,sensor_info)
% inverse_distnace_dipole2sensor		return the distance (in mm) from a given dipole index to all EEG/MEG sensors
%
% [dist]=inverse_distance_dipole2sensor(dipole_index,dipole_info,sensor_info)	 
% 
%dipole_index: 1-based dipole index
%dipole_info: 6*m matrix from inverse_read_dipdec
%sensor_info: 4*n matrix from inverse_read_eloc
%
%dist: a n*1 vector of distance from the given dipole to all sensors
%
% fhlin@May 07,2001

dip_location=repmat(dipole_info(1:3,dipole_index),[1,size(sensor_info,2)]);
sensor_location=sensor_info(2:4,:);

dist=sqrt(sum((dip_location-sensor_location).^2,1));

return;