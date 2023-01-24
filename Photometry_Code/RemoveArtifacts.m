function [Clean2,Clean3] = RemoveArtifacts(A2,A3,win,perMax)

  % cedric Wannaz remove artifacts solutions
    %
    A_temp2 = movmean(A2,win);
    
     d2 = [0; diff(  A_temp2 )] ;
      Rderv=max(d2)-perMax*max( d2);
     isValid_2 = ~logical(cumsum( -sign( d2) .* (abs( d2 ) > Rderv) ));
     
     
%     % then e.g. set invalid entries to NaN
      signalCut_2nan =A2 ;
      signalCut_2nan(~isValid_2) = NaN ;
%     % or interpolate:
     t = 1 : numel( A2 ) ;
     Clean2 = interp1( t(isValid_2), A2(isValid_2), t ) ;
     
     
     % This is a quick technical trick that you have to tweak and check visually. It is not robust (in comparison to the two other answers), but if all you want to do is a one shot elimination of the glitches ..
%     % With that you get:
       A_temp3= movmean(A3,win);
      d3 = [0; diff( A_temp3 )] ;
     Rderv=max(d3)-perMax*max( d3);
     isValid_3 =~logical (cumsum( -sign( d3) .* (abs( d3 ) >Rderv) ));
%     % then e.g. set invalid entries to NaN
      signalCut_3nan = A3 ;
      signalCut_3nan(~isValid_3) = NaN ;
%     % or interpolate:
     t = 1 : numel( A3 ) ;
     Clean3 = interp1( t(isValid_3), A3(isValid_3), t ) ;
     
     
    
  
end  
     
    %%
  
    