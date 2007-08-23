%RBNBPlugIn receives requests from RBNB, calls m-files to handle them
% note blocks until ctrl-C received
% call as RBNBPlugIn(rbnb,piname)
% example: RBNBPlugIn('localhost:3333','matlab')
function RBNBPlugIn(rbnb,piname)

timeout=2000; %max wait for data from sink

import com.rbnb.sapi.*;
import com.rbnb.utility.KeyValueHash;

if nargin~=2
    error('try calling calc(rbnb,piname)');
else
    %set up plugin and sink
    pi=PlugIn;
    pi.OpenRBNBConnection(rbnb,piname);
    snk=Sink;
    snk.OpenRBNBConnection(rbnb,'matsink');
    
    %loop handling requests
    while(1)
        picm=pi.Fetch(100); %time out so ctrl-C will terminate
        if (~picm.GetIfFetchTimedOut)
            if picm.GetRequestReference.equalsIgnoreCase('registration')
                %if wildcard registration request, give null response
                if (picm.GetName(0).endsWith('*')||picm.GetName(0).endsWith('...'))
                	picm.Clear;
                else
                    picm.PutTime(java.lang.System.currentTimeMillis/1000.0,0);
                    for i=1:picm.NumberOfChannels
                        picm.PutDataAsByteArray(i-1,[0]);
                    end
                end
                pi.Flush(picm);
            else
                %extract input src/chans, build request map
                chans=picm.GetName(0).split('/');
                userfunc=chans(1); %matlab function to call
                source=chans(2); %input channel's RBNB source name
                cm=ChannelMap;
                clear vars;
                for i=3:length(chans)
                    %other entries are either channel names or constants
                    x=str2double(chans(i));
                    if (isnan(x))
                        vars{i-2}=source.concat('/').concat(chans(i));
                        cm.Add(vars{i-2});
                    else
                        vars{i-2}=x;
                    end
                end
                if (cm.NumberOfChannels>0)
                    %fetch input data
                    snk.Request(cm,picm.GetRequestStart,picm.GetRequestDuration,picm.GetRequestReference);
                    cmr=snk.Fetch(timeout);
                else
                    cmr=ChannelMap;
                end
                if (~cmr.GetIfFetchTimedOut && cm.NumberOfChannels==cmr.NumberOfChannels)
                    dosend=1;
                    %prepare input data for matlab function
                    for i=1:length(vars)
                        if (~isnumeric(vars{i}))
                            idx=cmr.GetIndex(vars{i});
                            if (idx>-1)
                                if (cmr.GetType(idx)==ChannelMap.TYPE_FLOAT32) vars{i}=cmr.GetDataAsFloat32(idx);
                                elseif (cmr.GetType(idx)==ChannelMap.TYPE_FLOAT64) vars{i}=cmr.GetDataAsFloat64(idx);
                                elseif (cmr.GetType(idx)==ChannelMap.TYPE_INT32) vars{i}=cmr.GetDataAsInt32(idx);
                                elseif (cmr.GetType(idx)==ChannelMap.TYPE_INT64) vars{i}=cmr.GetDataAsInt64(idx);
                                else
                                    disp('data type not float32, float64, int32, or int64, cannot process');
                                    dosend=0;
                                end
                            else
                                disp('failed to obtain input data, aborting');
                                dosend=0;
                            end
                        end
                    end
                    if (dosend)
                        %call userfunc, flush data - assumes same number of
                        %points as input channels
                        try
                            y=eval(strcat(char(userfunc),'(vars)'));
                            if (cmr.NumberOfChannels>0) picm.PutTimeRef(cmr,0);
                            else picm.PutTime(picm.GetRequestStart,picm.GetRequestDuration);
                            end
                            picm.PutDataAsFloat64(0,y);
                        catch
                            disp(strcat('error calling ',char(userfunc),'; aborting'));
                            foo=lasterror;
                            disp(foo.message);
                        end
                    end
                end
                pi.Flush(picm);
            end
        end
    end
end