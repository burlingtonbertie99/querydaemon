
:- use_module(library(smtp)).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).

:- use_module(library(http/http_error)).
:- use_module(library(http/http_log)).


:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_ssl_plugin)).
:- use_module(library(http/json)).
:- use_module(library(http/json_convert)).

:-ensure_loaded(date_time).


%:-cd('P:/AllCode/prolog/queryserver').


schematests:-

   get_dict_from_json_file('taskobject.json', Dicty)

   ,write(Dicty)

   .


get_dict_from_json_file(FPath, Dicty) :-
  open(FPath, read, Stream), json_read_dict(Stream, Dicty), close(Stream).


:-dynamic today_is/1.

%article_as_body(ArticleAtom,Out):-


article_as_body(Input,Out):-


	catch(
	    (	set_stream(Out, encoding(utf8)),	format(Out,'~a',[Input]))

	     ,Error

	     ,(format(Out,'~a',[Error]))

	)


	. % article_as_body()




mailtest(Input):-


  catch(

    smtp_send_mail('cal@cryptomathic.com',


          article_as_body(Input),
                  %Goal,
				  

                  [


                    smtp('smtp.gmail.com')
                    ,header(from('Christian Adler, <christianadler101@gmail.com>'))


                    ,from('christianadler101@gmail.com')

                    ,auth('christianadler101'-'vcoqjmhlszhslkei')

                    ,auth_method(login)
                    ,subject('Your automatically-generated article')
                    ,security(tls)

%                  ,security(ssl)


                  ])




                ,_Error,false)

.











today_is(0).


:- http_handler(root(handle), handle_rpc, []).

%:-assert(http_json:json_type('application/json-rpc')).

%:-assert(http_json:json_type('application/json-rpc')).
%
http_json:json_type('application/json-rpc').

%http_json:json_type('text/xml').

% sample prolog program
f1(1).
f1(2).
f1(4).
f1(5).
f2(3).
f2(4).
f2(6).



%test(M):-getTasks(false,M), format(M).


test:-
	 format('Getting tasks... ~n')
	 ,getTasks(false,Work)
	 
	 
	 
	 ,getTasksPersonal(false,Personal)
	 %, format(M)
	 
	 ,atomic_list_concat(['Work priorities: ',Work,';   Personal priorities:  ',Personal], M)
	 
	 ,mailtest(M)
	 
	 .





getTasksPersonal(false,Message):-



   current_prolog_flag(ca101todoistkey,Key),

   %atom_json_term(D,json([model = Model, messages = [json([role = user, content = Prompt])] | Options]),[]),


   atom_json_term(D,json([sync_token="*", resource_types = ["all","-projects"] ]),[]),


   Data = atom(application/json, D),

%   http_post('https://api.openai.com/v1/chat/completions', Data, ReturnData,

    http_post('https://api.todoist.com/sync/v9/sync', Data, RawData,

            [authorization(bearer(Key)), application/json]

            ),


               % my_extract_data(RawData, [json(Message)])

               my_extract_data(RawData, Message)
/*

   (
      Raw = false
   -> (

	 %,member(content = Result, Message)


         )
   ;  Result = ReturnData
   )

              */
              .


my_extract_data(Data, Result):-

  /*
   %member(Group=Fieldlist, Data),
   gpt_extract_fields(Fieldname, Fieldlist, Result)

   */


	%json(Data)
	%nl,write('DATA is ...................'),nl,

	%nl,write(Data),nl,

	checkT(Data,ITEMS)


	,myfilter(ITEMS,[],CalculateList)



        %  myitem(InstaSign - key problem,json([date=2024-03-27,is_recurring= @(false),lang=en,string=Mar 27,timezone= @(null)]),4)
        ,findTopTask(CalculateList,0,'',FinalTask)
        ,FinalTask= myitem(CONTENT1,json([date=_DUE,_,_,string=DateString,_]),_)
%        , write('Most import task is: '), write(CONTENT1), write(',
%        Due: '), write(DateString),nl


        ,select(FinalTask,CalculateList,NextList),!


        ,findTopTask(NextList,0,'',NextTask)
      %  %, write('Next most import task is: '), write(NextTask),nl
        ,NextTask= myitem(CONTENT2,json([date=_DUE2,_,_,string=DateString2,_]),_)
       % , Write('Next most import task is: '), write(CONTENT2), write(', Due: '), write(DateString2),nl



%       ,atom_concat(CONTENT1,DateString,Result0)
 %      ,atom_concat(CONTENT2,Result0,Result1)
  %     ,atom_concat(DateString2,Result1,Result)

  ,atomic_list_concat([CONTENT1, ' Date due: ',DateString,CONTENT2, ' Date due: ',DateString2], ', ', Result)


   .

























% getTasks(Result):- gpt_completions(Model, Prompt, Result, false,
% Options),!.

getTasks(false,Message):-



   current_prolog_flag(todoistkey,Key),

   %atom_json_term(D,json([model = Model, messages = [json([role = user, content = Prompt])] | Options]),[]),


   atom_json_term(D,json([sync_token="*", resource_types = ["all","-projects"] ]),[]),


   Data = atom(application/json, D),

%   http_post('https://api.openai.com/v1/chat/completions', Data, ReturnData,

    http_post('https://api.todoist.com/sync/v9/sync', Data, RawData,

            [authorization(bearer(Key)), application/json]

            ),


               % my_extract_data(RawData, [json(Message)])

               my_extract_data(RawData, Message)
/*

   (
      Raw = false
   -> (

	 %,member(content = Result, Message)


         )
   ;  Result = ReturnData
   )

              */
              .


my_extract_dataXXXX(Data, Result):-

  /*
   %member(Group=Fieldlist, Data),
   gpt_extract_fields(Fieldname, Fieldlist, Result)

   */


	%json(Data)
	%nl,write('DATA is ...................'),nl,

	%nl,write(Data),nl,

	checkT(Data,ITEMS)


	,myfilter(ITEMS,[],CalculateList)



        %  myitem(InstaSign - key problem,json([date=2024-03-27,is_recurring= @(false),lang=en,string=Mar 27,timezone= @(null)]),4)
        ,findTopTask(CalculateList,0,'',FinalTask)
        ,FinalTask= myitem(CONTENT1,json([date=_DUE,_,_,string=DateString,_]),_)
%        , write('Most import task is: '), write(CONTENT1), write(',
%        Due: '), write(DateString),nl


        ,select(FinalTask,CalculateList,NextList),!


        ,findTopTask(NextList,0,'',NextTask)
      %  %, write('Next most import task is: '), write(NextTask),nl
        ,NextTask= myitem(CONTENT2,json([date=_DUE2,_,_,string=DateString2,_]),_)
       % , Write('Next most import task is: '), write(CONTENT2), write(', Due: '), write(DateString2),nl



%       ,atom_concat(CONTENT1,DateString,Result0)
 %      ,atom_concat(CONTENT2,Result0,Result1)
  %     ,atom_concat(DateString2,Result1,Result)

  ,atomic_list_concat([CONTENT1, ' Date due: ',DateString,CONTENT2, ' Date due: ',DateString2], ', ', Result)


   .




%findTopTask([],_,FinalTask,FinalTask):-!.
%
findTopTask([],_,FinalTask,FinalTask).

findTopTask([myitem(CONTENT,DUE,PRIORITY)|T],LastRating,OldTask,FinalTask):-


   findMultiplier(DUE,Multiplier)

   %,!


   ,Rating is PRIORITY * Multiplier


   ,(Rating > LastRating->(NewRating=Rating,NewTask=myitem(CONTENT,DUE,PRIORITY));(NewRating=LastRating,NewTask=OldTask))

   %comment out if you need to back-track over all solutions
   %,!

   ,findTopTask(T,NewRating,NewTask,FinalTask)


   .


findMultiplier(json([date=DateAtom,_,_,_,_]),Multiplier):-


   %'YYYY-MM-DD'


   atomic_list_concat(DateList, -, DateAtom),

   %DateList=[2024,5,1]
   DateList=[Y,M,D]

   ,atom_number(Y,YNo)   ,atom_number(M,MNo)   ,atom_number(D,DNo),

   call(today_is(Today))

   %,date_time_stamp(DateTime, Today)

   ,date_time_stamp(date(YNo,MNo,DNo,0,0,0,0,-,-), DueTime)


%   ,date_interval()
%
%   % 1 day = 86 400 seconds
%

   ,SecondsLeft is truncate(DueTime - Today)
%
%   ,SecondsLeft is (DueTime - Today)

   ,DaysLeft is truncate(div(SecondsLeft,86400))

%   ,nl,write(DaysLeft)

   ,((DaysLeft=<4)->Multiplier is 5 - DaysLeft;Multiplier is 1)


   % commit to this solution
   ,!


   .

findMultiplier(_,1).






myfilter([],CalculateList,CalculateList).


myfilter([H|T],Temp,CalculateList):-

	%nl,write(H),nl,

	H =


		json(

			[

			_,_,_,_,_,_,_,

			content=CONTENT,_,_,
			description=_DESCRIPTION,
			due=DUE,
			duration=_DURATION,
			_,_,_,_,_,
			priority=PRIORITY,
			_,_,_,_,_,_,_,_,_,_

			]

			)













                ,append([myitem(CONTENT,DUE,PRIORITY)],Temp,NewTemp)
%		,nl,write(CONTENT)

 %               ,nl,write(DUE)
	%	,nl,write(PRIORITY),nl
%

	,myfilter(T,NewTemp,CalculateList)
.



checkT(T,ITEMS):-


   T =

   json(
       [

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       items = ITEMS
	       ,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _,

       _

     ])



   .





% 1e9c117397f8d188a6865c34584319cc2aab6d45

init_todoistkey:-
  (
    getenv('TODOISTKEY',Key)
    ; (Key='b31489a4696cf6ad74d1896b6c47279a53b5b774')

  )
  
  ,(
    getenv('CA101TODOISTKEY',CA101Key)
    ; (CA101Key='1e9c117397f8d188a6865c34584319cc2aab6d45')

  )
  

  ,
   create_prolog_flag(todoistkey,Key,[type(atom)])
   
   ,create_prolog_flag(ca101todoistkey,CA101Key,[type(atom)])
   
   
   .


:-init_todoistkey.

%
%:-
%cd('P:/AllCode/prolog/queryserver').

server(Port) :-
http_server(http_dispatch, [port(Port)]).

handle_rpc(Request) :-

    % http_log(Request,[]),
    % http_log(JSONIn,[]),
    http_read_json(Request, JSONIn,[]),

    %http_read_json(Request, JSONIn),
     json_to_prolog(JSONIn, PrologIn),

     (   (
     evaluate(PrologIn, PrologOut), % application body
     PrologOut = JSONOut,
     reply_json(JSONOut)

     )
     ;

     ( reply_json(json(logic_error_innit))  )

     )

     .

evaluate(PrologIn, PrologOut) :-

 % init_todoistkey,



    (

    %PrologIn = json([jsonrpc=Version, params=[Query], id=Id, method=_MethodName])

    %;

    % Query = ['f1(R), f2(S)']
    PrologIn= json([id=Id,method=_MethodName,params=_Query,jsonrpc=Version])

    )
    ,
%     nl,write(Query),nl,
    % MethodName = eval

%     ,atom_codes(Query,QueryCodes)
 %    ,atom_to_term(QueryCodes, Term, Bindings),
  %   Goal =.. [findall, Bindings, Term, IR],
   %  call(Goal),
    % sort(IR, Result),

   % call(f1(Result))

    call(getTasks(_,Term))

    ,format(atom(StringResult), "~q", [Term]),
     PrologOut = json([jsonrpc=Version, result=StringResult, id=Id])


     .










































