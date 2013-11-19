%-*-Mode:erlang;coding:utf-8;tab-width:4;c-basic-offset:4;indent-tabs-mode:()-*-
% ex: set ft=erlang fenc=utf-8 sts=4 ts=4 sw=4 et:
%%%
%%%------------------------------------------------------------------------
%%% @doc
%%% ==Service Behaviour==
%%% A minimal behaviour for creating CloudI internal services.
%%% @end
%%%
%%% BSD LICENSE
%%% 
%%% Copyright (c) 2013, Michael Truog <mjtruog at gmail dot com>
%%% All rights reserved.
%%% 
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%% 
%%%     * Redistributions of source code must retain the above copyright
%%%       notice, this list of conditions and the following disclaimer.
%%%     * Redistributions in binary form must reproduce the above copyright
%%%       notice, this list of conditions and the following disclaimer in
%%%       the documentation and/or other materials provided with the
%%%       distribution.
%%%     * All advertising materials mentioning features or use of this
%%%       software must display the following acknowledgment:
%%%         This product includes software developed by Michael Truog
%%%     * The name of the author may not be used to endorse or promote
%%%       products derived from this software without specific prior
%%%       written permission
%%% 
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
%%% CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
%%% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
%%% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
%%% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%%% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
%%% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%%% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
%%% DAMAGE.
%%%
%%% @author Michael Truog <mjtruog [at] gmail (dot) com>
%%% @copyright 2013 Michael Truog
%%% @version 1.3.1 {@date} {@time}
%%%------------------------------------------------------------------------

-module(service).
-author('mjtruog [at] gmail (dot) com').

%% behavior interface
-export([add/1,
         add/2,
         remove/1,
         remove/2]).

-include("service_req.hrl").

-type service_req() :: #service_req{}.
-export_type([service_req/0]).

%%%------------------------------------------------------------------------
%%% Callback functions from behavior
%%%------------------------------------------------------------------------

-callback service_config() ->
    cloudi_service_api:service_internal() |
    cloudi_service_api:service_proplist().

-callback service_init(Args :: list(),
                       Prefix :: cloudi_service:service_name_pattern(),
                       Dispatcher :: cloudi_service:dispatcher()) ->
    {'ok', State :: any()} |
    {'stop', Reason :: any()} |
    {'stop', Reason :: any(), State :: any()}.

-callback service_request(ServiceReq :: service_req(),
                          State :: any(),
                          Dispatcher :: cloudi_service:dispatcher()) ->
    {'reply', Response :: cloudi_service:response(), NewState :: any()} |
    {'reply', ResponseInfo :: cloudi_service:response_info(),
     Response :: cloudi_service:response(), NewState :: any()} |
    {'forward', NextServiceReq :: service_req(),
     NewState :: any()} |
    {'noreply', NewState :: any()} |
    {'stop', Reason :: any(), NewState :: any()}.

-callback service_info(Request :: any(),
                       State :: any(),
                       Dispatcher :: cloudi_service:dispatcher()) ->
    {'noreply', NewState :: any()} |
    {'stop', Reason :: any(), NewState :: any()}.

-callback service_terminate(Reason :: any(),
                            State :: any()) ->
    'ok'.

%%%------------------------------------------------------------------------
%%% Behavior interface functions
%%%------------------------------------------------------------------------

-spec add(Module :: module()) ->
    {ok, ServiceId :: cloudi_service_api:service_id()} |
    {error, any()}.

add(Module)
    when is_atom(Module) ->
    case cloudi_service_api:services_add([Module:service_config()],
                                         infinity) of
        {ok, [ServiceId]} ->
            {ok, ServiceId};
        {error, _} = Error ->
            Error
    end.

-spec add(Module :: module(),
          Timeout :: cloudi_service_api:timeout_milliseconds() | infinity) ->
    {ok, ServiceId :: cloudi_service_api:service_id()} |
    {error, any()}.

add(Module, Timeout)
    when is_atom(Module) ->
    case cloudi_service_api:services_add([Module:service_config()],
                                         Timeout) of
        {ok, [ServiceId]} ->
            {ok, ServiceId};
        {error, _} = Error ->
            Error
    end.

-spec remove(ServiceId :: cloudi_service_api:service_id()) ->
    ok |
    {error, any()}.

remove(ServiceId)
    when is_binary(ServiceId), byte_size(ServiceId) == 16 ->
    cloudi_service_api:services_remove([ServiceId], infinity).

-spec remove(ServiceId :: cloudi_service_api:service_id(),
             Timeout :: cloudi_service_api:timeout_milliseconds() | infinity) ->
    ok |
    {error, any()}.

remove(ServiceId, Timeout)
    when is_binary(ServiceId), byte_size(ServiceId) == 16 ->
    cloudi_service_api:services_remove([ServiceId], Timeout).

