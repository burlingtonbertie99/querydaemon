
:-ensure_loaded(qserver).


:- dynamic last_run_date/1.

% Entry point for running as daemon
start_daemon :-
    % Redirect output to a log file
    %open('daemon.log', append, LogStream),
    %set_stream(user_output, LogStream),
    %set_stream(user_error, LogStream),
    % Optionally write a PID file
    %get_pid(PID),
    %open('daemon.pid', write, PIDStream),
    %format(PIDStream, '~w\n', [PID]),
    %close(PIDStream),
    % Run the worker loop
    load_last_run_date,
    loop.

% Main loop
loop :-
    get_time(Now),
    stamp_date_time(Now, DateTime, 'UTC'),
    date_time_value(date, DateTime, CurrentDate),
    ( should_run_today(CurrentDate) ->
        do_useful_work(Now),
        update_last_run_date(CurrentDate)
    ; true
    ),
	%12 hours
    sleep(43200),
    loop.

% Check if action should be run today
should_run_today(CurrentDate) :-
    ( last_run_date(LastDate) ->
        CurrentDate \= LastDate
    ; true
    ).

% Action to perform once daily
do_useful_work(Now) :-
    format_time(atom(TS), '%Y-%m-%d %H:%M:%S', Now),
    format('~w - hello~n', [TS]),
	
	
	test,
	
	
	
    flush_output.

% Update and save the run date
update_last_run_date(CurrentDate) :-
    retractall(last_run_date(_)),
    assertz(last_run_date(CurrentDate)),
    save_last_run_date.

% File persistence for last run date
load_last_run_date :-
    ( exists_file('last_run_date.db') ->
        consult('last_run_date.db')
    ; true
    ).

save_last_run_date :-
    open('last_run_date.db', write, Stream),
    last_run_date(Date),
    writeq(Stream, last_run_date(Date)),
    write(Stream, '.\n'),
    close(Stream).

% Get current process PID
get_pid(PID) :-
    current_prolog_flag(pid, PID).
