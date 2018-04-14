function [lestime, ldetect, d, Nestime] = detect_et_estime_part_1vue(input, wn, r0, pfa, optim)%%, pas_ijr)

[Ni, Nj] = size(input) ;

%% positions des parametres
Nparam = 7 ;
detect_i = 2 ;
detect_j = 3 ;
alpha = 4 ;
% sig2 = 5 ;

%% detection pour un rayon moyen r0
[c,ldetect,d] = carte_H0H1_1vue(input, r0, wn, wn, pfa);

%% estimation pour des pas de recherche
%% interval [-1,1] pour ij
%% interval [0.6,1.4] pour le rayon

Ndetect = size(ldetect, 1) ;
if (Ndetect==0) %no pixels meets glrt threshold
    lestime = zeros(1,Nparam) ;
    Nestime = 0 ;
    return ;
end%if

Nestime = 0 ;
bord = ceil(wn/2) ;
for n=1:Ndetect
    test_bord = (ldetect(n,detect_i) < bord) || (ldetect(n,detect_i) > Ni-bord) || ...
        (ldetect(n,detect_j) < bord) || (ldetect(n,detect_j) > Nj-bord) ;
    if ((ldetect(n,alpha) > 0.0) && (~test_bord) )
        Nestime = Nestime + 1 ;
        lestime(Nestime, :) = estim_param_part_GN(input, wn, ldetect(n,:), r0, optim) ;
    end%if
end%for

% a la bonne taille
if (Nestime==0)
    lestime = zeros(1,Nparam) ;
else
    lestime = lestime(1:Nestime,:) ;
end%if

end%function