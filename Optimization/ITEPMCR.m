clc; clf; clear all;

filename = strcat(pwd,'/parameters.csv');
[country,month,weekday,vazio,alphaX,betaX,gammaX,deltaX,alphaM,betaM,gammaM,deltaM,hours] = import_iberian_data(filename);

n = 101;

aX = 1 ./ betaX + 1 ./ deltaX;
bX = alphaX ./ betaX - gammaX ./ deltaX;

aM = 1 ./ betaM + 1 ./ deltaM;
bM = alphaM ./ betaM - gammaM ./ deltaM;

PAutX = bX ./ aX;
PAutM = bM ./ aM;

QAutX = (alphaX + gammaX) ./ (betaX + deltaX);
QAutM = (alphaM + gammaM) ./ (betaM + deltaM);

Qft = (aX .* bM - aM .* bX) ./ (aX + aM)

ResSWx = zeros(n,1);
ResSWm = zeros(n,1);
ResIx = zeros(n,1);
ResIm = zeros(n,1);
ResK = zeros(n,1);
Resc = zeros(n,1);

for i = 1:n
    c = -5000 + i * 5000
    
    cvx_begin
    
        variable I
        variable Ix
        variable Im
        variable K
        variable SWx(168)
        variable SWm(168)
        variable SWtotal
        variable F(168)
    
        maximize SWtotal - I
    
        subject to
            SWtotal <= ones(1, 168)* (hours .* ((bM ./ aM - bX ./ aX) .* F - 1/2 * (1 ./aM + 1 ./ aX) .* F.^2))
            I == c * K
            F >= zeros(168,1)
            F <= Qft
            F <= K
    cvx_end

    SWx = hours .* ((bM ./ aM - bX ./ aX) .* F - 1/2 * (2 ./aM + 1 ./ aX) .* F.^2);
    SWm = hours .* (1/2 * (1 ./aM) .* F.^2);
    Ix = 1/2 * (I + ones(1,168) * (SWx - SWm));
    Im = I - Ix;
    
    ResSWx(i) = ones(1,168) * SWx;
    ResSWm(i) = ones(1,168) * SWm;
    ResIx(i) = Ix;
    ResIm(i) = Im;
    ResK(i) = K;
    Resc(i) = c; 
end

plotmodelresults(ResSWx, ResSWm, ResIx, ResIm, ResK, Resc)