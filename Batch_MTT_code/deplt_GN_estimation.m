% Anders Sejr Hansen, August 2016
% Modified SLIMfast function: it sometimes get stuck in the WHILE loop and
% performs infinite iterations. So set a threshold: no more than 10000
% iterations of the while loop should be allowed. 

function [n_r, n_i, n_j, dr, di, dj, alpha, sig2 m] = ...
    deplt_GN_estimation(p_r, p_i, p_j, x, sig2init, p_dr, p_di, p_dj, optim)

%%  p_di, p_dj les precedents deplacements
%% qui ont conduit a p_r, p_i, p_j

r0 = p_r ;
i0 = p_i ;
j0 = p_j ;
prec_rel = 10^optim(2) ;

verif_crit = 1 ;
pp_r = r0 - p_dr ;
pp_i = i0 - p_di ;
pp_j = j0 - p_dj ;

[wn_i, wn_j] = size(x) ;
N = wn_i * wn_j ;
refi = 0.5 + (0:(wn_i-1)) - wn_i/2 ;
refj = 0.5 + (0:(wn_j-1)) - wn_j/2 ;

%% on boucle, en diminuant les deplacements
%% tand que le nouveau critere en plus grand
again = 1 ;
while_iter = 0;
while (again)
    
    i = refi - i0 ;
    j = refj - j0 ;
    ii = i' * ones(1,wn_j) ; %'
    jj = ones(wn_i,1) * j ;
    
    %% puissance unitaire
    iiii = ii.*ii ;
    jjjj = jj.*jj ;
    iiii_jjjj = iiii + jjjj ;
    g = (1/(sqrt(pi)*r0)) * exp(-(1/(2*r0^2))*(iiii_jjjj)) ;
    gc = g - sum(g(:))/N ;
    Sgc2 = sum(gc(:).^2) ;
    g_div_sq_r0 = inv(r0^2) * g ;
    
    %% alpha estime MV
    if (Sgc2 ~= 0)
        alpha = sum(sum(x .* gc)) / Sgc2 ;
    else
        alpha = 0 ;
    end%if
    %% m estime MV
    x_alphag = x - alpha.*g ;
    m = sum(sum(x_alphag))/N ;
    
    err = x_alphag - m ;
    
    %% critere avant deplacement
    sig2 = sum(sum(err.^2)) / N ;
    if ((verif_crit) && (sig2 > sig2init))
        p_di = p_di / 10.0 ;
        p_dj = p_dj / 10.0 ;
        i0 = pp_i + p_di ;
        j0 = pp_j + p_dj ;
        if optim(3)
            p_dr = p_dr / 10.0 ;
            r0 = pp_r + p_dr ;
        else
            p_dr = 0;
            r0 = pp_r;
        end %if
        if (max([abs(p_dr), abs(p_di), abs(p_dj)]) > prec_rel)
            %      if (max([abs(p_di), abs(p_dj)]) > prec_rel)
            n_r = p_r ;
            n_i = p_i ;
            n_j = p_j ;
            dr = 0 ;
            di = 0 ;
            dj = 0 ;
            return ;
        end%if
    else
        again = 0 ;
    end%if
    
    % MAKE SURE YOU SET A LIMIT ON THE NUMBER OF ITERATIONS
    if while_iter > 10000
        again = 0; %break the while loop
    end
    
    while_iter = while_iter +1;
end%while

%% der_g
der_g_i0 =  ii .* g_div_sq_r0 ;
der_g_j0 =  jj .* g_div_sq_r0 ;

%% derder_g
derder_g_i0 = (-1 + inv(r0^2)*iiii) .* g_div_sq_r0 ;
derder_g_j0 = (-1 + inv(r0^2)*jjjj) .* g_div_sq_r0 ;

%% der_J /2
der_J_i0 = alpha * sum(sum(der_g_i0 .* err)) ;
der_J_j0 = alpha * sum(sum(der_g_j0 .* err)) ;

%% derder_J /2
derder_J_i0 = alpha * sum(sum(derder_g_i0 .* err)) - alpha^2 * sum(sum(der_g_i0.^2)) ;
derder_J_j0 = alpha * sum(sum(derder_g_j0 .* err)) - alpha^2 * sum(sum(der_g_j0.^2)) ;

%% deplacement par Gauss-Newton
if optim(3)
    der_g_r0 = (-inv(r0) + inv(r0^3)*(iiii_jjjj)) .* g ;
    derder_g_r0 = (1 - 3*inv(r0^2)*iiii_jjjj) .* g_div_sq_r0 ...
        + (-inv(r0) + inv(r0^3)*(iiii_jjjj)) .* der_g_r0 ;
    der_J_r0 = alpha * sum(sum(der_g_r0 .* err)) ;
    derder_J_r0 = alpha * sum(sum(derder_g_r0 .* err)) - alpha^2 * sum(sum(der_g_r0.^2)) ;
    dr = - der_J_r0 / derder_J_r0 ;
    n_r = abs(r0 + dr) ; %% r0 > 0
else
    dr = 0;
    n_r = r0;
end %if

di = - der_J_i0 / derder_J_i0 ;
dj = - der_J_j0 / derder_J_j0 ;

n_i = i0 + di ;
n_j = j0 + dj ;

end %function