(* Auto-generated from "protocol.atd" *)


type node = {
  key: string;
  createdIndex: int;
  modifiedIndex: int;
  expiration: string option;
  value: string option;
  dir: bool option;
  nodes: node list option
}

type response = { action: string; node: node; prevNode: node option }

type error = { errorCode: int; message: string; cause: string; index: int }

val write_node :
  Bi_outbuf.t -> node -> unit
  (** Output a JSON value of type {!node}. *)

val string_of_node :
  ?len:int -> node -> string
  (** Serialize a value of type {!node}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_node :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> node
  (** Input JSON data of type {!node}. *)

val node_of_string :
  string -> node
  (** Deserialize JSON data of type {!node}. *)

val create_node :
  key: string ->
  createdIndex: int ->
  modifiedIndex: int ->
  ?expiration: string ->
  ?value: string ->
  ?dir: bool ->
  ?nodes: node list ->
  unit -> node
  (** Create a record of type {!node}. *)


val write_response :
  Bi_outbuf.t -> response -> unit
  (** Output a JSON value of type {!response}. *)

val string_of_response :
  ?len:int -> response -> string
  (** Serialize a value of type {!response}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_response :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> response
  (** Input JSON data of type {!response}. *)

val response_of_string :
  string -> response
  (** Deserialize JSON data of type {!response}. *)

val create_response :
  action: string ->
  node: node ->
  ?prevNode: node ->
  unit -> response
  (** Create a record of type {!response}. *)


val write_error :
  Bi_outbuf.t -> error -> unit
  (** Output a JSON value of type {!error}. *)

val string_of_error :
  ?len:int -> error -> string
  (** Serialize a value of type {!error}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_error :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> error
  (** Input JSON data of type {!error}. *)

val error_of_string :
  string -> error
  (** Deserialize JSON data of type {!error}. *)

val create_error :
  errorCode: int ->
  message: string ->
  cause: string ->
  index: int ->
  unit -> error
  (** Create a record of type {!error}. *)


