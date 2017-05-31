:- module(spelling, [correction/2]).

splitWords(Text, Words) :- splitRegex("\w+", Text, Words).

vocab(V) :-
    readText("big.txt", Text),
    splitWords(Text, V).

probability(Word, N, P) :-
    vocab(V),
    lookup(V, Word, W),
    P is W/N.

correction(Word, NewWord) :-
    candidates(Word, Words),
    max(Words, NewWord).

candidates(Word, Words) :- known([Word], Words).
candidates(Word, Words) :- edits1(Word, EditWords), known(EditWords, Words).
candidates(Word, Words) :- edits2(Word, EditWords), known(EditWords, Words).
candidates(Word, [Word]).

unique(Xs, Ys) :-
    nth0(_, Ys, Xs, X),
    \+ member(Xs, X).

known(Words, NewWords) :-
    vocab(V),
    filter(containsp(V), Words, Words2),
    unique(Words2, NewWords).

edits1(Word, Words) :-
    Letters    is "abcdefghijklmnopqrstuvwxyz",
    Splits     is [(word[:I], word[I:])      for I in range(len(Word) + 1)],
    Deletes    is [L + R[1:]                 for L, R in Splits if R],
    Transposes is [L + R[1] + R[0] + R[2:]   for L, R in Splits if len(R) > 1],
    Replaces   is [L + C + R[1:]             for L, R in Splits if R for C in Letters],
    Inserts    is [L + C + R                 for L, R in Splits for C in Letters],
    concat([Deletes, Transposes, Replaces, Inserts], DupWords),
    unique(DupWords, Words).

edits2(Word, Words) :-
    edits1(Word, Words1),
    edits2(Words1, Words2),
    flatten(Words2, Words).
