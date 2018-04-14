function g = gausswin2(sig, wn_i, wn_j, offset_i, offset_j)

if (nargin < 5)
    offset_i = 0.0 ;
    offset_j = 0.0 ;
end%if

if (nargin < 3)
    wn_j = wn_i ;
end%if

refi = 0.5 + (0:(wn_i-1)) - wn_i/2 ;
i = refi - offset_i ;
refj = 0.5 + (0:(wn_j-1)) - wn_j/2 ;
j = refj - offset_j ;
ii = i' * ones(1,wn_j) ; %'
jj = ones(wn_i,1) * j ;

%%% puissance unitaire
g = (1/(sqrt(pi)*sig)) * exp(-(1/(2*sig^2))*(ii.*ii + jj.*jj)) ;
end %function
