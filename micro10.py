def fib(n:int) -> int:
    if n <= 1:
        return 1
    else:
        return fib(n-1)+fib(n-2)

def main() -> None:
    print("Digite um numero para calcular o fibonacci: ")
    inputi(f)
    print(" fibonacci :")
    print(fib(f))
