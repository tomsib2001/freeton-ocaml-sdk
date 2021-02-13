(**************************************************************************)
(*                                                                        *)
(*  Copyright (c) 2021 OCamlPro SAS & Origin Labs SAS                     *)
(*                                                                        *)
(*  All rights reserved.                                                  *)
(*  This file is distributed under the terms of the GNU Lesser General    *)
(*  Public License version 2.1, with the special exception on linking     *)
(*  described in the LICENSE.md file in the root directory.               *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

open Ezcmd.V2
open EZCMD.TYPES
open Types

let action name contract create =
  let config = Config.config () in
  let net = Config.current_network config in
  match name with
  | None -> Error.raise "Name of key must be provided"
  | Some name ->
      let rec iter create =
        match Config.find_key net name with
        | None ->
            if create then begin
              CommandAccount.genkey config ( Some name );
              iter false
            end
            else
              Error.raise "No key %S in network %S" name net.net_name
        | Some key ->
            if create then
              Error.raise "Key %S alreay exists and cannot be created" name;
            CommandAccount.genaddr config contract key

      in
      iter create

let cmd =
  let name = ref None in
  let contract = ref "SafeMultisigWallet" in
  let create = ref false in
  EZCMD.sub
    "genaddr"
    (fun () -> action !name !contract !create)
    ~args:
      [ [],
        Arg.Anon (0, fun s -> name := Some s),
        EZCMD.info "Name of key" ;
        [ "--contract" ],
        Arg.String (fun s -> contract := s),
        EZCMD.info "Name of contract" ;
        [ "--create" ],
        Arg.Set create,
        EZCMD.info "Create new key";
      ]
    ~doc: "Generate new addr (default is for a SafeMultisigWallet, use 'ft list' for more)"
