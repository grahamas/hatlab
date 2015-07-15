%% Create definitions

definitions = {};

definitions.bands.list_all = {'mid_beta', 'low_beta'};
definitions.bands.mid_beta = [20, 25];
definitions.bands.low_beta = [15, 21]; % Targeting RS's peak 18Hz

% Assume beh is in seconds
definitions.epochs.list_all = {'instruction_early', 'instruction_late',...
    'execution'};
definitions.epochs.instruction_early = ...
    @(beh) [beh(:,3) + .001, beh(:,3) + .500];
definitions.epochs.instruction_late = ...
    @(beh) [beh(:,3) + .501, beh(:,3) + 1.000];
definitions.epochs.execution = ...
    @(beh) [beh(:,5) - .200, beh(:,5) + .299];