%catenary arch script for spacing hanging photos evenly
%David Miller
%10/31/2019

clearvars
close all

w = 2.5; %horizontal spacing of suspension points, ft
n = 3;  %number of strings

s = zeros(1,n); %preallocate s, vector of string lengths
s(1) = 3 + (4/12); %ft
t = 4/12; %max spacing between lines, ft
err = .5/12; %amount of vertical error tolerable, maximum, ft

%suspension point coordinates (x,y)
p1 = [0 0];
p2 = [w 0];

%number of points to plot
N = 100;

%solve catenary eq for first line
[x y] = catenary(p1,p2,s(1),N);

%plot initial line
plot([p1(1) p2(1)],[p1(2) p2(2)],'ro',x,y,'b-');
axis  %for visual comparison to reality
hold on

%prevents unescapable while loop
maxIter = 100;

for i = 2:n
    count = 1; %initialize count variable for each new string
    target = min(y)-t; %initialize target height for each new string
    si = 1.01*s(i-1); %initial guess for new string length (dummy var)
    
    while count<maxIter %iteratative solver loop
        [xi yi] = catenary(p1,p2,si,N); %generate catenary with that parameter
        err_i = abs(target - min(yi)); %calculate error from target
        
        if err_i<=err %solver converges
            count = maxIter; %end while loop
            y = yi; %assign variable for next iteration in for loop
            s(i) = si; %assign dummy var value to s vector for final result
            plot(x,y,'b-'); %overlay plot of current string
            
        else %solver does not converge
            count = count+1; %increment count variable
            si = si+err_i*.1; %new guess is increased by an amount proportional to the of error
            
            if count == maxIter %solver does not converge within max # of iterations
                xmin = x(y==min(y)); %find x coordinate of minimum y
                xmin = xmin(1); %eliminate duplicates
                plot(xi,yi,'r--',xmin,target,'g*') %overlay plot of current string
                error('Solver could not converge on a solution.\n')
            end
        end
    end
end