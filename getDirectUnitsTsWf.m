%% Get TimeStamps and Waveforms from direct units sorted online during the experiment
%  This information is in the "snips" field of the the TDT blocks
%  Author: Aamir Abbasi
%  -----------------------------------------------------------------------------------
%% Read spike times and waveforms 
clear;clc;close all; tic;
path = 'Z:\TDTData\BMI_zBus_RS4_RV2_Cb64-201130-100839\'; % For I076
% path = 'Z:\TDTData\BMI_zBus_RS4-200629-101443\'; % For I064
% path = 'Z:\TDTData\BMI_zBus-200310-092524\'; % For I061 and I060
% path = 'Z:\TDTData\BMI_Cedars-191216-135822\'; % For I050 
savepath = 'Z:\Aamir\BMI\I086\Data\';
% sessions = {'I050-191218-*','I050-191219-*','I050-191220-*','I050-191221-*','I050-191223-*'};
sessions = {'I086-210504-*','I086-210505-*','I086-210506-*','I086-210507-*',...
    'I086-210511-*','I086-210512-*','I086-210513-*','I086-210514-*'};
% List of Tp and Tn for I076
% Tp_chs = {25, 9,[2,24,27],[5,7,11,28],[10,16,21,32]};
% Tn_chs = {27,16,[],[],[]};

% List of Tp and Tn for I064
% Tp_chs = {23,17,10,15,20};
% Tn_chs = {[],[],[],17,[]};

% List of Tp and Tn for I061
% Tp_chs = {25,6,29,13,6};
% Tn_chs = {15,27,25,8,27};

% List of Tp and Tn for I060
% Tp_chs = {23,12,24,27,27};
% Tn_chs = {22,27,22, 5,12};

% List of Tp and Tn for I050
% Tp_chs = {27,32,25,18,31};
% Tn_chs = {[],[],[],[],[]};

% List of Tp and Tn for I086
Tp_chs = { 8,24,15,15,10, 8, 6, 4};
Tn_chs = {15,[],[],[],[],[],[],18};

for i = 1:3%length(sessions)
    blocks = dir([path,sessions{i}]);
    for b = 1:length(blocks)
        disp(['Block: ',blocks(b).name]);  
        
        % Preallocate cell arrays
        TimeStamps_tp = cell(32,6);
        TimeStamps_tn = cell(32,6);
        Waves_tp      = cell(32,6);
        Waves_tn      = cell(32,6);
        
        % Read TDT tank
        tank = TDTbin2mat([path,blocks(b).name],'STORE','eNe1');
        
        % Read snippet data from TDT tank
        chans = tank.snips.eNe1.chan;
        ts    = tank.snips.eNe1.ts;
        sc    = tank.snips.eNe1.sortcode;
        wf    = tank.snips.eNe1.data;
        
        % Extract Tp channels
        chs = Tp_chs{i};
        for c=1:length(chs)
            % Get current channel data
            bfr_ts = ts(chans==chs(c));
            bfr_sc = sc(chans==chs(c));
            bfr_wf = wf(chans==chs(c),:);
            
            % Remove noise sortcode
            bfr_sc = bfr_sc(bfr_sc~=31);
            bfr_ts = bfr_ts(bfr_sc~=31);
            bfr_wf = bfr_wf(bfr_sc~=31,:);
            
            % Split data into different sortcodes
            sc_id = 1:max(bfr_sc);
            for d = sc_id
                TimeStamps_tp{chs(c),d+1} = bfr_ts(bfr_sc==d);
                Waves_tp{chs(c),d+1}      = bfr_wf(bfr_sc==d,:);
            end
        end
        
        % Extract Tn channels
        chs = Tn_chs{i};
        for c=1:length(chs)
            % Get current channel data
            bfr_ts = ts(chans==chs(c));
            bfr_sc = sc(chans==chs(c));
            bfr_wf = wf(chans==chs(c),:);
            
            % Remove noise sortcode
            bfr_sc = bfr_sc(bfr_sc~=31);
            bfr_ts = bfr_ts(bfr_sc~=31);
            bfr_wf = bfr_wf(bfr_sc~=31,:);
            
            % Split data into different sortcodes
            sc_id = 1:max(bfr_sc);
            for d = sc_id
                TimeStamps_tn{chs(c),d+1} = bfr_ts(bfr_sc==d);
                Waves_tn{chs(c),d+1}      = bfr_wf(bfr_sc==d,:);
            end
        end
        
        currentsavepath = [savepath,blocks(b).name];
        if ~exist(currentsavepath, 'dir')
            mkdir(currentsavepath);
        end
        save([currentsavepath,'\Timestamps_Direct.mat'], 'TimeStamps_tp','TimeStamps_tn',...
            'Waves_tp','Waves_tn');
    end
end
runTime = toc;
disp(['Done! time elapsed (min) - ', num2str(runTime/60)]);

%%