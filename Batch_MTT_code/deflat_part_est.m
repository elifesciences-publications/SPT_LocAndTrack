function output = deflat_part_est(input, liste_est, wn)

[idim, jdim] = size(input) ;
nb_part = size(liste_est, 1) ;

output = input ;

%% parametre dans liste_est :
%% liste_param = [num, i, j, alpha, sig^2, rayon, ok]

for part=1:nb_part
    if (liste_est(part, 7) == 1)
        i0 = liste_est(part, 1) ;
        j0 = liste_est(part, 2) ;
        alpha = liste_est(part, 3) ;
        r0 = liste_est(part, 6) ;
        wn = ceil(6*r0); % by CPR: 99% of Gaussian
        
        pos_i = round(i0) ;
        dep_i = i0 - pos_i ;
        pos_j = round(j0) ;
        dep_j = j0 - pos_j ;
        
        alpha_g = alpha * gausswin2(r0, wn, wn, dep_i, dep_j) ;
        
        dd = (1:wn) - floor(wn/2) ;
        di = dd + pos_i ;
        iin = di > 0 & di < idim+1;
                
        dj = dd + pos_j ;
        jin = dj > 0 & dj < jdim+1;
                
        output(di(iin), dj(jin)) = ...
            output(di(iin), dj(jin)) - alpha_g(iin,jin) ;
    end%if
end%for


end%function