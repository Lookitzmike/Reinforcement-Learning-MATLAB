function [allData, scenario, sensors] = DrivingSD_2()
%DrivingSD_2 - Returns sensor detections
%    allData = DrivingSD_2 returns sensor detections in a structure
%    with time for an internally defined scenario and sensor suite.
%
%    [allData, scenario, sensors] = DrivingSD_2 optionally returns
%    the drivingScenario and detection generator objects.

% Generated by MATLAB(R) 9.5 and Automated Driving System Toolbox 1.3.
% Generated on: 15-Mar-2019 20:54:02

% Create the drivingScenario object and ego car
[scenario, egoCar] = createDrivingScenario;

% Create all the sensors
[sensors, numSensors] = createSensors(scenario);

allData = struct('Time', {}, 'ActorPoses', {}, 'ObjectDetections', {}, 'LaneDetections', {});
running = true;
while running
    
    % Generate the target poses of all actors relative to the ego car
    poses = targetPoses(egoCar);
    % Generate the boundaries of all lanes relative to the ego car for 100m
    lanes = laneBoundaries(egoCar, 'XDistance', 100);
    time  = scenario.SimulationTime;
    
    objectDetections = {};
    laneDetections   = [];
    isValidTime      = false(1, numSensors);
    isValidLaneTime  = false(1, numSensors);
    
    % Generate detections for each sensor
    for sensorIndex = 1:numSensors
        type = getDetectorOutput(sensors{sensorIndex});
        if strcmp(type, 'Objects only')
            [objectDets, numObjects, isValidTime(sensorIndex)] = sensors{sensorIndex}(poses, time);
            objectDetections = [objectDetections; objectDets(1:numObjects)]; %#ok<AGROW>
        elseif strcmp(type, 'Lanes only')
            [laneDets, ~, isValidTime(sensorIndex)] = sensors{sensorIndex}(lanes, time);
            laneDetections   = [laneDetections laneDets]; %#ok<AGROW>
        elseif strcmp(type, 'Lanes and objects')
            [objectDets, numObjects, isValidTime(sensorIndex), laneDets, ~, isValidLaneTime(sensorIndex)] = sensors{sensorIndex}(poses, lanes, time);
            objectDetections = [objectDetections; objectDets(1:numObjects)]; %#ok<AGROW>
            laneDetections   = [laneDetections laneDets]; %#ok<AGROW>
        elseif strcmp(type, 'Lanes with occlusion')
            [laneDets, ~, isValidLaneTime(sensorIndex)] = sensors{sensorIndex}(poses, lanes, time);
            laneDetections   = [laneDetections laneDets]; %#ok<AGROW>
        end
    end
    
    % Aggregate all detections into a structure for later use
    if any(isValidTime) || any(isValidLaneTime)
        allData(end + 1) = struct( ...
            'Time',       scenario.SimulationTime, ...
            'ActorPoses', actorPoses(scenario), ...
            'ObjectDetections', {objectDetections}, ...
            'LaneDetections',   {laneDetections}); %#ok<AGROW>
    end
    
    % Advance the scenario one time step and exit the loop if the scenario is complete
    running = advance(scenario);
end

% Restart the driving scenario to return the actors to their initial positions.
restart(scenario);

% Release all the sensor objects so they can be used again.
for sensorIndex = 1:numSensors
    release(sensors{sensorIndex});
end

%%%%%%%%%%%%%%%%%%%%
% Helper functions %
%%%%%%%%%%%%%%%%%%%%

% Units used in createSensors and createDrivingScenario
% Distance/Position - meters
% Speed             - meters/second
% Angles            - degrees
% RCS Pattern       - dBsm

function [sensors, numSensors] = createSensors(scenario)
% createSensors Returns all sensor objects to generate detections

% Assign into each sensor the physical and radar profiles for all actors
profiles = actorProfiles(scenario);
sensors{1} = visionDetectionGenerator('SensorIndex', 1, ...
    'SensorLocation', [3.7 0], ...
    'MaxRange', 10, ...
    'DetectorOutput', 'Lanes and objects', ...
    'Intrinsics', cameraIntrinsics([907.405091138834 907.405091138834],[320 240],[480 320]), ...
    'ActorProfiles', profiles);
sensors{2} = radarDetectionGenerator('SensorIndex', 2, ...
    'SensorLocation', [2.8 0.9], ...
    'Yaw', 30, ...
    'MaxRange', 10, ...
    'FieldOfView', [75 5], ...
    'ActorProfiles', profiles);
sensors{3} = radarDetectionGenerator('SensorIndex', 3, ...
    'SensorLocation', [2.8 -0.9], ...
    'Yaw', -30, ...
    'MaxRange', 10, ...
    'FieldOfView', [75 5], ...
    'ActorProfiles', profiles);
numSensors = 3;

function [scenario, egoCar] = createDrivingScenario
% createDrivingScenario Returns the drivingScenario defined in the Designer

% Construct a drivingScenario object.
scenario = drivingScenario;

% Add all road segments
roadCenters = [-16.28 23.58 0;
    10.38 17.97 0;
    15.61 -5.69 0];
marking = [laneMarking('Solid', 'Color', [0.98 0.86 0.36])
    laneMarking('DoubleSolid')
    laneMarking('Solid')];
laneSpecification = lanespec(2, 'Width', 3.1, 'Marking', marking);
road(scenario, roadCenters, 'Lanes', laneSpecification);

% Add the ego car
egoCar = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [-9.27 22.46 0.01]);
waypoints = [-9.27 22.46 0.01;
    1.59 21.2 0.01;
    9.89 16.9 0.01;
    13.66 8.45 0.01;
    13.81 -0.37 0.01];
speed = 30;
trajectory(egoCar, waypoints, speed);

% Add the non-ego actors
car1 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [16.86 0.78 0.01]);
waypoints = [17.08 0.92 0.01;
    15.54 12.89 0.01;
    11.39 19.3 0.01;
    3.85 23.68 0.01;
    -7.39 25.18 0.01;
    -10.48 25.11 0.01];
speed = 30;
trajectory(car1, waypoints, speed);

pedestrian = actor(scenario, ...
    'ClassID', 4, ...
    'Length', 0.24, ...
    'Width', 0.45, ...
    'Height', 1.7, ...
    'Position', [9.72 8.99 0], ...
    'RCSPattern', [-8 -8;-8 -8]);
waypoints = [9.72 8.99 0;
    16.79 11.2 0.01];
speed = 4;
trajectory(pedestrian, waypoints, speed);

function output = getDetectorOutput(sensor)

if isa(sensor, 'visionDetectionGenerator')
    output = sensor.DetectorOutput;
else
    output = 'Objects only';
end

