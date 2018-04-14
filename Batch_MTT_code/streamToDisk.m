    function streamToDisk(data,outputname)
        %stream data to harddisc
        fidY = fopen([outputname '.ctrsY'], 'a+');
        fidX = fopen([outputname '.ctrsX'], 'a+');
        fidSignal = fopen([outputname '.signal'], 'a+');
        fidNoise = fopen([outputname '.noise'], 'a+');
        fidOffset = fopen([outputname '.offset'], 'a+');
        fidRadius = fopen([outputname '.radius'], 'a+');
        fidFrame = fopen([outputname '.frame'], 'a+');
        
        fwrite(fidY,data(:,1),'real*8'); %y-coordinate
        fwrite(fidX,data(:,2),'real*8'); %x-coordinate
        fwrite(fidSignal,data(:,3)/sqrt(pi)./data(:,6),'real*8'); %peak amplitude
        fwrite(fidNoise,sqrt(data(:,4)),'real*8'); %noise std
        fwrite(fidOffset,data(:,5),'real*8'); %background level
        fwrite(fidRadius,data(:,6),'real*8'); %gaussian radius.
        fwrite(fidFrame,data(:,8),'real*8'); %detected frame
        fclose('all');
    end