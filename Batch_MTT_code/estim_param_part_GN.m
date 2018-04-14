function liste_param = estim_param_part_GN(im, wn, liste_info_param, r0, optim)

Pi = liste_info_param(2) ;
Pj = liste_info_param(3) ;
di = (1:wn)+Pi-floor(wn/2) ;
dj = (1:wn)+Pj-floor(wn/2) ;
im_part = im(di, dj) ;

if 0
        options = optimset(...
        'Algorithm', 'Active-Set',...
        'Display','off',...
        'UseParallel', 'always');
    if 0
    guess = [0,0,r0];
    bounds = [-1.5,-1.5,r0-r0*0.1;1.5,1.5,r0+r0*0.6];
    liste_param = gaussMLE(im_part,guess,bounds,options);
    else
    guess = [0,0,r0,0,r0];
    bounds = [-1.5,-1.5,r0-r0*0.1,0,r0-r0*0.1;...
        1.5,1.5,r0+r0*0.6,0.8,r0+r0*0.6];
    liste_param = gaussEllipticMLE(im_part,guess,bounds,options);
    end   
    liste_param(1:2) = liste_param(1:2)+[Pi Pj];    
else
    %limits for optimization
    bornes_ijr(1) = -optim(5) ;
    bornes_ijr(2) = optim(5) ;
    bornes_ijr(3) = -optim(5) ;
    bornes_ijr(4) = optim(5) ;
    bornes_ijr(5) = r0-optim(4)*r0/100 ;
    bornes_ijr(6) = r0+optim(4)*r0/100 ;
    
    r = r0 ;
    i = 0.0 ;
    j = 0.0 ;
    dr = 1 ;
    di = 1 ;
    dj = 1 ;
    fin = 10^optim(2) ;
    sig2 = inf ;
    cpt = 0 ;
    test = 1 ;
    ITER_MAX = optim(1) ;
    while (test)
        %%[r, i, j, dr, di, dj, alpha, sig2] = deplt_GN_estimation (r, i, j, im_part) ;
        [r, i, j, dr, di, dj, alpha, sig2, offset] = deplt_GN_estimation (r, i, j, im_part, sig2, dr, di, dj, optim) ;
        cpt = cpt + 1 ;
        if optim(3)
            test = max([abs(di), abs(dj), abs(dr)]) > fin ;
        else
            test = max([abs(di), abs(dj)]) > fin ;
        end %if
        if (cpt > ITER_MAX)
            test = 0 ;
        end%if
       
        %% on stop si l_on sort des bornes
        result_ok = ~((i < bornes_ijr(1)) || (i > bornes_ijr(2)) || ...
            (j < bornes_ijr(3)) || (j > bornes_ijr(4)) || ...
            (r < bornes_ijr(5)) || (r > bornes_ijr(6)) ) ;
        test = test & result_ok ;
        
    end%while
    
    
    % liste_info_param = [num, i, j, alpha, sig^2]
    % liste_param = [num, i, j, alpha, sig^2, rayon, ok]
    
    liste_param = [Pi+i , ... %y-coordinate
        Pj+j , ... %x-coordinate
        alpha , ... %mean amplitude
        sig2 , ... %noise power
        offset, ... %background level
        r , ... %r0
        result_ok ];
end %if
end%fonction