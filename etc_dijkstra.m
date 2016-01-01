function [sp,binform] = dijkstra(A) 

% Moffett Stephen, Jacob Rios, Angel Sun and Blake Borgeson 

% 9/28/01 

% ELEC 422 Group D 

% 

% Solving the Shortest Path Problem using Dijkstra's Algorithm 

% - This function takes in a square matrix as input. The matrix 

% represents the weights of edges in a network of n vertices. A zero 

% indicates that vertices are not adjacent. The function returns 

% an n-1 x 3 matrix, sp, that shows the shortest total path length 

% to each vertex from the starting vertex (in the middle column), 

% and the preceding vertex in the minimum path (in the right column). 

% 

% DIJKSTRA find the shortest paths from the starting vertex to 

% each other vertex in the network. 

% 

% INPUT: 

% A = input matrix 

% 

% OUTPUT: 

% sp = shortest paths to each vertex from starting vertex 


[m,n] = size(A); 


y = [zeros(1,n-1); A(1,2:n); ones(1,n-1)]; % shortest path 

% status (volatile memory) 


p = find(y(1,1:n-1)==0); % p = vector of non-terminated vertices 


iter = 1; 


while ~isempty(p) 


fprintf('\n iter #%d: y = \n ',iter); disp(y); 

pause; 


x = find(y(2,p)>0); % x = vector of indices referring to nonzero entries 


% Step 2 


[a,K] = min(y(2,p(x))); % a = smallest nonzero entry 

% K = index of x referring to a 


o = p(x); 


J = o(K) + 1; % J = index of A referring to a 


y(1,J-1) = 1; % changes termination bit to 1 


p = p(find(p ~= J-1)); % update p 


if ~isempty(p) 



z = find(A(J,p+1)>0); % z = vector of vertices adjacent to J 


r = p(z) + 1; % r = indices (wrt A) of non-terminated adjacent vertices 


w = A(J,r) + y(2,J-1); % distance to all vertices via J 


temp1 = y(2,r-1); 

temp2 = y(3,r-1); 


helper1 = y(2,r-1) > w; % if w is less than previous 

% shortest path ... 


y(3,r-1) = y(3,r-1) + (J - y(3,r-1)).*helper1; % update y 

y(2,r-1) = min(y(2,r-1), w); 


helper2 = temp1 == 0; % if shortest path was zero ... 


y(2,r-1) = y(2,r-1) + (w - y(2,r-1)).*helper2; % update y 

y(3,r-1) = y(3,r-1) + (J - y(3,r-1)).*helper2; 


% y stays unchanged if w > y(2,r-1) 


end 


iter = iter + 1; 


end 


sp = [(2:n)',y(2,:)',y(3,:)'] 


binform = [dec2bin(sp(:,1)) dec2bin(sp(:,2)) dec2bin(sp(:,3))]; 

