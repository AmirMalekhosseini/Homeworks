
% Part a:
function bit_count = find_mantissa_bits()

    epsilon = 1;
    bit_count = 0;
    
    while true
        epsilon = epsilon / 2;
        one_plus_epsilon = 1 + epsilon;
        
        if one_plus_epsilon == 1
            break
        end
        
        bit_count = bit_count + 1;
    end
end

% Test part a:
mantissa_bits = find_mantissa_bits();
fprintf('Number of mantissa bits: %d\n', mantissa_bits);



% Part b:

function N = max10(m, limit)

N = 0;
factorFive = 1;
expCount = 1;
factorTwo = 2;

while (expCount + N <= limit) && (expCount <= m)

    N = N + 1;
    factorFive = factorFive * 5;

    if (2 * factorTwo <= factorFive) && (factorFive < 4 * factorTwo)
        expCount = expCount + 2;
        factorTwo = factorTwo * 4;
    else
        expCount = expCount + 3;
        factorTwo = factorTwo * 8;
    end
end

N = N - 1;
end

% Test part b:
test_cases = [
    15, 20;
    20, 50;
    25, 100;
    52, 1024
];

for i = 1:size(test_cases, 1)
    m = test_cases(i, 1);
    limit = test_cases(i, 2);
    result = max10(m, limit);
    fprintf('max10(%d, %d) = %d\n', m, limit, result);
end



