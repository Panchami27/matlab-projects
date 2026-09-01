clc;
clear all;

%Program to design heat exchanger network using temperature interval method
% and to plot a Grand Composite Curve (GCC)
%Data taken Example 10.7 (Warren D. Seider, J. D. Seader, Daniel R. Lewin, Product and Process Design Principles: Synthesis, Analysis, and Evaluation, 2nd Edition, Wiley)
deltaTmin = 10; %input deltaTmin between hot and cold streams

Thot1 = [40 180]; %Input hot stream 1 temperatures, degreeC
Thot2 = [40 150]; %Input hot stream 2 temperatures, degreeC

Tcold1 = [60 180]; %Input cold stream 1 temperatures, degreeC
Tcold2 = [30 130]; %Input cold stream 2 temperatures, degreeC

mcphot1 = 2; %Input hot stream 1 heat capacity rate, kW/degreeC
mcphot2 = 4; %Input hot stream 2 heat capacity rate, kW/degreeC

mcpcold1 = 3; %Input cold stream 1 heat capacity rate, kW/degreeC
mcpcold2 = 2.6; %Input cold stream 2 heat capacity rate, kW/degreeC

Thot1m = Thot1 - [deltaTmin deltaTmin]; %deltaTmin subtracted from hot stream temperatures to obtain adjusted temperatures
Thot2m = Thot2 - [deltaTmin deltaTmin];

Tall = [Thot1m Thot2m Tcold1 Tcold2]; %combine all stream temperatures into one main vector

Tallm = sort(Tall, 'descend'); %arrange modified temperatures in decreasing order

%remove any components in modified temperature vector that are same
Tall_m = unique(Tallm, 'stable');
N = length(Tall_m);

%divide temperatures into intervals and find which stream is in which
%interval and calculate enthalpy differnce of each temperaure interval

for i = 2:N %interval from Tall_m(i-1) to Tall_m(i)
    T_high = Tall_m(i-1);
    T_low = Tall_m(i);
    
    H1 = isbetween(T_high, Thot1m(1), Thot1m(2)) && isbetween(T_low, Thot1m(1), Thot1m(2));
    H2 = isbetween(T_high, Thot2m(1), Thot2m(2)) && isbetween(T_low, Thot2m(1), Thot2m(2));
    C1 = isbetween(T_high, Tcold1(1), Tcold1(2)) && isbetween(T_low, Tcold1(1), Tcold1(2));
    C2 = isbetween(T_high, Tcold2(1), Tcold2(2)) && isbetween(T_low, Tcold2(1), Tcold2(2));
    
    mcphot = 0;
    mcpcold= 0;

    if H1, mcphot = mcphot + mcphot1; end
    if H2, mcphot = mcphot + mcphot2; end
    if C1, mcpcold = mcpcold + mcpcold1; end
    if C2, mcpcold = mcpcold + mcpcold2; end
    
    dT = T_high-T_low;
    enthal(i-1) = (mcphot-mcpcold)*dT;
end


O = length(enthal);
%energy flow calculation - find residual energy of each temp. interval by
%doing initial pass
R = zeros(1, O);
Qsteam = 0;
R(1) = Qsteam + enthal(1);

for l = 2:O
    R(l) = R(l-1) + enthal(l);
end

Qcw = R(end);

for l = 1:O
    if (R(l) == 0)
        disp(['Qsteam = ', num2str(Qsteam)]);
        disp(['Qcw = ', num2str(Qcw)]);
        Coldpin = Tall_m(l);
        disp('Cold pinch temp =', num2str(Coldpin));
        Hotpin = Tall_m(l) + deltaTmin;
        disp('Hot pinch temp =', num2str(Hotpin));
        
        figure (1) %to plot Grand Composite Curve (GCC)
        plot(R, Tall_m)
        grid on
        xlabel('Enthalpy [kW]')
        ylabel('Adjusted Temperature [°C]')
        text(0.03,0.97,'Hot Utility','Units','normalized');
        text(0.03,0.03,'Cold Utility','Units','normalized');
    else
        for x = 1:O
        D = -1*min(R); %find maximum negative value in R
        Qsteam = D;
        S(1) = Qsteam;
        S(x+1) = R(x) + D;
        end
    end
end

Qcw = S(end);

for m = 1:O
    if (S(m) == 0)
        disp(['Qsteam = ', num2str(Qsteam)]);
        disp(['Qcw = ', num2str(Qcw)]);
        Coldpin = Tall_m(m);
        disp(['Cold pinch temp = ', num2str(Coldpin)]);
        Hotpin = Tall_m(m) + deltaTmin;
        disp(['Hot pinch temp = ', num2str(Hotpin)]);
    end
end

figure (1) %to plot Grand Composite Curve (GCC)
plot(S, Tall_m)
grid on
xlabel('Enthalpy [kW]')
ylabel('Adjusted Temperature [°C]')
text(0.03,0.97,'Hot Utility','Units','normalized');
text(0.03,0.03,'Cold Utility','Units','normalized');