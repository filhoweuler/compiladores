
(* The type of tokens. *)

type token = 
  | WHILE of (Lexing.position)
  | VIRG of (Lexing.position)
  | SUBATRIB of (Lexing.position)
  | STRING of (Lexing.position)
  | SOMAATRIB of (Lexing.position)
  | SETA of (Lexing.position)
  | RETURN of (Lexing.position)
  | RANGE of (Lexing.position)
  | PRINT of (Lexing.position)
  | OULOG of (Lexing.position)
  | NOVALINHA
  | NONE of (Lexing.position)
  | NAO of (Lexing.position)
  | MULATRIB of (Lexing.position)
  | MUL of (Lexing.position)
  | MODATRIB of (Lexing.position)
  | MOD of (Lexing.position)
  | MENOS of (Lexing.position)
  | MENORIGUAL of (Lexing.position)
  | MENOR of (Lexing.position)
  | MAIS of (Lexing.position)
  | MAIORIGUAL of (Lexing.position)
  | MAIOR of (Lexing.position)
  | Linha of (int * int * token list)
  | LITSTRING of (string * Lexing.position)
  | LITINT of (int * Lexing.position)
  | LITFLOAT of (float * Lexing.position)
  | LITCHAR of (char * Lexing.position)
  | LITBOOL of (bool * Lexing.position)
  | INPUTS of (Lexing.position)
  | INPUTI of (Lexing.position)
  | INPUTF of (Lexing.position)
  | INPUTC of (Lexing.position)
  | INDENTA
  | IN of (Lexing.position)
  | IGUAL of (Lexing.position)
  | IF of (Lexing.position)
  | ID of (string * Lexing.position)
  | I32 of (Lexing.position)
  | FPAR of (Lexing.position)
  | FOR of (Lexing.position)
  | F32 of (Lexing.position)
  | EOF
  | ELSE of (Lexing.position)
  | ELOG of (Lexing.position)
  | ELIF of (Lexing.position)
  | DPTOS of (Lexing.position)
  | DIVATRIB of (Lexing.position)
  | DIV of (Lexing.position)
  | DIFERENTE of (Lexing.position)
  | DEF of (Lexing.position)
  | DEDENTA
  | CHAR of (Lexing.position)
  | BOOL of (Lexing.position)
  | ATRIB of (Lexing.position)
  | APAR of (Lexing.position)

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val programa: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Sast.expressao Ast.programa)

module MenhirInterpreter : sig
  
  (* The incremental API. *)
  
  include MenhirLib.IncrementalEngine.INCREMENTAL_ENGINE
    with type token = token
  
end

(* The entry point(s) to the incremental API. *)

module Incremental : sig
  
  val programa: Lexing.position -> (Sast.expressao Ast.programa) MenhirInterpreter.checkpoint
  
end
