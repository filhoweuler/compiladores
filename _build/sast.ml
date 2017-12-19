open Ast

type expressao = 
	  ExpVar   of (expressao variavel)
	| ExpInt   of int pos
	| ExpStr   of string pos
	| ExpChar  of char pos
	| ExpBool  of bool pos
	| ExpFloat of float pos
	| ExpOperB of operador pos * expressao * expressao
	| ExpOperU of operador pos * expressao 
	| ExpChmd  of identificador pos * (expressao expressoes)
