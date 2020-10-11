function [K_est, alpha_est] = estmotor(t, ydata)

% simulating the motor's shaft angle
% 't' contains the shifted and truncated time vector
% 'ydata' contains the step response data to be compared against
% i have used 3 - double for loops each searching for a different significant figure
% approach based on exhaustive search using for loops and comparing root mean squared error
% by narrowing down for loop ranges through interpolation we arrive at our estimated km and alpha values

% starting root mean squared value of error
old_RMSE = 1e100;

% 0th decimal place
% estimation for 1st significant figure
% iterating over 2 for loops with step size of 1 to estimate km and alpha
for km_1sigfig = 0 : 1 : 10
    for alpha_1sigfig = 0 : 1 : 10
        
        % setting up test motor transfer function
        % getting numerator and denominator and denominator
        % calculating transfer function using 'tf' command
        numeratorTest = [ km_1sigfig ];
        denominatorTest = [ 1 alpha_1sigfig 0 ];
        motor_TF = tf(numeratorTest, denominatorTest);
                    
        % test motor system response to step input to get step response
        motor_SR = step(motor_TF, t);
        
        % error of current motor data
        data_error = ydata - motor_SR;
        
        % calculating the root mean squared value of the error
        RMSE = rms(data_error);
        
        % if the rmse of the current data
        % is less than the rmse of the previous data
        % storing the current data in variables
        % as numerator and denominator
        if RMSE < old_RMSE
            
            num_proper = [ km_1sigfig ]; % numerator
            den_proper = [ 1 alpha_1sigfig 0 ]; % denominator
            old_RMSE = RMSE;
            
        end
    end
end

% 1st decimal place
% estimation for 2nd significant figure
% interpolating data with a new range and decreased step size
% iterating over 2 for loops with step size of 0.1 to estimate km and alpha
for km_2sigfigs = num_proper(:) - 2 : 0.1 : num_proper(:) + 2
    for alpha_2sigfigs = den_proper(:,2) - 2 : 0.1 : den_proper(:,2) + 2
        
        % setting up motor test transfer function
        numeratorTest = [ km_2sigfigs ];
        denominatorTest = [ 1 alpha_2sigfigs 0 ];
        motor_TF = tf(numeratorTest, denominatorTest);
                    
        % test motor system response to step input to get step response
        motor_SR = step(motor_TF, t);
        
        % error of current motor data
        data_error =  ydata - motor_SR;

        % calculating the root mean squared value of the error
        RMSE = rms(data_error);
        
        % if the rmse of the current data
        % is less than the rmse of the previous data
        % storing the current data in variables
        % as numerator and denominator
        if RMSE < old_RMSE
            
            num_proper = [ km_2sigfigs ]; % numerator
            den_proper = [ 1 alpha_2sigfigs 0 ]; % denominator
            old_RMSE = RMSE;
            
        end
    end
end

% 2nd decimal place
% estimation for 3rd significant figure
% interpolating data with a new range and decreased step size
% iterating over 2 for loops with step size of 0.01 to estimate km and alpha
for km_3sigfigs = num_proper(:) - 1 : 0.01 : num_proper(:) + 1
    for alpha_3sigfigs = den_proper(:,2) - 1 : 0.01 : den_proper(:,2) + 1
        
        % setting up motor test transfer function
        numeratorTest = [ km_3sigfigs ];
        denominatorTest = [ 1 alpha_3sigfigs 0 ];
        motor_TF = tf(numeratorTest, denominatorTest);
                    
        % test motor system response to step input to get step response
        motor_SR = step(motor_TF, t);
        
        % error of current motor data
        data_error =  ydata - motor_SR;

        % calculating the root mean squared value of the error
        RMSE = rms(data_error);
        
        % if the rmse of the current data
        % is less than the rmse of the previous data
        % storing the current data in variables
        % as numerator and denominator
        if RMSE < old_RMSE
            
            num_proper = [ km_3sigfigs ]; % numerator
            den_proper = [ 1 alpha_3sigfigs 0 ]; % denominator
            old_RMSE = RMSE;
            
        end
    end
end

% final root mean squared error of the estimation
disp('final rmse is'); 
disp(old_RMSE);

% numerator and denominator now contain 
% the final estimates with 3 significant figures for variables km and alpha
% estimated km and alpha values for the motor's shaft angle as outputs are stored in K_est and alpha_est
K_est = num_proper; % final km value
alpha_est = den_proper(:,2); % final alpha value

end