% Part a:
function [digits, exponent, relativeError] = convertToBase(number, base, precision)
    exponentPower = floor(log(number)/log(base));
    digits = zeros(1, precision);
    validDigits = min(exponentPower, precision);
    exponent = exponentPower + 1;
    remainder = number;

    for index = 1 : validDigits
        weight = base^(exponentPower - index + 1);
        digits(index) = floor(remainder / weight);
        remainder = remainder - digits(index) * weight;
    end

    halfBase = base/2;
    weight = weight/base;
    nextDigit = floor(remainder / weight);

    if nextDigit >= halfBase
        remainder = abs(remainder - base^(exponent - precision));
        currentIndex = precision;
        
        while (currentIndex >= 1)
            digits(currentIndex) = digits(currentIndex) + 1;
            if (digits(currentIndex) == base)
                digits(currentIndex) = 0;
                currentIndex = currentIndex - 1;
            else
                break
            end
        end
        
        if (currentIndex == 0)
            exponent = exponent + 1;
            digits(1) = 1;
        end
    end
    
    relativeError = remainder/number;
end

% Part b:
function [digits, exponent, relativeError] = enhancePrecision(number, base, precision, maxError)
    [digits, exponent, relativeError] = convertToBase(number, base, precision);
    
    if relativeError > maxError
        precision = 2 * precision;
        [digits, exponent, relativeError] = convertToBase(number, base, precision);
    end
end


% Test Case:
[digits, exponent, error] = enhancePrecision(17, 2, 5, 0.01);
disp('Mantissa Digits:'); disp(digits);
disp(['Exponent: ', num2str(exponent)]);
disp(['Relative Error: ', num2str(error)]);