%Joint Probability Distribution for a Go/NoGo Gage
%David Miller
%12/5/2019

close all
clearvars
clc

%% GAGE AND FEATURE DEFINITIZATION

%define feature specification and tolerance
featNom = 21;
featMin = 21;
featMax = 21.03;
featTyp = 'ID'; %can be "ID" or "OD"
featTol = featMax - featMin;

%feature statistical parameters
featDst = 'Normal';
featAvg = featMin + .5*featTol;                                             %assumption, in lieu of real data
featCpk = 1.33;                                                             %assumption, in lieu of real data
featStd = featTol/(6*featCpk);                                              %calculated from previous two assumptions.
featPar = makedist(featDst,'mu',featAvg,'sigma',featStd);

%define gage tolerance
gageTol = .1 * featTol;                                                     %10% is the standard

%split gage tolerance btwn GO and NOGO gages
goPer = .5;
goTol = goPer*gageTol;
ngTol = (1 - goPer)*goTol;

%define GO gage specification and tolerance
switch featTyp
    case 'ID'
        goNom = featMin;
        goMin = goNom;
        goMax = goNom + goTol;
    case 'OD'
        goNom = featMax;
        goMin = goNom - goTol;
        goMax = goNom;
    otherwise
        error('featType must either be ''ID'' or ''OD''.\n');
end

%GO gage statistical parameters
goDst = 'Normal';
goStd = (goMax-goMin)/(12);                                                 %assume gages are made with a 6Sigma process (Cpk = 2) with a mean at the center of the tolerance range
goAvg = goMin + .5*goTol;                                                   %define mean at the center of the tolerance range
goPar = makedist(goDst,'mu',goAvg,'sigma',goStd);

%define NOGO gage specification and tolerance
switch featTyp
    case 'OD'
        ngNom = featMin;
        ngMin = ngNom - ngTol;
        ngMax = ngNom;
    case 'ID'
        ngNom = featMax;
        ngMin = ngNom;
        ngMax = ngNom + ngTol;
    otherwise
        error('featType must either be ''ID'' or ''OD''.\n');
end

%NOGO gage statistical parameters
ngDst = 'Normal';
ngStd = (ngMax-ngMin)/(12);                                                 %assume gages are made with a 6Sigma process (Cpk = 2) with a mean at the center of the tolerance range
ngAvg = ngMin + .5*ngTol;                                                   %define mean at the center of the tolerance range
ngPar = makedist(ngDst,'mu',ngAvg,'sigma',ngStd);

%% GENERATE AND PLOT JOINT PDF

%x,y plot limits
xMin = featMin - .01*featTol;
xMax = featMax + .01*featTol;
yMinGo = goMin - .01*gageTol;
yMaxGo = goMax + .01*gageTol;
yMinNg = ngMin - .01*gageTol;
yMaxNg = ngMax + .01*gageTol;

%x,y vectors
x = linspace(xMin,xMax,50);
yGo = linspace(yMinGo,yMaxGo,50);
yNg = linspace(yMinNg,yMaxNg,50);

%evaluate 2D PDFs
zFeat = pdf(featPar,x);
zGo = pdf(goPar,yGo);
zNg = pdf(ngPar,yNg);

%plot 2D PDFs
subplot(2,2,1)
plot(x,zFeat,[featMin featMin],[0 max(zFeat)],[featMax featMax],[0 max(zFeat)])
title('Feature PDF')

subplot(2,2,2)
plot(yGo,zGo,[goMin goMin],[0 max(zGo)],[goMax goMax],[0 max(zGo)])
title('Go Gage PDF')

subplot(2,2,3)
plot(yNg,zNg,[ngMin ngMin],[0 max(zNg)],[ngMax ngMax],[0 max(zNg)])
title('NoGo Gage PDF')

%X,Y matrices for 3D surface
[X YGO] = meshgrid(x,yGo);
[X YNG] = meshgrid(x,yNg);

%evaluate 3D PDF
ZGO = zFeat'*zGo;
ZNG = zFeat'*zNg;

%plot 3D PDFs
figure
surf(X,YGO,ZGO);

xlabel('Feature Axis')
ylabel('Gage Axis')
title('Go Gage Joint PDF')

figure
surf(X,YNG,ZNG);

xlabel('Feature Axis')
ylabel('Gage Axis')
title('NoGo Gage Joint PDF')