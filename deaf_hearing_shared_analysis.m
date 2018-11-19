% % Analysis for deaf and hearing groups - fTCD animation description

clc;
% clear all;
clear dop


dop.struc_name = 'dop';

dop.def.task_name = 'deaf_hearing_comparison';

% definition information
dop.def.signal_channels = [3 4]; % columns in file (e.g., EXP)
dop.def.event_channels = 11; % TX/TW files
dop.def.event_height = 45; % 400; % greater than
dop.def.event_sep = 45; %
dop.def.num_events = 25;

dop.def.downsample_rate = 100; % in Hertz. Entering 100 maintains sampling frequency of recorded data. 

% lower and upper values. These will be task specific.

dop.def.epoch = [-12 26]; %[-5 20];
dop.def.baseline = [-10 -2];
dop.def.poi = [4 18];
dop.def.act_window = 2; % activation window

dop = dopPeriodChecks(dop,'wait_warn',1);

dop.def.act_range = [60 140];

dop.def.correct_range = [-3 4];%[50 150]; threshold in % for acceptable activation limits;
dop.def.correct_pct = 5; % if =< x% outside range, correct with mean/median

dop.def.act_separation = 20; % acceptable activation difference
dop.def.act_separation_pct = 1;

dop.def.screen = {'manual','length','act','sep'};


dop.def.keep_data_steps = 1;% keep copy of proccessing steps, e.g., dop.data.norm, dop.data.down etc.

dop.save.extras = {'file','rejected_epochs','period_t_value','period_tp'};%{'file','norm','base'}; % you can add your own variables to this, just need to be defined somewhere as dop.save.x = where x = variable name

dop.save.summary = {'overall'}; % vs 'epoch'
dop.save.channels = {'Difference'};
dop.save.periods = {'poi'};
dop.save.epochs = {'screen','odd','even'};
dop.save.variables = {'period_mean','period_sd_of_mean','peak_n','peak_mean','peak_sd_of_mean','peak_latency','t_value','t_df','tp','ci'};


dop.save.save_file = []; % this will be auto completed based upon the dop.def.task_name variable
dop.save.save_dir = [];

[dop,okay,msg] = dopSaveDir(dop);


dop.data_dir = [];

% dop.file_list = dopGetFileList(dop.data_dir);%;dir(in.dir);
[dop,okay] = dopGetFileList(dop);%;dir(in.dir);
%dop.file_list = {YOUR FILENAMES HERE}
if okay
    
     for i = 1 : numel(dop.file_list)
   
        in.file = dop.file_list{i};
        
        fprintf('%u: %s\n',i,in.file);
        [dop,okay,msg] = dopImport(dop,'file',in.file);
        dop.save.file = dop.file; % dop.save.extras will save this as a column in the file
        % extract signal and event channels from larger set of data columns
        % this is called within dopImport as well
        [dop,okay,msg] = dopChannelExtract(dop,okay,msg);
        
        [dop,okay,msg] = dopDownsample(dop,okay,msg); % or dop.data.down = dopDownSample(dop.data.raw,25,100)
        
        [dop,okay,msg] = dopEventMarkers(dop,okay,msg,'outlier_type','sd'); % done automatically in (and redone at end of) dopDataTrim
        
        [dop,okay,msg] = dopEpochScreenManual(dop,okay,msg,'manual_dir',[]; %%% file with screened epoch numbers available with data files on request.
        
        dop.save.rejected_epochs = dop.tmp.exclude;
        
        [dop,okay,msg] = dopPeriodChecks(dop,okay,msg);
        
        [dop,okay,msg] = dopDataTrim(dop,okay,msg);
        
        [dop,okay,msg] = dopEventChannels(dop,okay,msg);
        
        [dop,okay,msg] = dopHeartCycle(dop,okay,msg);
        
        [dop,okay,msg] = dopActCorrect(dop,okay,msg);
        
        [dop,okay,msg] = dopNorm(dop,okay,msg,'norm_method','epoch');
          
        [dop,okay,msg] = dopEpochScreenAct(dop,okay,msg);
        
        [dop,okay,msg] = dopEpochScreenSep(dop,okay,msg);
        
        [dop,okay,msg] = dopEpochScreenCombine(dop,okay,msg);
        
        [dop,okay,msg] = dopBaseCorrect(dop,okay,msg);
        
        dop = dopPlot(dop,'wait');
        
        if okay
             [dop,okay,msg] = dopCalcAuto(dop,okay,msg);%'periods',{'baseline','poi'}); % ,'poi',[5 15],'act_window',2);
            %% collect grp data?
            [dop,okay,msg] = dopDataCollect(dop,okay,msg);
            fprintf('%u: %u %s\n',i,okay,in.file);
          
        else
            fprintf('%u: %u %s\n',i,okay,in.file);
        end
        
        dop.save.period_t_value = dop.sum.overall.Difference.poi4to18.screen.period_t_value;
        dop.save.period_tp = dop.sum.overall.Difference.poi4to18.screen.period_tp;
        
        [dop,okay,msg] = dopSave(dop,1,msg);%,'save_dir',dop.save.save_dir);
        
        %dop = dopDataCollect(dop,okay,msg);
        
    end
      
    
end

% other functions
% [dop,okay,msg] = dopUseDataOperations(dop,'base');
fprintf('%u: %u %s\n',i,okay,in.file);

% save the 'collected' data for all okay files
[dop,okay,msg] = dopSaveCollect(dop);

[dop,okay,msg] = dopPlot(dop,'collect','type','base'); % plot the 'collected' data for all okay files


save('overall.mat','dop');

dopCloseMsg;% close all popup warning dialogs with one command :)

dopOSCCIalert('finish');