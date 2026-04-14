% ================================================
% MDP-ProbLog: Grid de navegación 2×3
% gamma = 0.9, epsilon = 0.1
% ================================================

valid_cell(X,Y) :- row(X), col(Y).

% --- State fluents (multivaluados gracias a la extensión) ---
state_fluent(coor(X,Y), multivalued) :- valid_cell(X,Y).

% --- Actions ---
action(left).
action(right).
action(up).
action(down).
action(stay).

% --- Utilities / Rewards ---
utility(goal, 10).
utility(hole, -10).
utility(step, 0).          % costo por cada paso 

% --- Reward model ---
goal :- coor(2,3, 0).      % meta en la esquina superior derecha
hole :- coor(1,3, 0).      % trampa en la esquina inferior derecha
step :- not(goal), not(hole).

% ================================================
% Transitions (estilo original: 0.8 éxito, 0.1 deslizamiento, 0.1 quedarse)
% ================================================

% --- Desde (1,1) ---
0.80::coor(1,2, 1); 0.10::coor(2,1, 1); 0.10::coor(1,1, 1) :- coor(1,1, 0), right.
0.90::coor(1,1, 1); 0.10::coor(2,1, 1) :- coor(1,1, 0), left.
0.90::coor(1,1, 1); 0.10::coor(1,2, 1) :- coor(1,1, 0), up.
0.80::coor(2,1, 1); 0.10::coor(1,2, 1); 0.10::coor(1,1, 1) :- coor(1,1, 0), down.
1.00::coor(1,1, 1) :- coor(1,1, 0), stay.

% --- Desde (1,2) ---
0.80::coor(1,3, 1); 0.10::coor(2,2, 1); 0.10::coor(1,2, 1) :- coor(1,2, 0), right.
0.80::coor(1,1, 1); 0.10::coor(1,2, 1); 0.10::coor(2,2, 1) :- coor(1,2, 0), left.
0.90::coor(1,2, 1); 0.10::coor(1,3, 1) :- coor(1,2, 0), up.
0.80::coor(2,2, 1); 0.10::coor(1,3, 1); 0.10::coor(1,1, 1) :- coor(1,2, 0), down.
1.00::coor(1,2, 1) :- coor(1,2, 0), stay.

% --- Desde (2,1) ---
0.80::coor(2,2, 1); 0.10::coor(2,1, 1); 0.10::coor(1,1, 1) :- coor(2,1, 0), right.
0.90::coor(2,1, 1); 0.10::coor(1,1, 1) :- coor(2,1, 0), left.
0.80::coor(1,1, 1); 0.10::coor(2,2, 1); 0.10::coor(2,1, 1) :- coor(2,1, 0), up.
0.90::coor(2,1, 1); 0.10::coor(2,2, 1) :- coor(2,1, 0), down.
1.00::coor(2,1, 1) :- coor(2,1, 0), stay.

% --- Desde (2,2) ---
0.80::coor(2,3, 1); 0.10::coor(2,2, 1); 0.10::coor(1,2, 1) :- coor(2,2, 0), right.
0.80::coor(2,1, 1); 0.10::coor(1,2, 1); 0.10::coor(2,3, 1) :- coor(2,2, 0), left.
0.80::coor(1,2, 1); 0.10::coor(2,1, 1); 0.10::coor(2,3, 1) :- coor(2,2, 0), up.
0.80::coor(2,2, 1); 0.10::coor(2,3, 1); 0.10::coor(2,1, 1) :- coor(2,2, 0), down.
1.00::coor(2,2, 1) :- coor(2,2, 0), stay.

