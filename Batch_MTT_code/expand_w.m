function out = expand_w(in, N, M)

[N_in, M_in] = size(in) ;

out = zeros(N,M) ;
%nc = 1+floor(N/2 - N_in/2) ;
%mc = 1+floor(M/2 - M_in/2) ;
%out(nc:(nc+N_in-1) , mc:(mc+M_in-1)) = in ;

nc = floor(N/2 - N_in/2) ;
mc = floor(M/2 - M_in/2) ;
out((nc+1):(nc+N_in) , (mc+1):(mc+M_in)) = in ;

end %function