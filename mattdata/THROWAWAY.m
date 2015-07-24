
load('session040114.mat')
load('definitions.mat')
parpool('local', 16)
session = populate_session(base_session, definitions);
save('NEWsession040114.mat', 'session')
