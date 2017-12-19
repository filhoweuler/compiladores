def fat(n:int) -> int:
    if n <= 1:
        return 1
    else:
        return n*fat(n-1)

def main() -> None:
    print("Digite um numero para calcular o fatorial: ")
    inputi(f)
    print(" fatorial :")
    print(fat(f))
