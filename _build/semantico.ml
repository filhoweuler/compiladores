module Amb = Ambiente
module A = Ast
module S = Sast
module T = Tast

let rec posicao exp = 
  let open S in
  match exp with
  | ExpVar       v -> (match v with A.VarSimples (_,pos)      -> pos)
  | ExpInt       (_,pos)      -> pos
  | ExpStr       (_,pos)      -> pos
  | ExpBool      (_,pos)      -> pos
  | ExpChar      (_,pos)      -> pos
  | ExpFloat     (_,pos)      -> pos
  | ExpOperB    ((_,pos),_,_) -> pos
  | ExpOperU    ((_,pos),_)   -> pos
  | ExpChmd     ((_,pos),_)   -> pos

type classe_op = Aritmetico | Relacional | Logico

let classifica op =
  let open A in
    match op with
      Mais
    | Menos
    | Mul
    | Div
    | Mod       -> Aritmetico
    | Maior
    | Menor
    | MaiorIgual
    | MenorIgual
    | Igual
    | Difer     -> Relacional
    | Elog
    | Oulog
    | Not       -> Logico

let msg_erro_pos pos msg =
  let open Lexing in
  let lin = pos.pos_lnum
  and col = pos.pos_cnum - pos.pos_bol - 1 in
  Printf.sprintf "Semantico -> linha %d, coluna %d: %s" lin col msg

(*  argumento nome é do tipo S.tipo  *)
let msg_erro nome msg =
  let pos = snd nome in
  msg_erro_pos pos msg

let nome_tipo t =
  let open A in
    match t with
      TipoInt     -> "inteiro"
    | TipoStr     -> "string"
    | TipoBool    -> "booleano"
    | TipoChar    -> "caracter"
    | TipoFloat   -> "real"
    | TipoNone    -> "vazio"

let mesmo_tipo pos msg tinf tdec =
  if tinf <> tdec then
    let msg = Printf.sprintf msg (nome_tipo tinf) (nome_tipo tdec) in
    failwith (msg_erro_pos pos msg)

let rec infere_exp amb exp =
  match exp with
  | S.ExpInt   i -> (T.ExpInt   (fst i, A.TipoInt  ), A.TipoInt  )
  | S.ExpStr   s -> (T.ExpStr   (fst s, A.TipoStr  ), A.TipoStr  )
  | S.ExpBool  b -> (T.ExpBool  (fst b, A.TipoBool ), A.TipoBool )
  | S.ExpChar  c -> (T.ExpChar  (fst c, A.TipoChar ), A.TipoChar )
  | S.ExpFloat f -> (T.ExpFloat (fst f, A.TipoFloat), A.TipoFloat)
  | S.ExpVar v ->
    (match v with
      A.VarSimples nome ->
      let id = fst nome in
        (try (match (Amb.busca amb id) with
            | Amb.EntVar tipo -> (T.ExpVar (A.VarSimples nome, tipo), tipo)
            | Amb.EntFun _    -> 
                let msg = "Nome de funcao usado como nome de variavel: "^id in
                  failwith (msg_erro nome msg))
        with Not_found ->
          let msg = "Variavel "^id^" nao declarada" in
            failwith (msg_erro nome msg))
      )

  | S.ExpOperB (op, exp_esq, exp_dir) ->
      let (esq, tesq) = infere_exp amb exp_esq
      and (dir, tdir) = infere_exp amb exp_dir in
      let verifica_aritmetico () = 
        (match tesq with
        | A.TipoInt
        | A.TipoFloat ->
            let _ = mesmo_tipo (snd op)
                    "Operando esquerdo do tipo %s, mas o tipo do direito eh %s"
                    tesq tdir
            in tesq (* Tipo inferido para a operação *)
        | demais      ->
            let msg = "O tipo "^
                      (nome_tipo demais)^
                      " nao eh valido em um operador aritmético" in
              failwith (msg_erro op msg))
      and verifica_relacional () =
        (match tesq with
        | A.TipoInt
        | A.TipoStr
        | A.TipoBool
        | A.TipoChar
        | A.TipoFloat -> 
            (let _ = mesmo_tipo (snd op)
                    "Operando esquerdo do tipo %s, mas o tipo do direito eh %s"
                    tesq tdir
            in A.TipoBool) (* Tipo inferido para a operação *)
        | demais      ->
            (let msg = "O tipo "^
                      (nome_tipo demais)^
                      " nao eh valido em um operador relacional" in
              failwith (msg_erro op msg)))
      and verifica_logico () = 
        (match tesq with
        | A.TipoBool ->
            let _ = mesmo_tipo (snd op)
                    "Operando esquerdo do tipo %s, mas o tipo do direito eh %s"
                    tesq tdir
            in A.TipoBool (* Tipo inferido para a operação *)
        | demais ->
            let msg = "O tipo "^
                      (nome_tipo demais)^
                      " nao eh valido em um operador logico" in
              failwith (msg_erro op msg))
      in
      let oper = fst op in
      let tinf = 
         (match (classifica oper) with
        | Aritmetico -> verifica_aritmetico ()
        | Relacional -> verifica_relacional ()
        | Logico     -> verifica_logico () )
      in (T.ExpOperB ((oper, tinf), (esq, tesq), (dir, tdir)), tinf)
  | S.ExpOperU (op, exp) ->
    let (exp, texp) = infere_exp amb exp in
    let verifica_not () = 
      match texp with
      | A.TipoBool ->
          let _ = mesmo_tipo (snd op)
                  "O operando eh do tipo %s, mas espera-se um %s"
                  texp A.TipoBool
          in A.TipoBool
      | demais     ->
          let msg = "O tipo "^
                      (nome_tipo demais)^
                      " nao eh valido para o operador not" in
              failwith (msg_erro op msg)
    and verifica_negativo () = 
      match texp with
      | A.TipoFloat ->
          let _ = mesmo_tipo (snd op)
                  "O operando eh do tipo %s, mas espera-se um %s"
                  texp A.TipoFloat
          in A.TipoFloat
      | A.TipoInt ->
          let _ = mesmo_tipo (snd op)
                  "O operando eh do tipo %s, mas espera-se um %s"
                  texp A.TipoInt
          in A.TipoInt
      | demais     ->
          let msg = "O tipo "^
                      (nome_tipo demais)^
                      " nao eh valido para o operador menos" in
              failwith (msg_erro op msg)
    in
    let oper = fst op in
    let tinf =
      let open A in
        match oper with
        | Not   -> verifica_not ()
        | Menos -> verifica_negativo ()
        | demais->
            let msg = "Operador unario indefinido"
            in failwith (msg_erro op msg)
    in  (T.ExpOperU ((oper, tinf), (exp, texp)), tinf)
  | S.ExpChmd (nome, args) ->
    let rec verifica_parametros ags ps fs =
      match (ags, ps, fs) with
      | (a::ags), (p::ps), (f::fs) ->
          let _ = mesmo_tipo (posicao a)
                  "O parametro eh do tipo %s mas deveria ser do tipo %s" 
                  p f
          in verifica_parametros ags ps fs
      | [], [], [] -> ()
      | _ -> failwith (msg_erro nome "Numero incorreto de parametros")
    in
    let id = fst nome in
      try
        begin
          let open Amb in
            match (Amb.busca amb id) with
            | Amb.EntFun {tipo_fn; formais} ->
              let targs    = List.map (infere_exp amb) args
              and tformais = List.map snd formais in
              let _ = verifica_parametros args (List.map snd targs) tformais in
                (T.ExpChmd (id, (List.map fst targs), tipo_fn), tipo_fn)
            | Amb.EntVar _ -> (* Se estiver associada a uma variável, falhe *)
              let msg = id ^ " eh uma variavel e nao uma funcao" in
                failwith (msg_erro nome msg)
        end
      with Not_found ->
        let msg = "Nao existe a funcao de nome " ^ id in
        failwith (msg_erro nome msg)

let rec verifica_cmd amb tiporet cmd =
  let open A in
    match cmd with
    | CmdReturn exp ->
      (match exp with
      | None -> 
          let _ = mesmo_tipo (Lexing.dummy_pos)
            "O tipo retornado eh %s mas foi declarado como %s"
            TipoNone tiporet
          in CmdReturn None
      | Some exp ->
          let (e1,tinf) = infere_exp amb exp in
          let _ = mesmo_tipo (posicao exp)
            "O tipo retornado eh %s mas foi declarado como %s"
            tinf tiporet
          in CmdReturn (Some e1))
    | CmdChmd  exp -> let (exp,tinf) = infere_exp amb exp in CmdChmd exp
    | CmdInputi exp -> 
        (match exp with 
          S.ExpVar (A.VarSimples (id,pos)) ->
           (try
              begin 
                (match (Amb.busca amb id) with
                    Amb.EntVar tipo ->
                      let expt = infere_exp amb exp in  
                      let _ = mesmo_tipo pos
                        "inputi com tipos diferentes: %s = %s"
                        tipo (snd expt) in 
                        CmdInputi (fst expt)
                  | Amb.EntFun _ ->
                      let msg = "nome de funcao usado como nome de variavel: " ^ id in
                      failwith (msg_erro_pos pos msg) )
              end 
            with Not_found -> 
              let _ = Amb.insere_local amb id A.TipoInt in
              let expt = infere_exp amb exp in  
              CmdInputi (fst expt) )
          | _ -> failwith "Falha Inputi"
        )
        
    | CmdInputf exp -> 
        (match exp with 
          S.ExpVar (A.VarSimples (id,pos)) -> 
           (try
              begin 
                (match (Amb.busca amb id) with
                    Amb.EntVar tipo ->
                      let expt = infere_exp amb exp in  
                      let _ = mesmo_tipo pos
                        "Inputf com tipos diferentes: %s = %s"
                        tipo (snd expt) in 
                        CmdInputf (fst expt)
                  | Amb.EntFun _ ->
                      let msg = "nome de funcao usado como nome de variavel: " ^ id in
                      failwith (msg_erro_pos pos msg) )
              end 
            with Not_found -> 
              let _ = Amb.insere_local amb id A.TipoFloat in
              let expt = infere_exp amb exp in  
              CmdInputf (fst expt) )
          | _ -> failwith "Falha Inputf"  
        )
    | CmdInputs exp -> 
        (match exp with 
          S.ExpVar (A.VarSimples (id,pos)) -> 
           (try
              begin 
                (match (Amb.busca amb id) with
                    Amb.EntVar tipo ->
                      let expt = infere_exp amb exp in  
                      let _ = mesmo_tipo pos
                        "Inputs com tipos diferentes: %s = %s"
                        tipo (snd expt) in 
                        CmdInputs (fst expt)
                  | Amb.EntFun _ ->
                      let msg = "nome de funcao usado como nome de variavel: " ^ id in
                      failwith (msg_erro_pos pos msg) )
              end 
            with Not_found -> 
              let _ = Amb.insere_local amb id A.TipoStr in
              let expt = infere_exp amb exp in  
              CmdInputs (fst expt) )
          | _ -> failwith "Falha Inputs"  
        ) 
    | CmdInputc exp -> 
        (match exp with 
          S.ExpVar (A.VarSimples (id,pos)) -> 
           (try
              begin 
                (match (Amb.busca amb id) with
                    Amb.EntVar tipo ->
                      let expt = infere_exp amb exp in  
                      let _ = mesmo_tipo pos
                        "Input com tipos diferentes: %s = %s"
                        tipo (snd expt) in 
                        CmdInputc (fst expt)
                  | Amb.EntFun _ ->
                      let msg = "nome de funcao usado como nome de variavel: " ^ id in
                      failwith (msg_erro_pos pos msg) )
              end 
            with Not_found -> 
              let _ = Amb.insere_local amb id A.TipoChar in
              let expt = infere_exp amb exp in  
              CmdInputc (fst expt) )
          | _ -> failwith "Falha InputChar"  
        ) 
    | CmdPrint exp -> let expt = infere_exp amb exp in CmdPrint (fst expt)
    
    | CmdWhile (cond, cmds) -> 
        let (expCond, expT ) = infere_exp amb cond in
        let comandos_tipados = 
          (match expT with 
            | A.TipoBool -> List.map (verifica_cmd amb tiporet) cmds
            | _ -> let msg = "Condicao deve ser tipo Bool" in
                        failwith (msg_erro_pos (posicao cond) msg))
        in CmdWhile (expCond,comandos_tipados)

    | CmdIf (teste, entao, senao) ->
        let (teste1,tinf) = infere_exp amb teste in
        let _ = mesmo_tipo (posicao teste)
                "O teste do if deveria ser do tipo %s e nao %s"
                TipoBool tinf in
        let entao1 = List.map (verifica_cmd amb tiporet) entao in
        let senao1 =
          match senao with
          | None       -> None
          | Some bloco -> let c = verifica_cmd amb tiporet bloco in Some c
        in CmdIf (teste1, entao1, senao1)

    | CmdElse comandos ->
        let comandos = List.map (verifica_cmd amb tiporet) comandos in
          CmdElse comandos

    | CmdAtrib (elem, exp) ->
        let (var1, tdir) = infere_exp amb exp in       
        ( match elem with 
          S.ExpVar (A.VarSimples(id,pos)) -> 
           (try
              begin 
                (match (Amb.busca amb id) with
                    Amb.EntVar tipo -> 
                      let _ = mesmo_tipo pos
                        "Atribuicao com tipos diferentes: %s = %s"
                        tipo tdir in 
                        CmdAtrib (T.ExpVar (A.VarSimples(id,pos), tipo), var1)
                  | Amb.EntFun _ ->
                      let msg = "nome de funcao usado como nome de variavel: " ^ id in
                      failwith (msg_erro_pos pos msg) )
              end 
            with Not_found -> 
              let _ = Amb.insere_local amb id tdir in 
              CmdAtrib (T.ExpVar (A.VarSimples(id,pos), tdir), var1))
          | _ -> failwith "Falha CmdAtrib")
        
and verifica_fun amb ast =
  let open A in
  match ast with
  | Funcao {fn_nome; fn_tiporet; fn_formais; fn_corpo} ->
    (* Estende o ambiente global, adicionando um ambiente local *)
    let ambfn = Amb.novo_escopo amb in
    (* Insere os parâmetros no novo ambiente *)
    let insere_parametro (v,t) = Amb.insere_param ambfn (fst v) t in
      let _ = List.iter insere_parametro fn_formais in
    (* Verifica cada comando presente no corpo da função usando o novo ambiente *)
    let corpo_tipado = List.map (verifica_cmd ambfn fn_tiporet) fn_corpo in
      Funcao {fn_nome; fn_tiporet; fn_formais; fn_corpo = corpo_tipado}
  | Cmd _ -> failwith "Instrucao invalida"

let rec verifica_dup xs =
  match xs with
  | [] -> []
  | (nome,t)::xs ->
    let id = fst nome in
    if (List.for_all (fun (n,t) -> (fst n) <> id) xs)
    then (id, t) :: verifica_dup xs
    else let msg = "Parametro duplicado " ^ id in
      failwith (msg_erro nome msg)

let insere_declaracao_fun amb dec =
  let open A in
    match dec with
    | Funcao {fn_nome; fn_tiporet; fn_formais; fn_corpo} ->
      let formais = verifica_dup fn_formais in
      let nome = fst fn_nome in
      Amb.insere_fun amb nome formais fn_tiporet
    | Cmd _ -> failwith "Instrucao invalida"

let fn_predefs = 
  let open A in [
    ("printi", [("x", TipoInt  )], TipoNone);
    ("prints", [("x", TipoStr  )], TipoNone);
    ("printc", [("x", TipoChar )], TipoNone);
    ("printf", [("x", TipoFloat)], TipoNone);
    ("inputi", [("x", TipoInt  )], TipoNone);
    ("inputs", [("x", TipoStr  )], TipoNone);
    ("inputc", [("x", TipoChar )], TipoNone);
    ("inputf", [("x", TipoFloat)], TipoNone)]

let declara_predefinidas amb =
  List.iter (fun (n,ps,tr) -> Amb.insere_fun amb n ps tr) fn_predefs

let semantico ast =
  let amb_global = Amb.novo_amb [] in
  let _ = declara_predefinidas amb_global in
  let A.Programa instr = ast in
  let decs_funs = List.filter(fun x -> 
    (match x with
    | A.Funcao _ -> true
    | _          -> false)) instr in
    let _ = List.iter (insere_declaracao_fun amb_global) decs_funs in
      let decs_funs = List.map (verifica_fun amb_global) decs_funs in
      (A.Programa decs_funs, amb_global)
