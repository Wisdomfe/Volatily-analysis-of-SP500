%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  VOLATILITY ESTIMATE FOR SP500 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load SP500
% note: SP500 series ('SP') starts Jan 03 and ends Dec 10
ret = diff(log(SP));   
dates = dates_indices(2:end);  % discard first date and rename

save temp ret dates    
clear             
load temp    
delete temp.mat   


% historical volatility of SP5000 using windows of 50, 250 and 500 days

t0 = find(dates == datenum(2007,01,01));     % current date
T = length(dates);                           % total length

for t = t0+1:T
    histvol_50(t) = std(ret(t-50:t-1));    % 50 days window
    histvol_250(t) = std(ret(t-250:t-1));  % 250
    histvol_500(t) = std(ret(t-500:t-1));  % 500
    % note: vol(t) is the volatility of R_t estimated at day t-1
end

plot(dates(t0+1:end),abs(ret(t0+1:end)),'k')   % absolute values of returns
            % note: only series from t0+1 on are plotted
hold on
plot(dates(t0+1:end),histvol_50(t0+1:end),'g','linewidth',2)
plot(dates(t0+1:end),histvol_250(t0+1:end),'r','linewidth',2) 
plot(dates(t0+1:end),histvol_500(t0+1:end),'b','linewidth',2)
   % 'linewidth' followed by a width >= 1, thickens the curve
datetick('x','yyyy')
title('historical volatility')
legend('|R_t|','histvol (50 days)','histvol (250 days)','histvol (500 days)') 


% historical volatility using EWMA, with lambda 0:94 and 0:98. 

EWMAvol_94(t0) = std(ret(1:t0-1));  % first values of vol set to the historical one
EWMAvol_98(t0) = EWMAvol_94(t0);

for t = t0+1:T         % cycle for updating the estimates
    EWMAvol_94(t) = sqrt(0.94*EWMAvol_94(t-1)^2 + 0.06*ret(t-1)^2);
                                    % lambda = 0.94 (RiskMetrics)
    EWMAvol_98(t) = sqrt(0.98*EWMAvol_98(t-1)^2 + 0.02*ret(t-1)^2);
                                    % lambda = 0.98
end

figure
plot(dates(t0+1:end),abs(ret(t0+1:end)),'k')  % absolute values of returns
hold on
plot(dates(t0+1:end),EWMAvol_94(t0+1:end),'g','linewidth',2)
plot(dates(t0+1:end),EWMAvol_98(t0+1:end),'r','linewidth',2)
datetick('x','yyyy'), title('EWMA volatility')
legend('|R_t|','EWMA vol (0.94)','EWMA vol (0.98)')


% plot the estimates of the historical volatility (window:250 days) and EWMA volatility 
% (lambda= 0:94) from Jan 07 to Dec 10, together with the corresponding values of the VIX index

load data/VIX      % load VIX data
% note: VIX series starts Jan 90 and ends Sep 14, so 
% 1. it has to be reduced to Jan 07 - Dec 10
% 2. in the range Jan 07 - Dec 10 it must be sinchronized with histvol and
%    EWMAvol (already sinchronized each other as they share the same dates) 

dates_vol = dates(t0+1:end);     % dates for which histvol and EWMAvol are available
histvol_0710 = histvol_250(t0+1:end);  % historical vol 07-10
EWMAvol_0710 = EWMAvol_94(t0+1:end);   % EWMA vol 07-10

Y = year(dates_VIX);
dates_VIX = dates_VIX(Y >= 2007 & Y <= 2010);    % reduces dates to 07-10
VIX = VIX(Y >= 2007 & Y <= 2010);                % same for VIX series

disp([length(dates_vol), length(dates_VIX)])    
              % check: the series hist/EWMA vol and VIX have different
              % length. We need to synchronize (i.e. retain values
              % available on same days)

[dates_common, I, J] = intersect(dates_vol,dates_VIX);
                 % finds the common dates in 'dates_vol' and 'dates_VIX' and
                 % provides vectors of indices I and J such that
                 % dates_vol(I) = dates_common
                 % dates_VIX(J) = dates_common
                 
histvol_0710 = histvol_0710(I);   % only common dates are retained
EWMAvol_0710 = EWMAvol_0710(I);   % I is used also here
VIX = VIX(J);                     % J is used for VIX

figure
plot(dates_common,histvol_0710*100*sqrt(252),'r','linewidth',2)
       % note: for correct comparison with VIX, histvol is annualized (x sqrt(252))
       % and expressed in percentage terms (x100)
hold on
plot(dates_common,EWMAvol_0710*100*sqrt(252),'g','linewidth',2)   
       % same for EWMAvol
plot(dates_common,VIX,'k')
datetick('x','yyyy')
legend('histvol','EWMAvol','VIX')
