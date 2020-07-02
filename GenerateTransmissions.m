function event = GenerateTransmissions(lambda, t, plot_result)
    if(nargin==2)
        plot_result = false;
    end
    
    % Get the step size and number of steps
    N = length(t);
    dt = t(2) - t(1);
    
    % Generate vector of when transmission times occured
    event = zeros(1, N);  % array of when transmissions occur
    R = rand(size(event));  % generate array of random numbers
    event(R<lambda*dt) = 1; % event occurs every time R<lambda*delta
    
    if(plot_result)
        stem(t, event);
        hold on
    end
end



