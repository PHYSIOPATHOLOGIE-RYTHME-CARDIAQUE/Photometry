%******************************************************************************
% Calcium Photometry  Analysis Use of Pmat from Parker Lab for some
% procedures DeltaF.m FastPrint
% Prabahan Janneteau code Fontanaud
% 03/08/2021 mise a jour du 01/09/2022
% procedure menu :  https://fr.mathworks.com/matlabcentral/answers/101271
% -is-it-possible-to-reshape-the-column-of-edit-boxes-in-inputdlg-such-that-the-questions-span-multiple
%
% artifacts removal : https://fr.mathworks.com/matlabcentral/answers/358022-how-to-remove-artifacts-from-a-signal
% ajout des procedures de pmat pour detecter les spikes
%******************************************************************************

close all

clear
clc
Other_Behavior_Format=1;
Artifact=1;
etapes=6;
%Smoothing_a_Coartmanu=0.05;
[fname,chemin]=uigetfile('*.*','MultiSelect','on');%loads file


if isequal([fname chemin],[0,0])
    return
else

    fname=sort(fname);


    datname=[chemin char(fname{1})];
    raw=importdata(datname,',',2);


    AOut_2=raw.data(~isnan(raw.data(:,2)),2);
    AOut_3=raw.data(~isnan(raw.data(:,3)),3);
    time_tmp=raw.data(1:length(AOut_2),1);



    alldt =diff(time_tmp);
    dt=alldt(1);fs=1/dt;
    time=(0:length(time_tmp)-1)*dt;
    %     FcutNorm=3*2/fs;
    %     FcutNormiso=3*2/fs;
    %
    %     sigF=designfilt('lowpassiir','FilterOrder',10, ...
    %         'HalfPowerFrequency',FcutNorm,'DesignMethod','butter');
    %
    %     isoF = designfilt('lowpassiir','FilterOrder',10, ...
    %         'HalfPowerFrequency',FcutNormiso,'DesignMethod','butter');
    %
    %
    %
    %
    %     AOut_2 = filtfilt(sigF,raw.data(~isnan(raw.data(:,2)),2));
    %     AOut_3= filtfilt(isoF,raw.data(~isnan(raw.data(:,3)),3));



    End_rec=time(end);
    AOut_3_raw=raw.data(1:length(AOut_2),4);
    %*****************************************************
    %
    %
    d2 = [0; diff( AOut_2 )] ;
    d3= [0; diff( AOut_3 )] ;

    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(1,4,1)
    plot(time, AOut_2,'b')
    legend('GCamp')
    subplot(1,4,2)
    plot(time, AOut_3,'g')
    legend('Isobestic Control')
    subplot(1,4,3)
    plot(time, d2,'r')
    legend('derivative GCamp')
    subplot(1,4,4)
    plot(time,d3,'r')
    legend('derivative Isobestic Control ')

    %
    %
    %********************************************************
    display('Series Temporelles Photometrie ');

    %**********************************************************************



    %**********************************************************************
    prompt = {'Start Period:',...%1
        'Fin Period:',...        %2
        'File Name Calcium',...  %3
        'File Name Behaviour',...%4
        'Generic Directory Results',...%5
        'Correction Artifact (O no/1 yes)',...%6
        'Value For Correction',...%7
        'pre window time for Behavioral Episode in sec',...%8
        'post window time for Behavioral Episode in sec',...%9
        'Delimiter',...%10
        'window sec for Artifacts Removal',...%11
        'Smoothing value',...%12
        'Moving average value',...%13
        'Smoothing or Moving Average (1/0)',...%14
        'percentage of max for Threshold Artifacts Removal',...%15
        'Wavelength',...%16
        'Manual Artifact Removal',...%17
        'Back to Manual Artifacts',...%18
        'Points Number for trend estimate',...%19
        'Use AirPLS 0 no/1 yes',...%20
        'Lambda for AirPLS',...%21
        'Use Spike Detection(0/1)',...%22
        'Initiate at zero (0/1)',...%23
        'Median Absolute',...%24
        'Windows size',...%25
        'Iterations',...%26
        'Threshold',...%27
        'Hold Time (0/1)'};%28
    dlg_title = 'Series Temporelles Photometrie ';
    num_lines = [1  50];

    def = {'10',... %1 Start Period
        num2str(End_rec),... %2 Fin Period
        char(fname{1}),... %3
        char(fname{2}),... %4
        ['Results',strtok(char(fname{1}),'.')],... %5
        '0',... %6
        '0.1',... %7
        '1',... %8
        '2',... %9
        ';',... %10
        '2',... %11
        '0.001',...%12
        '299',...%13
        '1',...%14
        '0.60',...;%15
        '480',...%16
        '1',...%17
        '0',...%18
        '10000',...%19
        '0',...%20
        '800e10',...;%21
        '1',...%22
        '1',...%23
        '1',...%24
        '15',...%25
        '100',...%26
        '2.91',...%27
        '0'};%28


    Aopts.Resize='on';
    Aopts.WindowStyle='normal';
    Aopts.Interpreter='none';
    %answer = inputdlg(prompt,dlg_title,num_lines,def,opts);
    answer=inputdlgcol(prompt,dlg_title,num_lines,def,Aopts,2);

    if ~isempty(answer)
        dir_result=[chemin,answer{5},'\'];

        if (exist(dir_result)==0)
            mkdir(dir_result)
        end

        FastPrint('Raw Signal And derivative',dir_result);

        f = waitbar(0,'Please wait...');

        datname=[chemin char(fname{1})];
        raw=importdata(datname,',',2);
        datname=[chemin char(fname{2})];
        warning('off')
        Behav=readtable(datname,'Delimiter',answer{10});%,'VariableNamingRule','preserve');
        %Behav=importdata(datname,'Delimiter',answer{11});
        warning('on')
        movmin_win=str2double(answer{19});
        % debut du signal de Photometrie
        % debut_Signal=round(str2double(answer{1})/dt);

        % fin du signal de photometrie
        % Fin_Signal=round(str2double(answer{2})/dt);

        Start_Analyse=str2double(answer{1}); % Start Period
        End_Analyse=str2double(answer{2}); % Fin Period
        Startime=Behav.Start;
        Endtime=Behav.Stop;
        %tmp=Startime(1);
        if Startime(1)==0

            Startime(1)=dt;
        end
        %Endtime=[tmp; Endtime];
        if Endtime(end)>End_Analyse
            Endtime(end)=End_Analyse;
        end
        % [Startime, Isort]=sort(Startime);
        % Endtime=Endtime(Isort);
        Label_Behaviour=Behav.Behavior;
        %Label_Behaviour=['pre'; Label_Behaviour];
        % Label_Behaviour=Label_Behaviour(Isort);

        waitbar(1/etapes,f,sprintf('%3f',1))
        if Start_Analyse<=dt
            StartP=1;
            EndP=round(End_Analyse/dt);

        else
            StartP=round(Start_Analyse/dt);
            EndP=round( End_Analyse/dt);

            Startime=Startime-Start_Analyse;
            Endtime=Endtime-Start_Analyse;

        end


        AOut_2_lim= AOut_2( StartP: EndP,1);
        AOut_3_lim= AOut_3( StartP: EndP,1);

        time=(0: size( AOut_2_lim,1)-1).*dt;

        Start_Analyse=time(1);
        End_Analyse=time(end);

        correction_artifact=str2double(answer{6});
        prefenetre=str2double(answer{8});
        postfenetre=str2double(answer{9}); % 1 sec
        prefenetre_points=round(prefenetre/dt);
        postfenetre_points=round(postfenetre/dt);
        windows_debleach=round(str2double(answer{11})/dt);
        rate_deriv=str2double(answer{7});
        smoothing=str2double(answer{12});
        maverage=str2double(answer{13});
        choixMa_Sm=str2double(answer{14});
        perc_max_Threshold=str2double(answer{16});
        Wavelenght=answer{17};
        Manual_A_R=str2double(answer{17});
        flag_airPLS=str2double(answer{20});
        lambda=str2double(answer{21});
        flag_UseSpike=str2double(answer{22});
        Threshold=str2double(answer{27});
        Hold_Constant=str2double(answer{28});
        Iterations=str2double(answer{26});
        Windows_size=str2double(answer{25});
        Median_Absolute=str2double(answer{24});
        Zero_Rule=str2double(answer{23});



        Already_Filtered=0;

        %
        Update_Graph_ManualArtifact=str2double(answer{18});



        Calcium_Transient=[];tmp=[];

        tmp= Startime;


        Index_time_r=tmp>=Start_Analyse & tmp<=End_Analyse;
        Startime=tmp(Index_time_r);


        Label_Behaviour=Label_Behaviour(Index_time_r);
        tmp=Endtime;
        Endtime=tmp(Index_time_r);


        Diff_Timebehav=Endtime-Startime;
        index_post=find(Diff_Timebehav<=End_Analyse);
        Label_Behaviour_post=Label_Behaviour(index_post);
        Startime_post=Startime(index_post);
        Endtime_post=Endtime(index_post);
        Labels=cellstr(unique(Label_Behaviour,'stable'));



        nbre_max_behave=[];


        for i=1:size(Labels,1)
            nbre_max_behave(i)=length(find(strcmp(Labels(i),char(Label_Behaviour))));


        end

        if correction_artifact==1
            [signalClean_2,signalClean_3] = RemoveArtifacts(  AOut_2_lim,  AOut_3_lim, windows_debleach,perc_max_Threshold);
            signalClean_2_c=signalClean_2;
            signalClean_3_c= signalClean_3;
        else
            signalClean_2= AOut_2_lim;
            signalClean_3= AOut_3_lim;%bmin= movmin(signalClean_2,500);
            signalClean_2_c= AOut_2_lim;
            signalClean_3_c= AOut_3_lim;

        end
        if Manual_A_R==0 %

            S_2db = signalClean_2;
            S_3db = signalClean_3;
            %            signalClean_2= smooth(S_2db,smoothing,'loess');
            %            signalClean_3=smooth( S_3db,smoothing,'loess');
            %********************************************************************************
            %
            %********************************************************************************
            %            trend=polyfit(time, signalClean_2,2);
            %            FittedCurve=polyval(trend,time);
            tic
            if flag_airPLS==0
                bmin1=movmin(signalClean_2,movmin_win);

                FittedCurve2=smooth(bmin1,0.1,'loess');
                toc

                Res_Cal=  signalClean_2 - FittedCurve2;
                diff_Cal=signalClean_2(1)-Res_Cal(1);
                signalClean_2=Res_Cal+diff_Cal;

                %             trend=polyfit(time, signalClean_3,2);
                %            FittedCurve=polyval(trend,time);
                tic
                bmin2=movmin(signalClean_3,movmin_win);
                FittedCurve3=smooth( bmin2,0.1,'loess');
                toc
                Res_Cal=  signalClean_3 - FittedCurve3;
                diff_Cal=signalClean_3(1)-Res_Cal(1);
                signalClean_3=Res_Cal+diff_Cal;
                figure
                subplot(2,1,1)
                plot(time,signalClean_2,time,FittedCurve2)
                subplot(2,1,2)
                plot(time,signalClean_3,time,FittedCurve3)
                FastPrint('trend_+rectified',dir_result);
                figure
                subplot(2,1,1)
                plot(time,AOut_2_lim,time,FittedCurve2)
                subplot(2,1,2)
                plot(time,AOut_3_lim,time,FittedCurve3)
                FastPrint('trend_+Raw',dir_result);



            else
                [signalClean_2c,signalClean_2bl]=airPLS(signalClean_2', lambda);
                [signalClean_3c,signalClean_3bl]=airPLS(signalClean_3', lambda);
                signalClean_2c=signalClean_2c';
                diff_Cal=signalClean_2(1)-signalClean_2c(1);
                signalClean_2=signalClean_2c+diff_Cal;
                signalClean_3c=signalClean_3c';
                diff_Cal=signalClean_3(1)-signalClean_3c(1);
                signalClean_3=signalClean_3c+diff_Cal;

                figure
                subplot(2,1,1)
                plot(time,signalClean_2,time,signalClean_2bl)
                subplot(2,1,2)
                plot(time,signalClean_3,time,signalClean_3bl)
                FastPrint('trend_+rectified',dir_result);
                figure
                subplot(2,1,1)
                plot(time,AOut_2_lim,time,signalClean_2bl)
                subplot(2,1,2)
                plot(time,AOut_3_lim,time,signalClean_3bl)
                FastPrint('trend_+Raw',dir_result);


            end

           

            %********************************************************************************
            %
            %********************************************************************************

            S_2db = signalClean_2;
            S_3db = signalClean_3;

            if choixMa_Sm==1

                signalClean_2= smooth(S_2db,0.1,'loess');
                signalClean_3=smooth( S_3db,0.1,'loess');
            else
                signalClean_2=smooth(S_2db);
                signalClean_3=smooth(S_3db);
            end

            Dff = DeltaF(time,signalClean_2,signalClean_3,dir_result,smoothing, maverage,choixMa_Sm,Wavelenght,Already_Filtered);
        else

            [F490,F405]=Manual_Removal_Artifacts(time,signalClean_2,signalClean_3,smoothing,dir_result,Update_Graph_ManualArtifact);

            Already_Filtered=1;
            %%
            signalClean_2=[F490(1) F490];
            signalClean_3=[F405(1) F405];

            figure('Name','Press Return when Done','units','normalized','outerposition',[0 0 1 1],'KeyPressFcn',@(obj,evt) 0)
            subplot(2,1,1)
            hold on
            plot(time,signalClean_2_c,'b')
            plot(time,signalClean_3_c,'r')

            hold off
            subplot(2,1,2)
            hold on
            plot(time,signalClean_2,'b')
            plot(time,signalClean_3,'r')

            hold off
            %*******************************************
            waitfor(gcf,'CurrentCharacter');
            curChar=uint8(get(gcf,'CurrentCharacter'));
            %*******************************************

            close(gcf)









            %             [signalClean_2,Z1]= airPLS(signalClean_2',10e10);
            signalClean_2=signalClean_2';
            %             [signalClean_3,Z2]= airPLS(signalClean_3',10e10);
            signalClean_3= signalClean_3';
            %********************************************************************************
            %
            %********************************************************************************
            %            trend=polyfit(time, signalClean_2,2);
            %            FittedCurve=polyval(trend,time);
            tic

            if flag_airPLS==0
                bmin1=movmin(signalClean_2,movmin_win);

                FittedCurve2=smooth(bmin1,smoothing,'loess');
                toc

                Res_Cal=  signalClean_2 - FittedCurve2;
                diff_Cal=signalClean_2(1)-Res_Cal(1);
                signalClean_2=Res_Cal+diff_Cal;

                %             trend=polyfit(time, signalClean_3,2);
                %            FittedCurve=polyval(trend,time);
                tic
                bmin2=movmin(signalClean_3,movmin_win);
                FittedCurve3=smooth(bmin2,smoothing,'loess');
                toc
                Res_Cal=  signalClean_3 - FittedCurve3;
                diff_Cal=signalClean_3(1)-Res_Cal(1);
                signalClean_3=Res_Cal+diff_Cal;

                figure
                subplot(2,1,1)
                plot(time,signalClean_2,time,FittedCurve2)
                subplot(2,1,2)
                plot(time,signalClean_3,time,FittedCurve3)
                FastPrint('trend_+rectified',dir_result);
                figure
                subplot(2,1,1)
                plot(time,AOut_2_lim,time,FittedCurve2)
                subplot(2,1,2)
                plot(time,AOut_3_lim,time,FittedCurve3)
                FastPrint('trend_+Raw',dir_result);
            else
                [signalClean_2c,signalClean_2bl]=airPLS(signalClean_2', lambda);
                [signalClean_3c,signalClean_3bl]=airPLS(signalClean_3', lambda);
                signalClean_2c=signalClean_2c';
                diff_Cal=signalClean_2(1)-signalClean_2c(1);
                signalClean_2=signalClean_2c+diff_Cal;
                signalClean_3c=signalClean_3c';
                diff_Cal=signalClean_3(1)-signalClean_3c(1);
                signalClean_3=signalClean_3c+diff_Cal;
                figure
                subplot(2,1,1)
                plot(time,signalClean_2,time,signalClean_2bl)
                subplot(2,1,2)
                plot(time,signalClean_3,time,signalClean_3bl)
                FastPrint('trend_+rectified',dir_result);
                figure
                subplot(2,1,1)
                plot(time,AOut_2_lim,time,signalClean_2bl)
                subplot(2,1,2)
                plot(time,AOut_3_lim,time,signalClean_3bl)
                FastPrint('trend_+Raw',dir_result);

            end

        end

        %********************************************************************************
        %
        %********************************************************************************
        S_2db = signalClean_2;
        S_3db = signalClean_3;

        if choixMa_Sm==1
            signalClean_2= smooth(S_2db,smoothing,'loess');
            signalClean_3=smooth( S_3db,smoothing,'loess');
        else
            signalClean_2=smooth(S_2db);
            signalClean_3=smooth(S_3db);
        end
        Dff = DeltaF(time, signalClean_2, signalClean_3,dir_result,smoothing,...
            maverage,choixMa_Sm,Wavelenght,Already_Filtered);

    end



    waitbar(2/etapes,f,sprintf('%3f',2))

    Fiber_Photometry_Trace_Debleached_1=zscore(Dff);

    waitbar(3/etapes,f,sprintf('%3f',3))
    %*******************************************************************
    % episodes
    %*******************************************************************

    %**********************************************************************************************************************
    % figure Affichage superposés de l'expérience avec  les périodes de
    % comportements
    %
    %************************************************************************************************************************
    %%
    [C,ia,ic] = unique(Label_Behaviour);
    a_counts = accumarray(ic,1);


    time_transient=-prefenetre:dt:postfenetre;%+dt;

    Calcium_Transient{size(Labels,1),max(a_counts)}=[];Cal_Trans=time_transient';
    Calcium_Transient_Behavior=[];
    %Calcium_Transient_prepost{size(Labels,1),max(tmp)}=[];Cal_Trans_post=time_transient';



    % figure repeat twice
    for fig_repeat=1:3

        figure('units','normalized','outerposition',[0 0 1 1])

        %Markers = {'+','o','*','x','v','d','s'};
        colormap(jet(size(Labels,1)));
        cmap=colormap;
        %linecolors = jet(256);
        % c_color={'r','b','g','c','k','m','y'};    %
        plot(time,Fiber_Photometry_Trace_Debleached_1)
        hold on
        if fig_repeat==1
            line(xlim(), [0,0], 'LineWidth', 2, 'Color', 'k');
        end

        p1=[];
        for i=1:size(Label_Behaviour,1)

            j=find(strcmp(Labels,char(Label_Behaviour{i})));
            if i<=size(Label_Behaviour,1)

                Calcium_Transient_Behavior{i}=Fiber_Photometry_Trace_Debleached_1(round( Startime(i)/dt):round(  Endtime(i)/dt),1);

                x=[time(round( Startime(i)/dt)) time(round( Startime(i)/dt)) time(round(Endtime(i)/dt))  time(round(Endtime(i)/dt))];
                if fig_repeat<=2
                    y=[max(Fiber_Photometry_Trace_Debleached_1)+2 max(Fiber_Photometry_Trace_Debleached_1)+4  max(Fiber_Photometry_Trace_Debleached_1)+4 max(Fiber_Photometry_Trace_Debleached_1)+2];
                else
                    y=[0 max(Fiber_Photometry_Trace_Debleached_1)  max(Fiber_Photometry_Trace_Debleached_1) 0];
                end
            else
                Calcium_Transient_Behavior{i}=Fiber_Photometry_Trace_Debleached_1(round( Startime(i)/dt):end,1);

                x=[time(round( Startime(i)/dt)) time(round( Startime(i)/dt)) time(end)  time(end)];

                if fig_repeat<=2
                    y=[max(Fiber_Photometry_Trace_Debleached_1)+2 max(Fiber_Photometry_Trace_Debleached_1)+4  max(Fiber_Photometry_Trace_Debleached_1)+4 max(Fiber_Photometry_Trace_Debleached_1)+2];
                else
                    y=[0 max(Fiber_Photometry_Trace_Debleached_1)  max(Fiber_Photometry_Trace_Debleached_1) 0];
                end
            end
            if fig_repeat==1
                for k_1=1:size(Calcium_Transient,2)
                    if isempty(Calcium_Transient{j,k_1})
                        k=k_1;
                        break;
                    end
                end



                %************************************************************************
                if (round( Startime(i)/dt)-prefenetre_points)<1
                    Calcium_Transient{j,k}=Fiber_Photometry_Trace_Debleached_1(1:round( Startime(i)/dt)+prefenetre_points+postfenetre_points,1);


                elseif (round( Startime(i)/dt)+postfenetre_points)>size(Dff,1)
                    Calcium_Transient{j,k}=Fiber_Photometry_Trace_Debleached_1(round( Startime(i)/dt)-prefenetre_points:end,1);


                else
                    Calcium_Transient{j,k}=Fiber_Photometry_Trace_Debleached_1(round( Startime(i)/dt)-prefenetre_points:round( Startime(i)/dt)+postfenetre_points,1);


                end
                tmp_cal_sweep=Calcium_Transient{j,k};
                if (size(tmp_cal_sweep,1)>size(time_transient,2))
                    time_transient=-prefenetre:dt:postfenetre+dt;
                    Cal_Trans=reshape(time_transient',[],1);
                    Cal_Trans(:,1)=time_transient';
                elseif (size(tmp_cal_sweep,1)<size(time_transient,2))
                    tmp_cal_sweep=[tmp_cal_sweep; zeros(abs(size(tmp_cal_sweep,1)-size(time_transient,2)),1)]
                end


                Cal_Trans=[Cal_Trans tmp_cal_sweep];



            end
            p=patch(x,y,cmap(j,:),'FaceAlpha',0.3,'EdgeColor','none');
            objet_patch(j)=p;



        end
        legend(objet_patch,Labels, 'location', 'northeastoutside');
        hold off
        if fig_repeat==1
            FastPrint('ZscoreCal_Behavior',dir_result);
        elseif fig_repeat==2
            FastPrint('ZscoreCal_BehaviorWithout0line',dir_result);
        else
            FastPrint('ZscoreCal_BehaveWithTrace',dir_result);
        end

    end
    waitbar(4/etapes,f,sprintf('%3f',4))
    %************************************************************
    %
    %************************************************************

    %


    %***************************************************************
    %*
    %**************************************************************


    figure('units','normalized','outerposition',[0 0 1 1])




    tmp_AUC=[];Calcium_Transient_AUC=zeros(6*size(Labels,1),500);Calcium_Transient_AUC(:,:)=nan;
    k=1;
    for i=1:size(Calcium_Transient,1)
        tmp_AUCpre=[]; tmp_AUCpost=[];tmp_CalTrans=[];
        tmp_AUCpremin=[];tmp_AUCpremax=[];tmp_AUCpostmin=[];tmp_AUCpostmax=[];
        %eval(['Calcium_Transient_Image' num2str(i) '=zeros(size(time_transient,2),a_counts(i));']);

        subplot(2,size(Calcium_Transient,1),i)
        i_trans=1;
        for j=1:size(Calcium_Transient,2)

            hold on
            if ~isempty(Calcium_Transient{i,j})
                tmp=Calcium_Transient{i,j};
                tmp_time=(0:size(tmp,1)-1)*dt;


                %                      tmp=max(cal_epi,0);
                %             AUCBehavior_plus(i)=trapz(time_epi,tmp);
                %             tmp=min(cal_epi,0);
                %             AUCBehavior_minus(i)=trapz(time_epi,tmp);
                %
                %             AUCBehavior_net(i)=trapz(time_epi,cal_epi);




                tmp_AUCpre(i_trans)=trapz(tmp_time(1:prefenetre_points),tmp(1:prefenetre_points));
                tmp_AUCpost(i_trans)= trapz(tmp_time(prefenetre_points:end),tmp(prefenetre_points:end));
                tmp_AUCpremin(i_trans)=trapz(tmp_time(1:prefenetre_points),min(tmp(1:prefenetre_points),0));
                tmp_AUCpostmin(i_trans)=trapz(tmp_time(prefenetre_points:end),min(tmp(prefenetre_points:end),0));
                tmp_AUCpremax(i_trans)=trapz(tmp_time(1:prefenetre_points),max(tmp(1:prefenetre_points),0));
                tmp_AUCpostmax(i_trans)=trapz(tmp_time(prefenetre_points:end),max(tmp(prefenetre_points:end),0));

                plot(time_transient(1,1:size(tmp,1)),tmp)
                % eval(['Calcium_Transient_Image' num2str(i) '(:,i)=tmp;']);
                i_trans=i_trans+1;

            end



        end
        title(char(Labels(i)))
        hold off
        %saveas(gcf,[chemin char(fname{1}) char(Labels(i)) '.jpg'],'jpg');

        Calcium_Transient_AUC(k:k+5,1:size(tmp_AUCpost,2))=[tmp_AUCpremin;tmp_AUCpostmin;...
            tmp_AUCpremax;tmp_AUCpostmax;tmp_AUCpre;tmp_AUCpost];
        k=k+6;

    end
    waitbar(5/etapes,f,sprintf('%3f',5))
    %********************************************************************************
    % calcul des AUC des differentes périodes de comportements
    %********************************************************************************

    FastPrint('TransientTrace',dir_result);
    AUCBehavior_plus=[] ;AUCBehavior_minus=[] ;AUCBehavior_net=[];
    figure('units','normalized','outerposition',[0 0 1 1])
    for i=1:size(Calcium_Transient_Behavior,2)


        cal_epi=Calcium_Transient_Behavior{i};
        time_epi=(0:size(cal_epi,1)-1).*dt;
        subplot(3,round(size(Calcium_Transient_Behavior,2)/2),i)
        plot(time_epi,cal_epi)
        hold on
        line(xlim(), [0,0], 'LineWidth', 2, 'Color', 'k');
        hold off
        title(Label_Behaviour{i})
        tmp=max(cal_epi,0);
        AUCBehavior_plus(i)=trapz(time_epi,tmp);
        tmp=min(cal_epi,0);
        AUCBehavior_minus(i)=trapz(time_epi,tmp);

        AUCBehavior_net(i)=trapz(time_epi,cal_epi);
    end
    FastPrint('TraceBehavior',dir_result);

    figure('units','normalized','outerposition',[0 0 1 1])
    for i=1:size(Calcium_Transient_Behavior,2)


        cal_epi=Calcium_Transient_Behavior{i};
        time_epi=(0:size(cal_epi,1)-1).*dt;
        subplot(3,round(size(Calcium_Transient_Behavior,2)/2),i)
        plot(time_epi,cal_epi)

        title(Label_Behaviour{i})
        tmp=max(cal_epi,0);
        AUCBehavior_plus(i)=trapz(time_epi,tmp);
        tmp=min(cal_epi,0);
        AUCBehavior_minus(i)=trapz(time_epi,tmp);

        AUCBehavior_net(i)=trapz(time_epi,cal_epi);
    end
    FastPrint('TraceBehaviorWithout0line',dir_result);

    %******************************************************************
    %  Affichage des valeurs Valeurs AUC des periodes de comportements
    %   diagramme en barres histogrammes
    %******************************************************************

    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(3,1,1)
    bar(AUCBehavior_plus)
    if strcmp(version('-release'),'2020b')
        xticklabels(Label_Behaviour)
    else
        ax = gca;
        ax.XTickLabels = Label_Behaviour;
    end

    title('AUC Plus')
    subplot(3,1,2)
    bar(AUCBehavior_minus)
    if strcmp(version('-release'),'2020b')
        xticklabels(Label_Behaviour)
    else
        ax = gca;
        ax.XTickLabels = Label_Behaviour;
    end

    title('AUC Minus')
    subplot(3,1,3)
    bar(AUCBehavior_net)

    if strcmp(version('-release'),'2020b')
        xticklabels(Label_Behaviour)
    else
        ax = gca;
        ax.XTickLabels = Label_Behaviour;
    end

    title('AUC Net')
    FastPrint('AUC',dir_result);

    waitbar(6/etapes,f,sprintf('%3f',6))
    close(f)





    %*****************************************************************************************************
    %          Detection Spike Pmat1.3
    %
    %*****************************************************************************************************
    if flag_UseSpike==1
        if Median_Absolute== 1
            DF_DEBLEACHED = 'MAD';
        else% Set to 'MAD' or 'NORM'
            DF_DEBLEACHED = 'NORM';
        end
        DeltaFlour=DeltaF_stripped(signalClean_2,signalClean_3);

        [DF_norm, DF_MAD] =FP_DEBLEACHED(DeltaFlour,Windows_size,fs, Iterations);
        if strcmp(DF_DEBLEACHED,'MAD')
            [Spike_Values] = FP_SPIKECOUNT (DF_MAD,Threshold,dt,fs,Hold_Constant,Zero_Rule);
        else
            [Spike_Values] = FP_SPIKECOUNT (DF_norm,Threshold,dt,fs, Hold_Constant,Zero_Rule);
        end
        SpikeValues=Spike_Values.*(1/fs);

        FastPrint('Spike Count',dir_result);

        header=["Spike Start (s)","Spike End (s)"];
        tmp2=cellstr([header;SpikeValues]);
        Spikes=table(tmp2);

        filename_photometry_Spikes=[dir_result,strtok(char(fname{1}),'.'),'_SpikesCount.csv'];



        writetable(Spikes,filename_photometry_Spikes,'WriteVariableNames',false);
    end
    %**************************************************************************************************
    %  Fin detection
    %**************************************************************************************************

    %
    %   ***********************************************************************************************
    %                Sauvegarde des signaux Signal Isobestic filtré
    %                DFoF et zscore
    %   *************************************************************************************************
    test_mat=size(signalClean_2);
    if  test_mat(1)>1
        signalClean_2=signalClean_2';
        signalClean_3=signalClean_3';

    end


    f = waitbar(0,'Sauvegarde...');
    filename_photometry_dCorected_ratio=[dir_result,strtok(char(fname{1}),'.'),'_Data'];

    outputFid = fopen([filename_photometry_dCorected_ratio, '.csv'],'w');

    fprintf(outputFid,'%s\t','time')
    fprintf(outputFid,'%s\t','rawSignal');
    fprintf(outputFid,'%s\t','rawIsobestic');
    fprintf(outputFid,'%s\t','rawSignalfiltered_corrected');
    fprintf(outputFid,'%s\t','rawIsobesticfiltered_corrected');
    fprintf(outputFid,'%s\t','DFoF');
    fprintf(outputFid,'%s\t','RatioZscore');


    fprintf(outputFid,'\n');

    for i=1:size(AOut_2_lim,1)

        fprintf(outputFid,'%s\t',num2str(time(i)));
        fprintf(outputFid,'%s\t',num2str(AOut_2_lim(i,1)));
        fprintf(outputFid,'%s\t',num2str(AOut_3_lim(i,1)));
        fprintf(outputFid,'%s\t',num2str(signalClean_2(1,i)));
        fprintf(outputFid,'%s\t',num2str(signalClean_3(1,i)));
        fprintf(outputFid,'%s\t',num2str(Dff(i,1)));
        fprintf(outputFid,'%s\t',num2str(Fiber_Photometry_Trace_Debleached_1(i,1)));

        fprintf(outputFid,'\n');


    end

    fclose(outputFid);


    waitbar(1/5,f,sprintf('%3f',5))
    %***************** AUC pre/ post *****************************************

    filename_photometry_R=[dir_result,strtok(char(fname{1}),'.'),'_AUC'];




    outputFid = fopen([filename_photometry_R, '.csv'],'w');


    for i=1:size(Labels,1)
        fprintf(outputFid,'%s\t',[Labels{i} '_pre_AUC_minus']);
        fprintf(outputFid,'%s\t',[Labels{i} '_post_AUC_minus']);
        fprintf(outputFid,'%s\t',[Labels{i} '_pre_AUC_plus']);
        fprintf(outputFid,'%s\t',[Labels{i} '_post_AUC_plus']);
        fprintf(outputFid,'%s\t',[Labels{i} '_pre_AUC_net']);
        fprintf(outputFid,'%s\t',[Labels{i} '_post_AUC_net']);
    end

    fprintf(outputFid,'\n');

    for i=1:size(Calcium_Transient_AUC,2)

        for j=1:size(Calcium_Transient_AUC,1)

            if ~isnan( Calcium_Transient_AUC(j,i))
                fprintf(outputFid,'%s\t',num2str(Calcium_Transient_AUC(j,i)));

            else
                fprintf(outputFid,'%s\t','  ');

            end
        end

        fprintf(outputFid,'\n');

    end


    fclose(outputFid);

    waitbar(2/5,f,sprintf('%3f',5))
    filename_photometry_Rtransient=[dir_result,strtok(char(fname{1}),'.'),'_Calcium'];




    outputFid = fopen([filename_photometry_Rtransient, '.csv'],'w');

    fprintf(outputFid,'%s\t','time');
    for i=1:size(Label_Behaviour,1)

        fprintf(outputFid,'%s\t',[Label_Behaviour{i} '_' num2str(i)]);

    end
    fprintf(outputFid,'\n');
    for i=1:size(Cal_Trans,1)

        for j=1:size(Cal_Trans,2)

            fprintf(outputFid,'%s\t',num2str(Cal_Trans(i,j)));

        end
        fprintf(outputFid,'\n');
    end

    fclose(outputFid);




    waitbar(3/5,f,sprintf('%3f',5))


    %*********************************************************************************************
    %
    %   ***********************************************************************************************
    %                Sauvegarde limite a la duree post comportement
    %   *************************************************************************************************

    filename_photometry_R=[dir_result,strtok(char(fname{1}),'.'),'postbehduration_AUC'];




    outputFid = fopen([filename_photometry_R, '.csv'],'w');


    for i=1:size(Label_Behaviour,1)

        fprintf(outputFid,'%s\t',[Label_Behaviour{i} '_AUC']);
    end

    fprintf(outputFid,'\n');


    for i=1:size(AUCBehavior_plus,2)



        fprintf(outputFid,'%s\t',num2str(AUCBehavior_plus(i)));



    end


    fprintf(outputFid,'\n');
    for i=1:size(AUCBehavior_minus,2)



        fprintf(outputFid,'%s\t',num2str(AUCBehavior_minus(i)));



    end


    fprintf(outputFid,'\n');
    for i=1:size(AUCBehavior_net,2)



        fprintf(outputFid,'%s\t',num2str(AUCBehavior_net(i)));



    end


    fprintf(outputFid,'\n');


    fclose(outputFid);

    waitbar(4/5,f,sprintf('%3f',5))

    %***************************************************************
    %
    %******************************************************************
    filename_photometry_Rtransient=[dir_result,strtok(char(fname{1}),'.'),'postbehduration_Calcium'];




    outputFid = fopen([filename_photometry_Rtransient, '.csv'],'w');

    fprintf(outputFid,'%s\t','time');
    for i=1:size(Label_Behaviour,1)

        fprintf(outputFid,'%s\t',[Label_Behaviour{i} '_' num2str(i)]);

    end
    fprintf(outputFid,'\n');
    [nrows,ncols] = cellfun(@size,Calcium_Transient_Behavior);
    Nombre_elts_Max=max(nrows);
    time_epi=(0:Nombre_elts_Max-1).*dt;


    for i=1:Nombre_elts_Max
        fprintf(outputFid,'%s\t',num2str(time_epi(i)));
        for j=1:size(Calcium_Transient_Behavior,2)
            cal_epi=Calcium_Transient_Behavior{j};
            if i<=size(cal_epi,1)
                fprintf(outputFid,'%s\t',num2str(cal_epi(i)));
            else
                fprintf(outputFid,'%s\t','  ');

            end

        end
        fprintf(outputFid,'\n');
    end

    fclose(outputFid);

%***************************************************************
    %
    %******************************************************************

      filename_photometry_Behavior_pmat=[dir_result,strtok(char(fname{1}),'.'),'behavior_Pmat'];
% Label_Behaviour Startime(i) Endtime(i)
%        fprintf(outputFid,'%s\t',num2str(time(i)));
%     
%      fprintf(outputFid,'%s\t',num2str(signalClean_2(1,i)));
%     fprintf(outputFid,'%s\t',num2str(signalClean_3(1,i)));

 outputFid = fopen([filename_photometry_Behavior_pmat, '.csv'],'w');

    fprintf(outputFid,'%s,','Event');
    fprintf(outputFid,'%s,','Onset');
    fprintf(outputFid,'%s','Offset');
    fprintf(outputFid,'\n');
    for i=1:size(Label_Behaviour,1)
   fprintf(outputFid,'%s,',char(Label_Behaviour{i})); 
   fprintf(outputFid,'%s,',num2str(Startime(i))); 
   fprintf(outputFid,'%s',num2str(Endtime(i)));
    fprintf(outputFid,'\n');
    end
 fclose(outputFid);

%*************************************************************************************
%
%*************************************************************************************
filename_photometry_pmat=[dir_result,strtok(char(fname{1}),'.'),'_Datapmat'];

    outputFid = fopen([filename_photometry_pmat, '.csv'],'w');

    fprintf(outputFid,'%s,','TimeStamp');
  
    fprintf(outputFid,'%s,','Signal');
    fprintf(outputFid,'%s','Control');
   

    fprintf(outputFid,'\n');

    for i=1:size(AOut_2_lim,1)

        fprintf(outputFid,'%s,',num2str(time(i)));
        
        fprintf(outputFid,'%s,',num2str(signalClean_2(1,i)));
        fprintf(outputFid,'%s',num2str(signalClean_3(1,i)));
        

        fprintf(outputFid,'\n');


    end

    fclose(outputFid);






%***********************************************************************************
%
%***************************************************************************************

    waitbar(5/5,f,sprintf('%3f',5))
    %
    close(f)
end

