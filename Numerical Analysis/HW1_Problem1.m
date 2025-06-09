function HW1_Problem1

    n = input('Enter a number: ');

    figure;
    hold on;
    axis([0 n 0 n]);
    axis equal; 

    for i = 0:n
        % Vertical line at x = i
        plot([i i], [0 n], 'b');
        % Horizontal line at y = i
        plot([0 n], [i i], 'b');
    end

    for i = 0:n-1
        for j = 0:n-1
            plot([i i+1], [j j+1], 'b');
            plot([i i+1], [j+1 j], 'b');
        end
    end

    hold off;
    title(sprintf('Grid for n = %d', n));
end
