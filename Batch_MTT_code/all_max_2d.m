function carte_max = all_max_2d(input)

[N,M] = size(input) ;
ref = input(2:N-1, 2:M-1) ;

pos_max_h = input(1:N-2, 2:M-1) < ref & ...
    input(3:N  , 2:M-1) < ref;
pos_max_v = input(2:N-1, 1:M-2) < ref & ...
    input(2:N-1, 3:M  ) < ref;
pos_max_135 = input(1:N-2, 1:M-2) < ref & ...
    input(3:N  , 3:M  ) < ref;
pos_max_45  = input(3:N  , 1:M-2) < ref & ...
    input(1:N-2, 3:M  ) < ref;

carte_max = zeros(N,M) ;
carte_max(2:N-1, 2:M-1) = pos_max_h & pos_max_v & pos_max_135 & pos_max_45 ;
carte_max = carte_max .* input ;

end %function
