function [F1490,F1405]=Manual_Removal_Artifacts(t,Sig_2,Sig_3,smth,dir_r,um_a)

  F1490=Sig_2;%smooth(Sig_2, smth,'loess'); 
  F1405=Sig_3;%smooth(Sig_3, smth,'loess');
  
  %F490mean= movmean(Sig_2,5000);
  %F405mean= movmean(Sig_3,5000);
  
         Diff_2= diff(F1490)' ;
         Diff_3= diff(F1405)' ;
     if um_a==0   
        %% figure('KeyPressFcn',@(obj,evt) 0);
        figure('Name','Press Return when Done','units','normalized','outerposition',[0 0 1 1],'KeyPressFcn',@(obj,evt) 0);
       d = datacursormode(gcf);
        ax1=subplot(4,1,1);
        hold on
        plot(t(1:end-1),Diff_2,'b');
       
        plot(t([1 size(Diff_2,2)]),[0 0],'k','LineWidth',2);
        hold off
        
        
        ax2=subplot(4,1,2);
        hold on
        plot(t(1:end-1),Diff_3,'r')
        plot(t([1 size(Diff_3,2)]),[0 0],'k','LineWidth',2);
        hold off
         ax3=subplot(4,1,3);
     
        plot( t,Sig_2,'k')
        
         ax4=subplot(4,1,4);
     
        plot(t,Sig_3,'r')
        
         linkaxes([ax1,ax2,ax3,ax4],'x');
        %************************************************************************** 
        %pause;
     else
         
        f=openfig([dir_r 'tmp_fig.fig']) ;
          d = datacursormode(gcf);
     end
        waitfor(gcf,'CurrentCharacter');
        curChar=uint8(get(gcf,'CurrentCharacter'));
        
       savefig([dir_r 'tmp_fig.fig']);
       %save([dir_r 'tmp_workspace.mat'],'-v7.3');

        %*****************************************************************************
      

        %*****************************************************************************
       
        vals = struct2table(getCursorInfo(d));
    

        se_tmp= sort(vals.DataIndex);
%         k=1;
%       for i=1:2:size(se_tmp,1)-1
%          [valmax,Indexmax]= max(dvdt_DFF_1(se_tmp(i)-1:se_tmp(i+1)-1,1));
%          pidx_H(k)=Indexmax+se_tmp(i)-1
%          k= k+1;
%       end
      
       ax3=subplot(4,1,3);
      
     plot(t,Sig_2,'r')
      hold on
       plot(t(se_tmp+1),Sig_2(se_tmp+1),'ks','MarkerSize',5)
        hold off
          ax4=subplot(4,1,4);
      
     plot(t,Sig_3,'r')
      hold on
       plot(t(se_tmp+1),Sig_3(se_tmp+1),'ks','MarkerSize',5)
        hold off
       
        %************************************************************************** 
        %pause;
        waitfor(gcf,'CurrentCharacter');
        curChar=uint8(get(gcf,'CurrentCharacter'));
        
        FastPrint('Result_Artifact_Manual_Detection',dir_r);
        %*****************************************************************************
      close(gcf)  
       Difforig_2= diff(Sig_2) ;
      Difforig_3= diff(Sig_3) ; 
        
      F1490=Sig_2;
      F1405= Sig_3;    
      for i=1:2:size(se_tmp,1)-1
          %         signdev=sum(Difforig_2(1,se_tmp(i):se_tmp(i+1)));
          %
          %
          %
          %        if sign(signdev)  <0
          %       Sig_2(se_tmp(i)+1:end)=  Sig_2(se_tmp(i)+1:end)+abs((Sig_2(se_tmp(i)+1)-Sig_2(se_tmp(i+1)+1)));
          %       Sig_3(se_tmp(i)+1:end)=  Sig_3(se_tmp(i)+1:end)+abs((Sig_3(se_tmp(i)+1)-Sig_3(se_tmp(i+1)+1)));
          %        else
          %        Sig_2(se_tmp(i)+1:end)=  Sig_2(se_tmp(i)+1:end)-abs((Sig_2(se_tmp(i)+1)-Sig_2(se_tmp(i+1)+1)));
          %        Sig_3(se_tmp(i)+1:end)=  Sig_3(se_tmp(i)+1:end)-abs((Sig_3(se_tmp(i)+1)-Sig_3(se_tmp(i+1)+1)));
          %        end
          
          Diff_2(1,se_tmp(i):se_tmp(i+1))=0;
          %
          Diff_3(1,se_tmp(i):se_tmp(i+1))= 0;
          
          
%           if Sig_2(se_tmp(i)+1)>Sig_2(se_tmp(i+1)+1)% descente
%               
%               Sig_2(se_tmp(i)+1:end)=  Sig_2(se_tmp(i)+1:end)+abs((Sig_2(se_tmp(i)+1)-Sig_2(se_tmp(i+1)+1)));
%               
%           else % montée
%               
%               Sig_2(se_tmp(i)+1:end)=  Sig_2(se_tmp(i)+1:end)-abs((Sig_2(se_tmp(i)+1)-Sig_2(se_tmp(i+1)+1)));
%               
%           end
%           if Sig_3(se_tmp(i)+1)>Sig_3(se_tmp(i+1)+1)% descente
%               
%               Sig_3(se_tmp(i)+1:end)=  Sig_3(se_tmp(i)+1:end)+abs((Sig_3(se_tmp(i)+1)-Sig_3(se_tmp(i+1)+1)));
%               
%           else % montée
%               
%               Sig_3(se_tmp(i)+1:end)=  Sig_3(se_tmp(i)+1:end)-abs((Sig_3(se_tmp(i)+1)-Sig_3(se_tmp(i+1)+1)));
%               
%           end
          
          
          
      end
%      isValid_2=logical(isnan(Difforig_2));
%      isValid_3=logical(isnan(Difforig_3));
%     % or interpolate:
%      t = 1 : numel( Difforig_2 ) ;
%      F1 = interp1( t(~isValid_2), Difforig_2(~isValid_2), t ) ;
%       F2=interp1( t(~isValid_3), Difforig_3(~isValid_3), t ) ;
%       F1490=Sig_2;
%       F1405= Sig_3;
     F1490=cumsum(Diff_2)+Sig_2(1);
     F1405=cumsum(Diff_3)+Sig_3(1);
end