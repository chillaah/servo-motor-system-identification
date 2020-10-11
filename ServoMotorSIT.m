%% EGB345 - Servo Motor Identification Task 

%% Question 1
close all; clear; clc

% let's not run for 3 days :)
tStart = tic;

% creating randomly assigned data
% [km, alpha] = GenerateCSVRandom('EGB345RandomData.csv');
% true values of km and alpha
% km = 6.953793434319672;
% alpha = 3.027161552216756;

% first column is time data
% second column is step input data
% third column is step response data
% reading data from csv file to matlab workspace
csvfiledata = csvread('EGB345RandomData.csv', 2, 0);

% getting channel 1 which reads step input and channel 2 which reads step response data
step_input = csvfiledata(:, 2);
yn_random = csvfiledata(:, 3);

% getting channel 1 which is the time vector to plot
time = csvfiledata(:,1);

% plotting the unshifted and undelayed step response
figure();
plot(time, yn_random, 'red', 'LineWidth', 1, 'MarkerSize', 14);
hold on
grid on
box on

save('prelabdata_yn_random.txt','yn_random','-ascii');

% checking for abrupt changes in step input voltage
% expecting 2 results as output since there is only 2 places of interest
% 1. when step is on 2. when step is off
change = time(ischange(step_input, 'linear'));

% shifting time vector so that plot starts at approximately t = 0
time = time - change(1);

% defining start time and endtime for the response
% % using step input as a reference
starttime = 0;
endtime = change(2) - change(1);

% removing voltage offset by first calculating mean before t = 0 mean
% offset = yn_random(time < 0);
% offset = mean(offset);

% removing the voltage offset
% yn_random_fixed now starts from amplitude = 0
% yn_random_fixed now solely represents the response of the motor
% yn_random_fixed = yn_random - offset;

% removing offset and delays
% step input was from t = 0 to t = 1.5 approx.
% cropping the function with respect to the step response ON time
t = time((time >= starttime) & (time <= endtime));
yn_random = yn_random((time >= starttime) & (time <= endtime));

offset = yn_random(1);
yn_random_fixed = yn_random - offset;

% plotting shifted and delayed step response against time
plot(t, yn_random_fixed, 'blue', 'LineWidth', 1, 'MarkerSize', 14);

% axes labelling, title and legends
xlabel('time (s)', 'FontSize', 16);
ylabel('V_P(t)', 'FontSize', 16);
title('Open Loop Time Response Of The Motor System', 'FontSize', 20);
legend({'yn\_random', 'yn\_random\_fixed'}, 'FontSize', 16, 'Location', 'best');

% saving the generated step response and fixed step response as .txt files
save('prelabdata_yn_random_fixed.txt','yn_random_fixed','-ascii');


%% Question 2

% % Given values
% km = 6.953793434319672;
% alpha = 3.027161552216756;
%
% % TF =
%  
% %       6.954
% %   -------------
% %   s^2 + 3.027 s

% using yn_random_fixed data for the estmotor function
% to estimate K_est and alpha_est to test the functionig of our model
ydata = yn_random_fixed;

% running the estmotor function
[K_est, alpha_est] = estmotor(t, ydata);

% getting output K_est and storing in the numerator
numerator = [K_est];

% getting output alpha_est and storing in the denominator
denominator = [1 alpha_est 0];

% motor's shaft angle transfer function from estimated values
sysPerfectTF = tf(numerator, denominator);

% step response from estimated motor's shaft angle transfer function
sysPerfectSR = step(sysPerfectTF, t);

% error plot of yn_random_fixed vs motor's estimated step response
figure();
error = yn_random_fixed - sysPerfectSR;
plot(t, error, 'black', 'LineWidth', 1, 'MarkerSize', 14);
grid on
box on
xlabel('time (s)', 'FontSize', 16);
ylabel('amplitude', 'FontSize', 16);
title('error between yn\_random\_fixed and estimated step response', 'FontSize', 20);

% plotting motor's estimated step response and fixed step response against time
figure();
plot(t, yn_random_fixed, 'red', 'LineWidth', 1, 'MarkerSize', 14);
hold on
grid on
box on
plot(t, sysPerfectSR, 'blue', 'LineWidth', 1, 'MarkerSize', 14);

% axes labelling, title and legends
xlabel('time (s)', 'FontSize', 16);
ylabel('V_P(t)', 'FontSize', 16);
title('Estimation For Open Loop Time Response Of Motor System', 'FontSize', 20);
legend({'yn\_random\_fixed', 'motor''s estimated step response'}, 'FontSize', 16, 'Location', 'best');


%% Question 3

% Generate unknown data

% Use the estmotor function to find the best estimates for 'km' and 'alpha'

% Remove voltage offset and shift time response (similar to task 1)

% Plot y1 and the estimated y1

% Generating unknown data
% UnknownData('EGB345UnknownData.csv', 10454012);

unknowndata = csvread('EGB345UnknownData.csv', 2, 0);

time_unknown = unknowndata(:,1);
step_input_unknown = unknowndata(:,2);
step_response_unknown = unknowndata(:,3);

figure();
plot(time_unknown, step_response_unknown, 'LineWidth', 1, 'MarkerSize', 14);
hold on
grid on
box on

change_unknown = time_unknown(ischange(step_input_unknown, 'linear'));
time_unknown = time_unknown - change_unknown(1);
starttime_unknown = 0;
endtime_unknown = change_unknown(2) - change_unknown(1);

% offset_unknown = step_response_unknown(time_unknown < 0);
% offset_unknown = mean(offset_unknown);

t_unknown = time_unknown((time_unknown >= starttime_unknown) & (time_unknown <= endtime_unknown));
step_response_unknown = step_response_unknown((time_unknown >= starttime_unknown) & (time_unknown <= endtime_unknown));

offset_unknown = step_response_unknown(1);
y1 = step_response_unknown - offset_unknown;

save('prelabdata_y1.txt', 'y1', '-ascii');

plot(t_unknown, y1, 'LineWidth', 1, 'MarkerSize', 14);

xlabel('time (s)', 'FontSize', 16);
ylabel('V_P(t)', 'FontSize', 16);
title('unknown step response & unknown fixed step response vs unknown time', 'FontSize', 20);
legend({'unknown step response', 'y1'}, 'FontSize', 16, 'Location', 'best');

[K_est_unknown, alpha_est_unknown] = estmotor(t_unknown, y1);

numerator_unknown = [K_est_unknown];

denominator_unknown = [1 alpha_est_unknown 0];

sysPerfectTF_unknown = tf(numerator_unknown, denominator_unknown);

sysPerfectSR_unknown = step(sysPerfectTF_unknown, t_unknown);

figure();
error_unknown = y1 - sysPerfectSR_unknown;
plot(t_unknown, error_unknown, 'black', 'LineWidth', 1, 'MarkerSize', 14);
grid on
box on
xlabel('time (s)', 'FontSize', 16);
ylabel('amplitude', 'FontSize', 16);
title('error between y1 and estimated unknown step response', 'FontSize', 20);

figure();
plot(t_unknown, y1, 'red', 'LineWidth', 1, 'MarkerSize', 14);
hold on
grid on
box on
plot(t_unknown, sysPerfectSR_unknown, 'blue', 'LineWidth', 1, 'MarkerSize', 14);

xlabel('time (s)', 'FontSize', 16);
ylabel('V_P(t)', 'FontSize', 16);
title('Estimation For Unknown Data''s Open Loop Time Response', 'FontSize', 20);
legend({'EGB345UnknownData(y1)', 'unknown estimated step response'}, 'FontSize', 16, 'Location', 'best');

tEnd = toc(tStart)/60;
disp('* in spongebob tune *'); disp('A FEW MOMENTS LATER...');
disp('Code ran for'); disp(tEnd); disp('   minutes :)');
