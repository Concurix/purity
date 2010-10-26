-module(higher).
-compile(export_all).

%%% Test various aspects of higher order functions. %%%

%% Some simple preliminary cases, which should be easily resolvable
%% with call site analysis. The b/c functions should be equivalent.

%< a/3 [{arg,1}]
a(F, A1, A2) ->
    F(A1, A2).

%< b/0 true
b() ->
    a(fun erlang:'+'/2, 40, 2).

%< c/0 true
c() ->
    apply(fun erlang:'+'/2, [40, 2]).


%% Try a user defined function instead of a built-in.
%< d/2 true
d(X, Y) ->
    X + Y.

%< e/0 true
e() ->
    a(fun d/2, 40, 2).


%% Some edge cases of call site analysis:
%% Higher order recursive functions may potentially call themselves with
%% concrete arguments at some point. This creates two distinct problems:
%% Pure calls should be correctly detected and removed (requires extra
%% checks at call site), while impure ones should be propagated as usual.
%% Either way, this signifies the importance of tracking *recursive* calls,
%% since we could miss out on these impurities and incorrectly mark
%% certain functions as pure.

%% This is somewhat contrived, but for a real life example look at
%% `dets_utils:leafs_to_nodes/4'.
%< f/2 [{arg,1}]
f(_F, none) ->
    f(fun erlang:abs/1, 21);
f(F, N) when is_integer(N) ->
    F(N) * 2.

%< g/2 {false,"call to impure higher:g/2"}
g(_F, none) ->
    g(fun erlang:put/2, 21);
g(F, Val) ->
    F(key, 2 * Val).

%< h/0 true
h() ->
    f(fun erlang:abs/1, 21).

%< i/0 {false,"call to impure higher:g/2"}
i() ->
    g(fun d/2, 42).

%% Recursive HOFs present another challenge as it is possible that
%% they recursive call contains some unknown function. Usually however
%% this unknown function is the same one which characterised the function
%% as higher order (e.g. one of its arguments). We try to detect some
%% of these cases.
%< j/2 [{arg,1}]
j(F, [H|T]) ->
    [F(H)|j(F, T)];
j(_, []) ->
    [].

%< k/3 [{arg,1},{arg,2}]
k(F, G, [H|T]) ->
    [G(F(H))|k(F, G, T)];
k(_, _, []) ->
    [].

%% Variation of the previous example, with the higher order arguments
%% being transposed.
%< l/3 [{arg,1},{arg,2}]
l(F, G, [H|T]) ->
    [G(F(H))|l(G, F, T)];
l(_, _, []) ->
    [].

%% Example of an unresolvable unknown function (an element of the list).
%< m/2 [{arg,1},{local,{higher,m,2},[]}]
m(F, [G,E|T]) ->
    [F(E)|m(G, T)];
m(_, []) ->
    [].

