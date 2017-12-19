{
    open Sintatico
    open Lexing
    open Printf

    exception Erro of string

    let nivel_par = ref 0

    let incr_num_linha lexbuf =
        let pos = lexbuf.lex_curr_p in
            lexbuf.lex_curr_p <- { pos with
            pos_lnum = pos.pos_lnum + 1;
            pos_bol = pos.pos_cnum;
        }

    (*let msg_erro lexbuf c =
        let pos = lexbuf.lex_curr_p in
        let lin = pos.pos_lnum
        and col = pos.pos_cnum - pos.pos_bol - 1 in
        sprintf "%d-%d: caracter desconhecido %c" lin col c
*)
    let pos_atual lexbuf = lexbuf.lex_start_p

}

let digito  = ['0' - '9']
let inteiro = digito+
let frac    = '.'digito*
let exp     = ['e' 'E']['-' '+']?digito+
let float   = digito* frac exp?
let restante   = [^ ' ' '\t' '\n' ] [^ '\n']+
let brancos    = [' ' '\t']+
let novalinha  = '\r' | '\n' | "\r\n"
let comentario = "#"[ ^ '\n' ]*
let linha_em_branco = [' ' '\t' ]* comentario
let letra = [ 'a'-'z' 'A' - 'Z']
let identificador = letra(letra|digito|'_')*

rule preprocessador indentacao = parse
  linha_em_branco         { preprocessador 0 lexbuf }
| [' ' '\t' ]+ '\n'       { incr_num_linha lexbuf; preprocessador 0 lexbuf }
| ' '                     { preprocessador (indentacao + 1) lexbuf }
| '\t'                    { let nova_ind = indentacao + 8 - (indentacao mod 8) in preprocessador nova_ind lexbuf }
| novalinha               { incr_num_linha lexbuf; preprocessador 0 lexbuf }
| restante as linha {
                        let rec tokenize lexbuf =
                            let tok = token lexbuf in
                    	       match tok with
                    	        EOF -> []
                    	       | _  -> tok :: tokenize lexbuf in
                                    let toks = tokenize (Lexing.from_string linha) in
                                        Linha(indentacao,!nivel_par, toks)
                    }
| eof { nivel_par := 0; EOF }

and token = parse
  brancos            { token lexbuf }
| comentario         { token lexbuf }
| "\"\"\""           { comentario_bloco 0 lexbuf }
| '('                { incr(nivel_par); APAR (pos_atual lexbuf)}
| ')'                { decr(nivel_par); FPAR (pos_atual lexbuf)}
| "->"               { SETA       (pos_atual lexbuf)}
| "+="               { SOMAATRIB  (pos_atual lexbuf)} 
| "-="               { SUBATRIB   (pos_atual lexbuf)} 
| "*="               { MULATRIB   (pos_atual lexbuf)} 
| "/="               { DIVATRIB   (pos_atual lexbuf)} 
| "%="               { MODATRIB   (pos_atual lexbuf)} 
| "<="               { MENORIGUAL (pos_atual lexbuf)}
| ">="               { MAIORIGUAL (pos_atual lexbuf)}
| "=="               { IGUAL      (pos_atual lexbuf)}
| "!="               { DIFERENTE  (pos_atual lexbuf)}
| ','                { VIRG   (pos_atual lexbuf)}
| ':'                { DPTOS  (pos_atual lexbuf)}
| '+'                { MAIS   (pos_atual lexbuf)}
| '-'                { MENOS  (pos_atual lexbuf)}
| '*'                { MUL    (pos_atual lexbuf)}
| '/'                { DIV    (pos_atual lexbuf)}
| '%'                { MOD    (pos_atual lexbuf)}
| '<'                { MENOR  (pos_atual lexbuf)}
| '>'                { MAIOR  (pos_atual lexbuf)}
| '='                { ATRIB  (pos_atual lexbuf)}
| "not"              { NAO    (pos_atual lexbuf)}
| "and"              { ELOG   (pos_atual lexbuf)}
| "or"               { OULOG  (pos_atual lexbuf)}
| "def"              { DEF    (pos_atual lexbuf)}
| "return"           { RETURN (pos_atual lexbuf)}
| "while"            { WHILE  (pos_atual lexbuf)}
| "for"              { FOR    (pos_atual lexbuf)}
| "in"               { IN     (pos_atual lexbuf)}
| "range"            { RANGE  (pos_atual lexbuf)}
| "inputi"           { INPUTI (pos_atual lexbuf)}
| "inputf"           { INPUTF (pos_atual lexbuf)}
| "inputc"           { INPUTC (pos_atual lexbuf)}
| "inputs"           { INPUTS (pos_atual lexbuf)}
| "print"            { PRINT  (pos_atual lexbuf)}
| "str"              { STRING (pos_atual lexbuf)}
| "int"              { I32    (pos_atual lexbuf)}
| "bool"             { BOOL   (pos_atual lexbuf)}
| "char"             { CHAR   (pos_atual lexbuf)}
| "float"            { F32    (pos_atual lexbuf)}
| "None"             { NONE   (pos_atual lexbuf)}
| "if"               { IF     (pos_atual lexbuf)}
| "elif"             { ELIF   (pos_atual lexbuf)}
| "else"             { ELSE   (pos_atual lexbuf)}
| "True"             { LITBOOL(true,pos_atual lexbuf)}
| "False"            { LITBOOL(false,pos_atual lexbuf)}
| "'"_"'" as s       { let c = String.get s 1 in LITCHAR (c,pos_atual lexbuf) }
| inteiro as num     { let numero = int_of_string num   in LITINT   (numero,pos_atual lexbuf) }
| float as num       { let numero = float_of_string num in LITFLOAT (numero,pos_atual lexbuf) }
| '"'                { let buffer = Buffer.create 1 in 
                        let str = leia_string buffer lexbuf in 
                            LITSTRING (str, pos_atual lexbuf) }
| identificador as id{ ID (id, pos_atual lexbuf) }
| _                  { raise ( Erro ("Caracter desconhecido: " ^ Lexing.lexeme lexbuf)) }
| eof                { EOF     }

and comentario_bloco n = parse
    "\"\"\""{ token lexbuf                      }
    | _     { comentario_bloco n lexbuf         }
    | eof   { raise (Erro "Comentário não terminado") }
and leia_string buffer = parse
    | '"'       { Buffer.contents buffer }
    | "\\t"     { Buffer.add_char buffer '\t'; leia_string buffer lexbuf }
    | "\\n"     { Buffer.add_char buffer '\n'; leia_string buffer lexbuf }
    | '\\' '"'  { Buffer.add_char buffer '"'; leia_string buffer lexbuf  }
    | '\\' '\\' { Buffer.add_char buffer '\\'; leia_string buffer lexbuf }
    | _ as c    { Buffer.add_char buffer c; leia_string buffer lexbuf    }
    | eof       { raise (Erro "A string não foi fechada.") }
