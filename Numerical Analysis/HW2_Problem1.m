function [L, status] = decompose_matrix(M)
    sz = size(M,1);
    L = zeros(sz);
    status = true;
    
    for d = 1:sz
        if M(d,d) <= 0
            status = false;
            L = [];
            return;
        end
        L(d,d) = sqrt(M(d,d));
        
        for r = d+1:sz
            L(r,d) = M(r,d)/L(d,d);
            for c = d+1:r
                M(r,c) = M(r,c) - L(r,d)*L(c,d);
            end
        end
    end
    
end

function [L, cnt] = adjust_matrix(C)
    sz = length(C);
    eye_mat = eye(sz);

    cnt = 0;
    
    [L, valid] = decompose_matrix(C);
    while ~valid
        cnt = cnt + 1;
        C = C + eye_mat;
        [L, valid] = decompose_matrix(C);
    end
end

function y = lower_solve(L, rhs)  
    
    n = numel(rhs);
    y = zeros(n,1);
    if size(L,1) ~= size(L,2)  
        error('L must be square');  
    end
    for k = 1:n
        y(k) = (rhs(k) - L(k,1:k-1)*y(1:k-1)) / L(k,k);
    end
end

function x = upper_solve(U, rhs)  
    
    n = numel(rhs);
    x = zeros(n,1);
    if size(U,1) ~= n  
        error('Dimension mismatch');  
    end
    for k = n:-1:1
        x(k) = (rhs(k) - U(k,k+1:n)*x(k+1:n)) / U(k,k);
    end
end

%% Original test case
A = [1 2 3 4; 2 8 8 6; 3 8 19 17; 4 6 17 37];
b = [7; 6; 29; 72];

[L, t] = adjust_matrix(A);
y = lower_solve(L, b);  
x = upper_solve(L', y);  

disp('L:'); disp(L);
disp('t:'); disp(t);
disp('y:'); disp(y); 
disp('x:'); disp(x);
