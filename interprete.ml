module Amb = AmbInterp
module A = Ast
module S = Sast
module T = Tast

exception Valor_de_retorno of T.expressao

let obtem_nome_tipo_var exp = let open T in
  match exp with
    | ExpVar (nome,tipo) -> (nome,tipo)
    | _                  -> failwith "obtem_nome_tipo_var1: nao eh variavel"

let pega_int exp = match exp with
  | T.ExpInt (i,_)  -> i
  | _               -> failwith "pega_int: nao eh inteiro"

let pega_float exp = match exp with
  | T.ExpFloat (f,_)-> f
  | _               -> failwith "pega_float: nao eh inteiro"

let pega_char exp = match exp with
  | T.ExpChar (c,_) -> c
  | _               -> failwith "pega_char: nao eh inteiro"

let pega_str exp = match exp with
  | T.ExpStr (s,_)  -> s
  | _               -> failwith "pega_string: nao eh string"

let pega_bool exp = match exp with
  | T.ExpBool (b,_) -> b
  | _               -> failwith "pega_bool: nao eh booleano"

type classe_op = Aritmetico | Relacional | Logico

let classifica op = let open A in
  match op with
  | Mais
  | Menos
  | Mul
  | Div
  | Mod       -> Aritmetico
  | Maior
  | Menor
  | MaiorIgual
  | MenorIgual
  | Igual
  | Difer     ->Relacional
  | Elog
  | Oulog
  | Not       -> Logico

let rec interpreta_exp amb exp = 
  let open A in
  let open T in
    match exp with
    | ExpInt   _
    | ExpStr   _
    | ExpChar  _
    | ExpBool  _
    | ExpFloat _ -> exp
    | ExpVar (nome, tipo) ->
      (match (Amb.busca amb nome) with
        | Amb.EntVar (_, v) ->
          (match v with
            | Some valor -> valor
            | None       -> failwith "variável nao inicializada: "
          )
        |  _ -> failwith "interpreta_exp: expvar"
      )
    | ExpOperB ((op, top), (esq, tesq), (dir, tdir)) ->
      let vesq = interpreta_exp amb esq
      and vdir = interpreta_exp amb dir in
      let interpreta_aritmetico () =
        (match top with
          | TipoInt ->
            (match op with
              | Mais  -> ExpInt (pega_int vesq +   pega_int vdir, top)
              | Menos -> ExpInt (pega_int vesq -   pega_int vdir, top)
              | Mul   -> ExpInt (pega_int vesq *   pega_int vdir, top)
              | Div   -> ExpInt (pega_int vesq /   pega_int vdir, top)
              | Mod   -> ExpInt (pega_int vesq mod pega_int vdir, top)
              | _     -> failwith "interpreta_aritmetico"
            )
          | TipoFloat ->
            (match op with
              | Mais  -> ExpFloat (pega_float vesq +. pega_float vdir, top)
              | Menos -> ExpFloat (pega_float vesq -. pega_float vdir, top)
              | Mul   -> ExpFloat (pega_float vesq *. pega_float vdir, top)
              | Div   -> ExpFloat (pega_float vesq /. pega_float vdir, top)
              | _     -> failwith "interpreta_aritmetico"
            )
          | _ -> failwith "interpreta_aritmetico"
        )
      and interpreta_relacional () =
        (match tesq with
          | TipoInt ->
            (match op with
              | Menor      -> ExpBool (pega_int vesq <  pega_int vdir, top)
              | Maior      -> ExpBool (pega_int vesq >  pega_int vdir, top)
              | MaiorIgual -> ExpBool (pega_int vesq >= pega_int vdir, top)
              | MenorIgual -> ExpBool (pega_int vesq <= pega_int vdir, top)
              | Igual      -> ExpBool (pega_int vesq == pega_int vdir, top)
              | Difer      -> ExpBool (pega_int vesq != pega_int vdir, top)
              | _          -> failwith "interpreta_relacional"
            )
          | TipoStr ->
            (match op with
              | Menor      -> ExpBool (pega_str vesq <  pega_str vdir, top)
              | Maior      -> ExpBool (pega_str vesq >  pega_str vdir, top)
              | MaiorIgual -> ExpBool (pega_str vesq >= pega_str vdir, top)
              | MenorIgual -> ExpBool (pega_str vesq <= pega_str vdir, top)
              | Igual      -> ExpBool (pega_str vesq == pega_str vdir, top)
              | Difer      -> ExpBool (pega_str vesq != pega_str vdir, top)
              | _          -> failwith "interpreta_relacional"
            )
          | TipoChar ->
            (match op with
              | Menor      -> ExpBool (pega_char vesq <  pega_char vdir, top)
              | Maior      -> ExpBool (pega_char vesq >  pega_char vdir, top)
              | MaiorIgual -> ExpBool (pega_char vesq >= pega_char vdir, top)
              | MenorIgual -> ExpBool (pega_char vesq <= pega_char vdir, top)
              | Igual      -> ExpBool (pega_char vesq == pega_char vdir, top)
              | Difer      -> ExpBool (pega_char vesq != pega_char vdir, top)
              | _          -> failwith "interpreta_relacional"
            )
          | TipoBool ->
            (match op with
              | Menor      -> ExpBool (pega_bool vesq <  pega_bool vdir, top)
              | Maior      -> ExpBool (pega_bool vesq >  pega_bool vdir, top)
              | MaiorIgual -> ExpBool (pega_bool vesq >= pega_bool vdir, top)
              | MenorIgual -> ExpBool (pega_bool vesq <= pega_bool vdir, top)
              | Igual      -> ExpBool (pega_bool vesq == pega_bool vdir, top)
              | Difer      -> ExpBool (pega_bool vesq != pega_bool vdir, top)
              | _          -> failwith "interpreta_relacional"
            )
          | TipoFloat ->
            (match op with
              | Menor      -> ExpBool (pega_float vesq <  pega_float vdir, top)
              | Maior      -> ExpBool (pega_float vesq >  pega_float vdir, top)
              | MaiorIgual -> ExpBool (pega_float vesq == pega_float vdir, top)
              | MenorIgual -> ExpBool (pega_float vesq == pega_float vdir, top)
              | Igual      -> ExpBool (pega_float vesq == pega_float vdir, top)
              | Difer      -> ExpBool (pega_float vesq != pega_float vdir, top)
              | _          -> failwith "interpreta_relacional"
            )
          | _ ->  failwith "interpreta_relacional"
        )
      and interpreta_logico () =
        (match tesq with
          | TipoBool  ->
            (match op with
              | Oulog -> ExpBool (pega_bool vesq || pega_bool vdir, top)
              | Elog  -> ExpBool (pega_bool vesq && pega_bool vdir, top)
              | _     ->  failwith "interpreta_logico"
            )
          | _         ->  failwith "interpreta_logico"
        )
      in
      let valor = 
        (match (classifica op) with
          | Aritmetico -> interpreta_aritmetico ()
          | Relacional -> interpreta_relacional ()
          | Logico     -> interpreta_logico ()
        )
      in valor
    | ExpOperU ((op, top), (exp, texp)) ->
      let vexp = interpreta_exp amb exp in
      let interpreta_not () = 
       (match texp with
        | A.TipoBool -> ExpBool (not (pega_bool vexp), top)
        | _          -> failwith "Operador unario indefinido")
      and interpreta_negativo () = 
       (match texp with
        | A.TipoInt   -> ExpInt   (-1   *  pega_int   vexp, top)
        | A.TipoFloat -> ExpFloat (-1.0 *. pega_float vexp, top)
        | _           -> failwith "Operador unario indefinido")
      in
      let valor =
       (match op with
          | Not   -> interpreta_not ()
          | Menos -> interpreta_negativo ()
          | _     -> failwith "Operador unario indefinido")
      in  valor
    | ExpChmd (id, args, tipo) ->
      let open Amb in
        (match (Amb.busca amb id) with
          | Amb.EntFun {tipo_fn; formais; corpo} ->
             let vargs    = List.map  (interpreta_exp amb) args in
             let vformais = List.map2 (fun (n,t) v -> (n, t, Some v)) formais vargs
             in  interpreta_fun amb vformais corpo
          | _ -> failwith "interpreta_exp: expchamada"
        )
    | ExpNone -> T.ExpNone
and interpreta_cmd amb cmd =
  let open A in
  let open T in
  match cmd with
    CmdReturn exp ->
    (* Levantar uma exceção foi necessária pois, pela semântica do comando de   *)
    (* retorno, sempre que ele for encontrado em uma função, a computação       *)
    (* deve parar retornando o valor indicado, sem realizar os demais comandos. *)
    (match exp with
      (* Se a função não retornar nada, então retorne ExpVoid *)
      | None -> raise (Valor_de_retorno ExpNone)
      | Some e ->
        (* Avalia a expressão e retorne o resultado *)
        let e1 = interpreta_exp amb e in
        raise (Valor_de_retorno e1))
  | CmdIf (teste, entao, senao) ->
      let teste1 = interpreta_exp amb teste in
      (match teste1 with
        | ExpBool (true,_) ->
        (* Interpreta cada comando do bloco 'então' *)
        List.iter (interpreta_cmd amb) entao
        | _ ->
          (* Interpreta cada comando do bloco 'senão', se houver *)
          (match senao with
            | None -> ()
            | Some bloco -> interpreta_cmd amb bloco))
  | CmdElse comandos ->
        List.iter (interpreta_cmd amb ) comandos
  | CmdAtrib (elem, exp) ->
      let resp = interpreta_exp amb exp in       
        (match elem with
          | T.ExpVar (id,tipo) ->
           (try
              begin 
                match (Amb.busca amb id) with
                  | Amb.EntVar (t, _) -> Amb.atualiza_var amb id tipo (Some resp)
                  | Amb.EntFun _      -> failwith "falha na atribuicao"
              end 
            with Not_found -> 
              let _ = Amb.insere_local amb id tipo None in 
              Amb.atualiza_var amb id tipo (Some resp))
          | _ -> failwith "Falha CmdAtrib"
        )
  | CmdChmd   exp -> ignore( interpreta_exp amb exp )
  | CmdInputi exp
  | CmdInputf exp
  | CmdInputc exp
  | CmdInputs exp ->
    (* Obtem os nomes e os tipos de cada um dos argumentos *)
    let nt = obtem_nome_tipo_var exp in
    let leia_var (nome,tipo) =
     let _ = 
       (try
          begin 
            match (Amb.busca amb nome) with
              | Amb.EntVar (_,_) -> ()
              | Amb.EntFun _     -> failwith "falha no input"
          end 
        with Not_found -> 
          let _ = Amb.insere_local amb nome tipo None in ()
        )
      in
      let valor = 
       (match tipo with
          | TipoInt   -> T.ExpInt   (read_int   ()   , tipo)
          | TipoStr   -> T.ExpStr   (read_line  ()   , tipo)
          | TipoChar  -> T.ExpChar  (input_char stdin, tipo)
          | TipoFloat -> T.ExpFloat (read_float ()   , tipo)
          | _         -> failwith "Fail input")
      in  Amb.atualiza_var amb nome tipo (Some valor)
    in leia_var nt
  | CmdPrint exp ->
    let resp = interpreta_exp amb exp in
      (match resp with
        | T.ExpInt   (n,_) -> print_int    n
        | T.ExpFloat (n,_) -> print_float  n
        | T.ExpStr   (n,_) -> print_string n
        | T.ExpChar  (n,_) -> print_char   n
        | _ -> failwith "Fail print"
      )
  | CmdWhile (cond, cmds) -> 
        let rec laco cond cmds = 
          let condResp = interpreta_exp amb cond in
                (match condResp with
                  | ExpBool (true,_) ->
                      (* Interpreta cada comando do bloco 'então' *)
                      let _ = List.iter (interpreta_cmd amb) cmds in 
                        laco cond cmds
                  | _ -> ())
        in laco cond cmds

and interpreta_fun amb fn_formais fn_corpo =
  let open A in
 (* Estende o ambiente global, adicionando um ambiente local *)
  let ambfn = Amb.novo_escopo amb in
  (* Associa os argumento
  s aos parâmetros e insere no novo ambiente *)
  let insere_parametro (n,t,v) = Amb.insere_param ambfn n t v in
  let _ = List.iter insere_parametro fn_formais in
      (* Interpreta cada comando presente no corpo da função usando o novo *)
      (* ambiente                                                          *)
      try
        let _ = List.iter (interpreta_cmd ambfn) fn_corpo in T.ExpNone
      with
        Valor_de_retorno expret -> expret

let insere_declaracao_fun amb dec =
  let open A in
    match dec with
      | Funcao {fn_nome; fn_tiporet; fn_formais; fn_corpo} ->
        let nome = fst fn_nome in
        let formais = List.map (fun (n,t) -> ((fst n), t)) fn_formais in
        Amb.insere_fun amb nome formais fn_tiporet fn_corpo
      | _ -> failwith "Erro de declaacao de funcao"

(* Lista de cabeçalhos das funções pré definidas *)
let fn_predefs = let open A in [
    ("inputi", [("x", TipoInt  )], TipoNone, []);
    ("inputf", [("x", TipoFloat)], TipoNone, []);
    ("inputc", [("x", TipoChar )], TipoNone, []);
    ("inputs", [("x", TipoStr  )], TipoNone, []);
    ("printi", [("x", TipoInt  )], TipoNone, []);
    ("printf", [("x", TipoFloat)], TipoNone, []);
    ("printc", [("x", TipoChar )], TipoNone, []);
    ("prints", [("x", TipoStr  )], TipoNone, []);
]

(* insere as funções pré definidas no ambiente global *)
let declara_predefinidas amb =
  List.iter (fun (n,ps,tr,c) -> Amb.insere_fun amb n ps tr c) fn_predefs

let interprete ast =
  let open Amb in
  let amb_global = Amb.novo_amb [] in
  let _ = declara_predefinidas amb_global in
  let A.Programa instr = ast in
    let decs_funs = List.filter (fun x -> 
    (match x with
    | A.Funcao _ -> true
    | _          -> false)) instr in
    let _ = List.iter (insere_declaracao_fun amb_global) decs_funs in
      (try begin
        (match (Amb.busca amb_global "main") with
            | Amb.EntFun { tipo_fn ; formais ; corpo } ->
              let vformais = List.map (fun (n,t) -> (n, t, None)) formais in
              let _        = interpreta_fun amb_global vformais corpo in ()
            | _ -> failwith "variavel declarada como 'main'")
       end with Not_found -> failwith "Funcao main nao declarada ")
      