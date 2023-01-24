function [Delta490] = DeltaF(t,Ch490,Ch405,varargin)
% Smooth and process 490 channel and control channel data for fiber
% photometry. 

%Inputs:
% 1--Ch490-GCamp Channel
% 2--Ch405-isosbestic control channel
% 3--Start time- Set a specific sample to start at
% 4--End time-specify a specific ending sample
%mdir,smthing,movavg,Ma_Sm,Value_Wavelength,ManArt,


mdir=varargin{1};

%     Ch490=Ch490(1,varargin{1}:end)'; %GCaMP
%     Ch405=Ch405(1,varargin{1}:end)'; %Isosbestic Control

%     Ch490=Ch490(1,varargin{1}:varargin{2})'; %GCaMP
%     Ch405=Ch405(1,varargin{1}:varargin{2})'; %Isosbestic Control
smthing=varargin{2};

movavg=varargin{3};

Ma_Sm=varargin{4};

Value_Wavelength=varargin{5};

ManArt=varargin{6};

name=['F' Value_Wavelength];
name1=['Ch ' Value_Wavelength];
 F490=Ch490;
 F405=Ch405;

% if Ma_Sm==1 && ManArt==0
% F490=smooth(Ch490,smthing,'rloess'); 
% F405=smooth(Ch405,smthing,'rloess');
% else
% %%Moving Average instead of Lowess.
%  F490=smooth(Ch490,movavg,'moving'); 
%  F405=smooth(Ch405,movavg,'moving');
% end


bls=polyfit(F405(1:end),F490(1:end),1);
%scatter(F405(10:end-10),F490(10:end-10))

Y_Fit=bls(1).*F405+bls(2);

%figure
Delta490=(F490(:)-Y_Fit(:))./Y_Fit(:);
DeltaFlour=(F490(:)-Y_Fit(:));
figure('units','normalized','outerposition',[0 0 1 1])

subplot (2,3,1);plot(t,Ch490,'b');hold on;plot(t,Ch405,'r');ylabel([name1 ' & Ch 405']);xlabel('Time (Seconds)')
legend({name,'Ch405'})
%subplot (1,3,2);plot(Z490);hold on;plot(Z405);
subplot (2,3,2);plot(t,F490,'b');hold on;plot(t,F405,'r');ylabel([name ' & F 405']);xlabel('Time (Seconds)')
legend({name,'F405'})
hold off

subplot(2,3,3)
hold on
plot(t,F490(:),'b')
plot(t,Y_Fit,'r')
hold off
ylabel([name ' & Fit Isobestic'])
xlabel('Time (Seconds)')
legend({name,'Fit Isobestic'})
subplot(2,3,4)
plot(t,DeltaFlour(:),'b')
hold on
line(xlim(), [0,0], 'LineWidth', 2, 'Color', 'k');
hold off
ylabel('\Delta F')
xlabel('Time (Seconds)')

subplot(2,3,5)
plot(t,Delta490.*100,'b')
hold on
line(xlim(), [0,0], 'LineWidth', 2, 'Color', 'k');
hold off
ylabel('% \Delta F/F0')
xlabel('Time (Seconds)')
title('\Delta F/F for Recording ')

FastPrint('WholeSessionTrace',mdir);

figure('units','normalized','outerposition',[0 0 1 1])

subplot (2,3,1);plot(t,Ch490,'b');hold on;plot(t,Ch405,'r');ylabel([name1 ' & Ch 405']);xlabel('Time (Seconds)')
legend({name,'Ch405'})
%subplot (1,3,2);plot(Z490);hold on;plot(Z405);
subplot (2,3,2);plot(t,F490,'b');hold on;plot(t,F405,'r');ylabel([name ' & F 405']);xlabel('Time (Seconds)')
legend({name,'F405'})
hold off

subplot(2,3,3)
hold on
plot(t,F490(:),'b')
plot(t,Y_Fit,'r')
hold off
ylabel([name ' & Fit Isobestic'])
xlabel('Time (Seconds)')
legend({name,'Fit Isobestic'})
subplot(2,3,4)
plot(t,DeltaFlour(:),'b')

ylabel('\Delta F')
xlabel('Time (Seconds)')

subplot(2,3,5)
plot(t,Delta490.*100,'b')

ylabel('% \Delta F/F0')
xlabel('Time (Seconds)')
title('\Delta F/F for Recording ')

FastPrint('WholeSessionTraceWithout0line',mdir);
end

