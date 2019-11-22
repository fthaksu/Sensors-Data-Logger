function [deviceDataset] = synchronizeRoNIN_FLP(rawDeviceDataset, timeInterval)
% Project:    RoNIN Alignment with Multiple Sensors
% Function:  synchronizeRoNIN_FLP
%
% Description:
%   get synchronized RoNIN, Google FLP smartphone dataset
%
% Example:
%   OUTPUT:
%   deviceDataset:
%
%   INPUT:
%   rawDeviceDataset: result from loadRawSmartphoneDataset function
%   timeInterval: time resolution (second)
%
%
% NOTE:
%   Copyright 2019 GrUVi Lab @ Simon Fraser University
%
% Author: Pyojin Kim
% Email: pjinkim1215@gmail.com
% Website: http://pyojinkim.com/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% log:
% 2019-11-21: ing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%


% re-arrange RoNIN, FLP variables
RoninPoseTime = rawDeviceDataset.RoninPoseTime;
RoninPoseDegree = rawDeviceDataset.RoninPoseDegree;
FLPPoseTime = rawDeviceDataset.FLPPoseTime;
FLPPoseDegree = rawDeviceDataset.FLPPoseDegree;
FLPPoseMeter = rawDeviceDataset.FLPPoseMeter;
FLPAccuracyMeter = rawDeviceDataset.FLPAccuracyMeter;


% define reference time and data
startTime = max([RoninPoseTime(1), FLPPoseTime(1)]);
RoninPoseTime = RoninPoseTime - startTime;
FLPPoseTime = FLPPoseTime - startTime;
endTime = max([RoninPoseTime(end), FLPPoseTime(end)]);

syncTimestamp = [0.001:timeInterval:endTime];
numData = size(syncTimestamp,2);


% synchronize RoNIN, Google FLP
syncRoninPoseDegree = zeros(2,numData);
syncFLPPoseDegree = zeros(2,numData);
syncFLPPoseMeter = zeros(2,numData);
syncFLPAccuracyMeter = zeros(1,numData);
for k = 1:numData
    
    % remove future timestamp
    currentTime = syncTimestamp(k);
    validIndexRoNIN = ((currentTime - RoninPoseTime) > 0);
    validIndexFLP = ((currentTime - FLPPoseTime) > 0);
    timestampRoNIN = RoninPoseTime(validIndexRoNIN);
    timestampFLP = FLPPoseTime(validIndexFLP);
    
    % RoNIN
    [~,indexRoNIN] = min(abs(currentTime - timestampRoNIN));
    syncRoninPoseDegree(:,k) = RoninPoseDegree(:,indexRoNIN);
    
    % FLP
    [~,indexFLP] = min(abs(currentTime - timestampFLP));
    syncFLPPoseDegree(:,k) = FLPPoseDegree(:,indexFLP);
    syncFLPPoseMeter(:,k) = FLPPoseMeter(:,indexFLP);
    syncFLPAccuracyMeter(k) = FLPAccuracyMeter(1,indexFLP);
    
    % display current status
    fprintf('Current Status: %d / %d \n', k, numData);
end


% save the synchronized RoNIN, Google FLP
deviceDataset.syncTimestamp = syncTimestamp;
deviceDataset.syncRoninPoseDegree = syncRoninPoseDegree;
deviceDataset.syncFLPPoseDegree = syncFLPPoseDegree;
deviceDataset.syncFLPPoseMeter = syncFLPPoseMeter;
deviceDataset.syncFLPAccuracyMeter = syncFLPAccuracyMeter;


end

