
:- lib(ic).
:- lib(ic_cumulative).



proj(FileDados) :- 
     compile(FileDados),
     findall(I,tarefa(I,_,_,_),Nos),
     length(Nos,N),
     length(ES,N),
     zip(Nos,ES,Eventos),
     maxDuracao(Nos,MaxDuracao),
     [DurMin|ES] #:: 0..MaxDuracao,
     prec_constrs(Nos,Eventos,DurMin),
     % obtém a duração mínima do projeto 
     get_min(DurMin,DurMin),
     writeln("Duração mínima do projeto" : DurMin),
     numTrab(Eventos,Criticas),!,
     numTrabCriticas(Eventos,Criticas).


% soma da duração das tarefas
maxDuracao([],0).
maxDuracao([I|RNos],MaxDuracao) :-
     tarefa(I,_,Di,_),
     maxDuracao(RNos, Soma), MaxDuracao is Soma+Di.

% cria uma lista de tuplos evento(IdTarefa,EStarefa) para cada tarefa com o se earliest start
zip([],[],[]).
zip([I|Nos], [ESi|ES], [evento(I,ESi)|REventos]) :-
     zip(Nos,ES,REventos).

% restringe o valor que a duração do projeto pode tomar e que o earliest start de cada tarefa pode ser
prec_constrs([],_,_).
prec_constrs([I|RNos],Eventos,DurMin) :-
     getES(I,Eventos,evento(I,ESi)),
     tarefa(I,LTSegs,Di,_),
     prec_constrs_(LTSegs,Eventos,ESi,Di),
     ESi+Di #=< DurMin,
     prec_constrs(RNos,Eventos,DurMin).

prec_constrs_([],_,_,_).
prec_constrs_([J|RTSegs],Eventos,ESi,Di) :-
     getES(J,Eventos,evento(J,ESj)),
     ESi+Di #=< ESj,
     prec_constrs_(RTSegs,Eventos,ESi,Di).

% retira da lista de tuplos evento(Id,ES) o earliest start de cada tarefa
getES(_,[],_).
getES(I,[evento(I,ESi)|_],evento(I,ESi)) :- !.
getES(I,[_|R],X) :-
     getES(I,R,X).

% número de trabalhadores a contratar
numTrab(Eventos,Criticas) :-
     % calcula as atividades críticas para usar no predicado numTrabCriticas
     getAtCriticas(Eventos,Criticas),
     getData(Eventos),
     getDatas(Eventos,Datas),
     getDuracoes(Eventos,Duracoes),
     getTrabalhadores(Eventos,Trabalhadores),
     cumulative(Datas,Duracoes,Trabalhadores, MinTrabalhadores),
     % determina o mínimo de trabalhadores a contratar
     get_min(MinTrabalhadores,MinTrabalhadores),
     writeln("Número mínimo de trabalhadores a contratar" : MinTrabalhadores).

% número de trabalhadores para as atividades críticas
numTrabCriticas(Eventos,Criticas) :-
     getDatas(Criticas,Datas),
     getDuracoes(Criticas,Dur),
     getTrabalhadores(Criticas,Trab),
     cumulative(Datas,Dur,Trab,Min),
     % determina o mínimo de trabalhadores a contratar
     get_min(Min,Min),
     writeln("Número mínimo de trabalhadores para as atividades críticas" : Min).

% cria lista de tuplos evento(Id,ES) só para as atividades críticas
getAtCriticas([],[]).
getAtCriticas([evento(I,ESi)|REventos],[evento(I,ESi)|RCriticas]) :-
     % arranja a atividade que só pode ter uma data de início mais próxima -> atividade crítica
     get_domain_size(ESi,1),
     getAtCriticas(REventos,RCriticas).
getAtCriticas([_|REventos],Criticas) :-
     getAtCriticas(REventos,Criticas).

% arranja o earliest start de cada tarefa da lista de datas que cada tarefa pode tomar
getData([]).
getData([evento(_,ES)|REventos]) :-
     get_min(ES,ES),
     getData(REventos).

% cria lista com os earliest starts de todas as tarefas
getDatas([],[]).
getDatas([evento(I,ESi)|REventos],[ESi|RESs]) :-
     getDatas(REventos,RESs).

% cria lista com as durações de todas as tarefas
getDuracoes([],[]).
getDuracoes([evento(I,_)|REventos],[Di|RDur]) :-
     tarefa(I,_,Di,_),
     getDuracoes(REventos,RDur).

% cria lista com os trabalhadores de todas as tarefas
getTrabalhadores([],[]).
getTrabalhadores([evento(I,_)|REventos],[Ti|RTrab]) :-
     tarefa(I,_,_,Ti),
     getTrabalhadores(REventos,RTrab).
