% PlotAge.m
% Function to plot the age for any number of sources.

function PlotAge(t, age, lambda, source)
    if nargin == 3
        source = 0;
    end

    numSources = size(age,1);
    avgAge = sum(age, 2) / size(age, 2);

    % Calculate age for each source
    for i = 1:numSources
        if numSources ~= 1
            source = i;
        end    
        
        figure
        set(gcf, 'position', [369, 376, 935, 494]);
        
        plot(t, age(i, :));
        hold on
        plot(t, avgAge(i) .* ones(size(t)));
        xlabel('time (s)');
        ylabel('age (s)');
        title(['Source ', num2str(source), ', lambda = ', strtrim(rats(lambda(i)))]);
        legend('Location', 'northwest')
        legend('Age', ['Avg. Age = ', num2str(avgAge(i), 4)]);
        
		%{
        tFinal = 1800;
        slotDuration = [4.5;25.5];

        user1_slot_begin = 0:sum(slotDuration):tFinal;
        user1_slot_end = slotDuration(1):sum(slotDuration):tFinal;

        legend off
        h = gobjects(size(user1_slot_begin)); 
        for g = 1:numel(user1_slot_begin)
            h(g) = xline(user1_slot_begin(g)); 
        end

        h = gobjects(size(user1_slot_end)); 
        for g = 1:numel(user1_slot_end)
            h(g) = xline(user1_slot_end(g)); 
        end
		%}
       
    end
end
