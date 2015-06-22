function [spikes, lfpdeci, estRMS, spikematrix] = brainsigproc(filestring, process, makeMatrix)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Input: filestring (datatype: String) -> full path of the .ns5 file%
    % Input: process (datatype: double) - > 0 for spike detection       %
    %                                       1 for lfp                   %
    %                                       2 for both                  %
    % Outputs: Cell arrays of spike timings and LFPs                    %
    % Outputs: Array of estimated RMS used for thresholding             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                                   %
    % Coded by B.K. Date:01/30/2015  
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    nsxdatasmall = openNSx(filestring,'read', 'report', 'p:double');%, 't:0:2', 'sec', 'p:double');
    durationmsec = floor(nsxdatasmall.MetaTags.DataDurationSec*1000);
    rawdataFS = nsxdatasmall.MetaTags.SamplingFreq;
    intendedFS = 2000;
    x = {nsxdatasmall.MetaTags.ChannelID};
    x = cell2mat(x);
    estRMS = computeRMS(nsxdatasmall, length(x));
    rmsmultiply = -5.0;
    scalingfactor = 1/4;
    thresh = floor(estRMS.*scalingfactor.*rmsmultiply);
    spikes = cell(length(x),1);
    lfpdeci = cell(length(x),1);
    spikematrix = [];

    'going parallel'
    parfor channel = 1:length(x)
        chnstring = strcat('c:',num2str(channel));
        nsxdataperchannel = openNSx(filestring, chnstring, 'read', 't:10:13', 'min','p:double');
           switch process
               case 0
                   contdata = nsxdataperchannel.Data;
                   hpdata = spkfilter(contdata');
                   detspike = find((hpdata./4)<=thresh(channel));
                   detspikeloc = (hpdata./4)<=thresh(channel);
                   ss = strfind(detspikeloc', [0 1]);
                   ss = ss-11;
                   spikes{channel} = ss;
                   
               case 1
                   contdata = nsxdataperchannel.Data;
                   lpdata = lfpfilt(contdata);
                   decimatedData = decimate(lpdata, round(rawdataFS/intendedFS));
                   lfpdeci{channel} = decimatedData;
               case 2
                   contdata = nsxdataperchannel.Data;
                   hpdata = spkfilter(contdata');
                   detspike = find((hpdata./4)<=thresh(channel));
                   detspikeloc = (hpdata./4)<=thresh(channel);
                   ss = strfind(detspikeloc', [0 1]);
                   ss = ss-11;
                   spikes{channel} = ss;
                   lpdata = lfpfilt(contdata);
                   decimatedData = decimate(lpdata, round(rawdataFS/intendedFS));
                   lfpdeci{channel} = decimatedData;
           end
     end
    if (makeMatrix)
        spikematrix = zeros(max(x), durationmsec);
     for ch = 1:length(x)
      st = floor(spikes{ch}./30);
      st = st(st>0);
      spikematrix(x(ch), st) = 1;        
     end
    end
end
%[~, name, ~] = fileparts(filestring);
%currentfile = sprintf('/project/rossc/BMI/brainsigproc/results/%s_%s.mat', name,num2str(ix));
%save(currentfile, 'spikes', 'lfpdeci', 'estRMS', 'spikematrix', '-v7.3');
