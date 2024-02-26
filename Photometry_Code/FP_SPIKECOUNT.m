function [Final_Spikes] = FP_SPIKECOUNT(DF_DEBLEACHED,Threshold, Ts,Fs, Hold_Constant, ZERO_RULE)
%% By David Estrin & David Barker for the Barker Laboratory
% Code is written for ____ et al., 2020
% The purpose of this code is to take debleached calcium signal previously
% calculated in FP_DEBBLEACHED.m function and determine what is and is not
% a calcium transient ("spike"). 

%% The following are Inputs:
% 1--DF_DEBLEACHED- A debleached/detrended calcium trace
% 2--Threshold- Enter manual threshold value (typically set to 2.5 standard
%    devisions)
% 3--Hold_Constant- The miminum amount of time between two calcium
%    transients to be considered seperate events (in seconds). If set to 0,
%    this feature will be skipped.
% 4--ZERO_RULE- Enter 0 (no, do not use) or 1 (Yes, use zero rule) to use
%    the zero rule. The zero rule means that a calcium transient must go back
%    to 0 before a new calcium transient can be counted.

%% The following are Outputs:
% 1-- Final_Spikes- matrix of onsets and offsets for calcium transients that
%     were determined as true spikes after appplying the hold constant and/or
%     zero rule. 

%% Example use of this function:
%  [Fiber_Photometry_Trace]=DeltaF(Ch490,Ch405); %Get Trace 
%
%  [Fiber_Photometry_Trace_Debleached_1, Fiber_Photometry_Trace_Debleached_2] = ...
%       FP_DEBLEACHED(Fiber_Photometry_Trace, 15, 100); %Debleach Trace
%   
%  [Spikes] = FP_SPIKECOUNT(Fiber_Photometry_Trace_Debleached_2,3, 1, 1); %Get spikes
%


%% Set up variables
clearvars -except DF_DEBLEACHED Threshold  Hold_Constant ZERO_RULE Ts Fs
DF=DF_DEBLEACHED; % Debleached trace we just loaded in
DF(:,2)=(DF(:,1)>Threshold); %Apply threshold to debleached trace
Spikes(:,1)=find(DF(:,2)==1); %Preliminary variable for spikes
DF_ZERO=find(floor(DF)==0); %Find where debleached trace equals zero
if Hold_Constant==0
   Hold_Constant=[];
end 

%% Apply the "Zero Rule" or not
if ZERO_RULE ==1
    %% Find Spike onsets
    counter=2;
    Spike_series_onsets(1,1)=Spikes(1,1);
    for loop=1:length(Spikes)
        if (Spikes(loop+1,1)-Spikes(loop,1))~=1
        Spike_series_onsets(counter,1)=Spikes(loop+1,1);
        counter=counter+1;
        end 
        if (loop+1)==length(Spikes)
            break
        end 
    end 
    %% Find the offsets for spikes via Zero Rule
    for loop=1:length(Spike_series_onsets)
        Closest_end=(DF_ZERO-Spike_series_onsets(loop));
        Spike_series_offsets(loop,1)=Spike_series_onsets(loop)+min(Closest_end(Closest_end>0));
    end 
    %% Determine final list of spikes
    Zero_rule_spikes=zeros(length(Spike_series_offsets),3);
    Zero_rule_spikes(1,3)=1;
    for loop=1:length(Spike_series_offsets)
        if Spike_series_offsets(loop+1,1)~=Spike_series_offsets(loop,1)
            Zero_rule_spikes(loop+1,3)=1;
        end 
        if (loop+1)==length(Spike_series_offsets)
            break
        end 
    end 
    Zero_rule_spikes(:,1)=Spike_series_onsets(:,1);
    Zero_rule_spikes(:,2)=Spike_series_offsets(:,1);
    Zero_rule_spikes((Zero_rule_spikes(:,3)==0),:)=[];
    Zero_rule_spikes(:,3)=[];
    
    %% APPLY the Hold Constant
    if ~isempty(Hold_Constant)
    HOLD_CONSTANT=Hold_Constant*Fs;
    Spikes_hold=[];
    for loop=1:length(Zero_rule_spikes(:,1))
        Spikes_hold(loop,1)=((Zero_rule_spikes(loop+1,1)-Zero_rule_spikes(loop,1))<HOLD_CONSTANT);
        if loop==(length(Zero_rule_spikes)-1)
            break
        end 
    end
    
    Spike_conv=[0 1 ]; %Single correction
    Spike_conv2= [ 1 0 ]; %Finish of series correction
    Index  = strfind(Spikes_hold', Spike_conv);
    Index2  = strfind(Spikes_hold', Spike_conv2);
    
    Index2=Index2(Index2(1,:)>Index(1,1));
    
    tmpSpikes(:,1)=Zero_rule_spikes(Index+1,1);
    tmpSpikes(:,2)=Zero_rule_spikes(Index2+1,2);
    Final_Spikes=tmpSpikes;
   
    %% Merge Spikes based on Hold Constant CREATE new variable ? 
%     Spike_conv=[0 1 0]; %Single correction
%     Spike_conv2=[0 1 1 ]; %Start of series correction
%     Spike_conv3= [1 1 0 ]; %Finish of series correction
%     %Ends with 111 
%     Index  = strfind(Spikes_hold', Spike_conv);
%     Index2  = strfind(Spikes_hold', Spike_conv2);
%     Index3  = strfind(Spikes_hold', Spike_conv3);
%     
%     Zero_rule_spikes2=Zero_rule_spikes;
%     
%     %% Merge Spikes based on Hold Constant CREATE new variable ? 
%     % 0 1 0  t= 1 s t=3s 
%     if ~isempty(Index)
%         for loop=1:length(Index)
%             Zero_rule_spikes(Index(loop)+1,2)=Zero_rule_spikes(Index(loop)+2,2);
%             Matrix(loop,1)=Zero_rule_spikes(Index(loop),1);
%             Matrix(loop,2)=Zero_rule_spikes(Index(loop)+2,2);
%             
%         end 
%         Zero_rule_spikes(Index+2,:)=[];
%     end 
%     %Do we remove anything greater than length of zero rule spikes
%     
%     %Created a zero_rule_spikes2
%     if ~isempty(Index2) % Find the start and end of spike
%             for loop=1:length(Index2)-1
%                 Zero_rule_spikes2(Index2(loop),2)=Zero_rule_spikes2(Index3(loop)+1,2);
%                 Zero_rule_spikes2((Index2(loop)+1):(Index3(loop)),1)=NaN;
%                 Zero_rule_spikes2((Index2(loop)+1):(Index3(loop)),2)=NaN;
%                 if loop==length(Index2)
%                     if length(Index2)>length(Index3)
%                         break 
%                     end 
%                 end 
%             end 
%             Zero_rule_spikes2(find(isnan(Zero_rule_spikes2(:,1))),:)=[];
%     end 
%     
%     Final_Spikes=Zero_rule_spikes;
    else
     %% DO NOT APPLY HOLD CONSTANT   
     Final_Spikes=Zero_rule_spikes;
     fprintf('The Hold_Constant was not applied for spike generation \n');
     fprintf('The Zero Rule was applied \n');   
    end 

else
    %% DO NOT APPLY ZERO RULE
    fprintf('The Zero_Rule was not applied for spike generation \n');  
    counter=2;
    counter2=1;
    Spike_series_onsets(1,1)=Spikes(1,1);
    Spike_series_offsets=[];
    for loop=1:length(Spikes)
        if (Spikes(loop+1,1)-Spikes(loop,1))~=1
        Spike_series_onsets(counter,1)=Spikes(loop+1,1);
        Spike_series_offsets(counter2,1)=Spikes(loop,1);
        counter=counter+1; counter2=counter2+1;
        end 
        if (loop+1)==length(Spikes)
            Spike_series_offsets(end+1,1)=Spikes(end);
            break
        end 
    end 
    Spike_series=[Spike_series_onsets Spike_series_offsets];
    
    %% APPLY the Hold Constant
    if ~isempty(Hold_Constant)
        HOLD_CONSTANT=Hold_Constant*Fs;
        Spikes_hold=[];
        for loop=1:length(Spike_series(:,1))
            Spikes_hold(loop,1)=((Spike_series(loop+1,1)-Spike_series(loop,1))<HOLD_CONSTANT);
            if loop==(length(Spike_series)-1)

                break
            end 
        end
        
    Spike_conv=[0 1 ]; %Single correction
    Spike_conv2= [ 1 0 ]; %Finish of series correction
    Index  = strfind(Spikes_hold', Spike_conv);
    Index2  = strfind(Spikes_hold', Spike_conv2);
    
    Index2=Index2(Index2(1,:)>Index(1,1));
    
    tmpSpikes(:,1)=Spike_series(Index+1,1);
    tmpSpikes(:,2)=Spike_series(Index2+1,2);
    Final_Spikes=tmpSpikes;
   
%         Spike_conv=[0 1 0]; %Single correction
%         Spike_conv2=[0 1 1 ]; %Start of series correction
%         Spike_conv3= [1 1 0 ]; %Finish of series correction
%         Index  = strfind(Spikes_hold', Spike_conv);
%         Index2  = strfind(Spikes_hold', Spike_conv2);
%         Index3  = strfind(Spikes_hold', Spike_conv3);
% 
%         %% Merge Spikes based on hold constant
%         if ~isempty(Index)
%             for loop=1:length(Index)
%                 Spike_series(Index(loop)+1,2)=Spike_series(Index(loop)+2,2);
%             end 
%             Spike_series(Index+2,:)=[];
%         end 
% 
%         if ~isempty(Index2)
%             for loop=1:length(Index2)
%                 Spike_series(Index2(loop),2)=Spike_series(Index3(loop)+1,2);
%                 Spike_series((Index2(loop)+1):(Index3(loop)),1)=NaN;
%                 Spike_series((Index2(loop)+1):(Index3(loop)),2)=NaN;
%                 if loop==length(Index2)
%                     if length(Index2)>length(Index3)
%                         break 
%                     end 
%                 end 
%             end 
%             Spike_series(find(isnan(Spike_series(:,1))),:)=[];
%         end 
%         Final_Spikes=Spike_series;
        
    else
         %% DO NOT APPLY HOLD CONSTANT  
         Final_Spikes=Spike_series;
         fprintf('The Hold_Constant was not applied for spike generation \n');
         fprintf('The Zero Rule was not applied \n');   
    end 


end 

%% Plot Results
 DF_DEBLEACHED_ZERO=zeros(length(DF_DEBLEACHED),2);
 DF_DEBLEACHED_ZERO(:,1)=DF_DEBLEACHED(:,1); 
for loop=1:length(Final_Spikes)
    DF_DEBLEACHED_ZERO(Final_Spikes(loop,1):Final_Spikes(loop,2),2)=1;
end
DF_DEBLEACHED_ZERO(:,3)=(1:length(DF_DEBLEACHED_ZERO(:,1)))'./Fs;
DF_DEBLEACHED_ZERO(:,2)= DF_DEBLEACHED_ZERO(:,2)+max(DF_DEBLEACHED_ZERO(:,1)); % Maybe change. Max * 1.25? above the signal. 
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'color','w');
plot(DF_DEBLEACHED_ZERO(:,3), DF_DEBLEACHED_ZERO(:,1), 'LineWidth',2)
hold on
%plot(DF_DEBLEACHED_ZERO(:,3),(DF_DEBLEACHED_ZERO(:,2)-5), 'LineWidth',2) %Old
%version of plotting spikes, remove after 9/18 unless otherwise noted (DJE)
line([Final_Spikes(:,1)./Fs Final_Spikes(:,1)./Fs], [(max(DF_DEBLEACHED_ZERO(:,1))+1) (max(DF_DEBLEACHED_ZERO(:,1))+5)],'color','k', 'LineWidth',2)
line([Final_Spikes(:,2)./Fs Final_Spikes(:,2)./Fs], [(max(DF_DEBLEACHED_ZERO(:,1))+1) (max(DF_DEBLEACHED_ZERO(:,1))+5)],'color','r', 'LineWidth',2)
plot([0 length(DF_DEBLEACHED_ZERO)],[Threshold Threshold],'--k','LineWidth',2)
xlim([0 length(DF_DEBLEACHED_ZERO)./Fs])
set(gca,'box','off');
xlabel('TIME');
ylabel('Normalized dF/F');
set(findall(gcf,'-property','FontSize'),'FontSize',18)
end

