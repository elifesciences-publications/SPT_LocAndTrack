% Anders Sejr Hansen, August 2016
% Modified the IF statement for deflation, inserting an else. Also, moved
% "input_deflt" into the ELSE statement to not call it uneccesarily.
% Removed the function output "input_deflt".

function [lestime, dfin, ctrsN] =...
    detect_et_estime_part_1vue_deflt(input, wn, r0, pfa, n_deflt,...
    w,h,minInt,optim)

[lest,ldec,dfin] = detect_et_estime_part_1vue (input, wn, r0, pfa, optim) ;

lestime = lest ;
% No deflation loops
if n_deflt == 0
            border = ceil(wn/2);
        good = lestime(:,7) & ...
            (lestime(:,4)/sqrt(pi)./lestime(:,6)>minInt) & ...
            (lestime(:,1)>border) & (lestime(:,1)<h-border) & ...
            (lestime(:,2)>border) & (lestime(:,2)<w-border) ;
        lestime = lestime(good,:);
        ctrsN = sum(good);
        return

else
    input_deflt = deflat_part_est(input, lest, wn);
    % n DEFLATION LOOPS
    for n=1:n_deflt
        [l,ld,d,N] = detect_et_estime_part_1vue (input_deflt, wn, r0, pfa, optim) ;
        lestime = [lestime ; l] ;
        %%dfin += d
        dfin = dfin | d ;
        input_deflt = deflat_part_est(input_deflt, l, wn);

        if (N==0) || n == n_deflt
            border = ceil(wn/2);
            good = lestime(:,7) & ...
                (lestime(:,4)/sqrt(pi)./lestime(:,6)>minInt) & ...
                (lestime(:,1)>border) & (lestime(:,1)<h-border) & ...
                (lestime(:,2)>border) & (lestime(:,2)<w-border) ;
            lestime = lestime(good,:);
            ctrsN = sum(good);
            return
        end
    end
end
end%function