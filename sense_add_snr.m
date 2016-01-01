function [output]=sense_add_snr(input,snr)
%
% sense_add_snr	add noise based on the suggested SNR to the input signal
%
% [output]=sense_add_snr(input,snr)
% 
% input: N-dimensional input data
% SNR: specified SNR; SNR here is defined as the root-mean-squares (RMS) of the input signal
% output: N-dimensional output data from the sum of the input and the simulated noise (Gaussian noise is used).
%
% fhlin@sep. 15, 2001

%get the energy of the input data
ene_input=input.^2;
for i=1:ndims(input)
	ene_input=sum(ene_input);
end;
ene_input=sqrt(ene_input./prod(size(input)));
fprintf('Input data power (RMS)=[%3.3f]\n',ene_input);

%get the energy of simulated noise data
noise=randn(size(input));
ene_noise=noise.^2;
for i=1:ndims(noise)
	ene_noise=sum(ene_noise);
end;
ene_noise=sqrt(ene_noise./prod(size(noise)));


%scaling factor for noise to fit the suggested SNR
scale=(ene_input/snr)/ene_noise;

noise=noise.*scale;


ene_noise=noise.^2;
for i=1:ndims(noise)
	ene_noise=sum(ene_noise);
end;
ene_noise=sqrt(ene_noise./prod(size(noise)));
fprintf('Simulated noise power (RMS)=[%3.3f]\n',ene_noise);

output=input+noise;
return;