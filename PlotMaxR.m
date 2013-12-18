function PlotMaxR(report)
% function PlotMaxR(report)
%
% Plot MaxR from HebbCycle updates

nCycle = length(report.cycle);

for iCycle = 1:nCycle
    maxR(iCycle,:) = [report.cycle(iCycle).bn(1).maxR report.cycle(iCycle).bn(2).maxR];
end

% Plot maxR for LE and RE
figure
plot(1:nCycle, maxR)
xlabel('Cycle number');
ylabel('maxR = sum(LGN weights)')
title('Total weight in LE and RE as a function of experience');
legend({'LE', 'RE'})

 
