def fib(n:int) -> int:
    if n <= 1:
        return 1
    else:
        return fib(n-1)+fib(n-2)

def fat(n:int) -> int:
    if n <= 1:
        return 1
    else:
        return n*fat(n-1)

def primo(n:int) -> bool:
    div = 2
    while div < n:
        resto = n%div
        if resto == 0:
             return False
        div += 1
    return True

def mdc(dividendo:int, divisor:int) -> int:
    while divisor != 0:
        temp = divisor
        divisor = dividendo % divisor
        dividendo = temp    
    return dividendo

def media(x:float, y:float) -> float:
    return (x+y)/2.0

def main() -> None:
    op = 1
    while op != 0:
        print("| 1 - fib\n| 2 - fat\n| 3 - primo\n| 4 - media\n| 5 - mdc\n| 0 - sair\n-> ")
        inputi(op)
        if op == 1:
            print("Digite um numero para calcular o fibonacci: ")
            inputi(f)
            print(" fibonacci :")
            print(fib(f))
        elif op == 2:
            print("Digite um numero para calcular o fatorial: ")
            inputi(f)
            print(" fatorial :")
            print(fat(f))
        elif op == 3:
            print("Digite um numero para verificar se eh primo: ")
            inputi(f)
            if primo(f):
                print("Eh primo\n")
            else:
            	print("Nao eh primo\n")
        elif op == 4:
            print("Digite dois valores a e b:\n")
            inputf(a)
            inputf(b)
            print(" media: ")
            print(media(a,b))
        elif op == 5:
            print("Digite dividendo e divisor:\n")
            inputi(n)
            inputi(m)
            print(" mdc: ")
            print(mdc(m,n))
        print("\n")
