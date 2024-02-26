function [DeltaFlour] = DeltaF_stripped(Ch490,Ch405)
% Smooth and process 490 channel and control channel data for fiber
% photometry. 

%Inputs:
% 1--Ch490-GCamp Channel
% 2--Ch405-isosbestic control channel
% 3--Start time- Set a specific sample to start at
% 4--End time-specify a specific ending sample

bls2=polyfit(Ch405(1:end),Ch490(1:end),1);
Y_Fit2=bls2(1).*Ch405+bls2(2);
DeltaFlour=(Ch490(:)-Y_Fit2(:));       

end

