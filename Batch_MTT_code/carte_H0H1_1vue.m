function [carte_MV, liste_detect, detect_pfa] = carte_H0H1_1vue(im, rayon, wn_x, wn_y, s_pfa)

[N,M] = size(im) ;
T = wn_x*wn_y ; % number of pixels in the window


%% Hypothese H0
%% pas de particule dans la fenetre
m = ones(wn_x,wn_y) ;
hm = expand_w(m, N, M) ;
tfhm = fft2(hm) ;
tfim = fft2(im) ;
m0 = real(fftshift(ifft2(tfhm .* tfim))) /T ;

im2 = im .* im ;
tfim2 = fft2(im2) ;
Sim2 = real(fftshift(ifft2(tfhm .* tfim2)));

%% H0 = T/2*log(2*pi*sig0^2)-T/2 ;
T_sig0_2 = Sim2 - T*m0.^2 ;

%% Hypothèse H1
%% une particule est au centre de la fenetre
%% amplitude inconnue, rayon fixe

%% generation masque gaussien de largeur (sigma)
%% egal a rayon

%%g = gausswin2(rayon, wn_x, wn_y) ;
g = gausswin2(rayon, wn_x, wn_y, 0, 0) ;
gc = g - sum(g(:))/T ;
Sgc2 = sum(gc(:).^2) ;
hgc = expand_w(gc, N, M) ;
tfhgc = fft2(hgc) ;

alpha = real(fftshift(ifft2(tfhgc .* tfim))) / Sgc2 ;

%% H1 = T/2*log(2*pi*sig1^2)-T/2 ;
%%sig1_2 = sig0_2 - alpha.^2 * Sgc2 / T ;

%% pour test
%sig1_2 = T_sig0_2/T - alpha.^2 * Sgc2 / T ;
%%imagesc(T_sig0_2/T);
%imagesc(sig1_2);
%%imagesc(sig1_2 ./ (T_sig0_2/T));

%%  carte_MV = -0.5*(H0 - H1) ;
% carte_MV = - T * log(1 - (Sgc2 * alpha.^2) ./ T_sig0_2) ;
test = 1 - (Sgc2 * alpha.^2) ./ T_sig0_2 ;
test = (test > 0) .* test + (test <= 0) ;
carte_MV = - T * log(test) ;
carte_MV(isnan(carte_MV)) = 0; %CPR

%% detection et recherche des maximas
%% s_pfa = 28 ;
detect_masque = carte_MV > s_pfa ;
if (sum(detect_masque(:))==0)
    %     warning('No target detected !') ; %#ok
    liste_detect = zeros(1,6) ;
    detect_pfa = zeros(size(detect_masque)) ; % ajout AS 4/12/7
else
    detect_pfa = all_max_2d(carte_MV) & detect_masque ;
    
    [di, dj] = find(detect_pfa) ;
    n_detect = size(di, 1) ;
    vind = N*(dj-1)+di ;
    valpha = alpha(:) ;
    alpha_detect = valpha(vind) ;
    
    sig1_2 = ( T_sig0_2 - alpha.^2 * Sgc2 ) / T ;
    vsig1_2 = sig1_2(:) ;
    sig2_detect = vsig1_2(vind) ;
    
    %% g de puissance unitaire
    %%RSBdB_detect = 10*log10(alpha_detect.^2  ./ sig2_detect) ;
    
    %%liste_detect = [(1:n_detect)', di, dj, alpha_detect, sqrt(sig2_detect), RSBdB_detect] ;
    liste_detect = [(1:n_detect)', di, dj, alpha_detect, sig2_detect, rayon*ones(n_detect,1),ones(n_detect,1)] ;
    
end%if
end %function