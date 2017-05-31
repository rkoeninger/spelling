:- module(spelling, [correction/2]).

splitWords(Text, Words) :- splitRegex("\w+", Text, Words).

vocab(V) :-
    readText("big.txt", Text),
    splitWords(Text, V).

probability(Word, N, P) :-
    vocab(V),
    lookup(V, Word, W),
    div(W, N, P).

correction(Word, NewWord) :-
    candidates(Word, Words),
    max(Words, NewWord).

candidates(Word, Words) :- known([Word], Words).
candidates(Word, Words) :- edits1(Word, EditWords), known(EditWords, Words).
candidates(Word, Words) :- edits2(Word, EditWords), known(EditWords, Words).
candidates(Word, [Word]) :- !.

known(Words, NewWords) :-
    vocab(V),
    filter(lambda W: W in V, Words, Words2),
    distinct(Words2, NewWords).

edits1(Word, Words) :-
    Letters    = "abcdefghijklmnopqrstuvwxyz",
    Splits     = [(word[:I], word[I:])      for I in range(len(Word) + 1)],
    Deletes    = [L + R[1:]                 for L, R in Splits if R],
    Transposes = [L + R[1] + R[0] + R[2:]   for L, R in Splits if len(R) > 1],
    Replaces   = [L + C + R[1:]             for L, R in Splits if R for C in Letters],
    Inserts    = [L + C + R                 for L, R in Splits for C in Letters],
    concat([Deletes, Transposes, Replaces, Inserts], DupWords),
    distinct(DupWords, Words).

edits2(Word, Words) :-
    edits1(Word, Words1),
    edits2(Words1, Words2),
    flatten(Words2, Words).
