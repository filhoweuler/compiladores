def menu(op:int) -> str:
    resp = "opcao invalida!"
    if op == 1:
        resp = "adicionar alguma coisa"
    elif op == 2:
        resp = "remover alguma coisa"
    elif op == 3:
        resp = "consultar alguma coisa"
    else:
    	resp = "resto"
    return resp
