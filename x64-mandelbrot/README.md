## Zbiór Mandelbrota

Program wyświetlający zbiór <a href="https://en.wikipedia.org/wiki/Mandelbrot_set" target="_blank">Mandelbrota</a> przy pomocy biblioteki SDL. Program wykorzystuje x64 wersja NASM do algorytmu i C++ do wyświetlania rezultatu.

---

## Odpalenie

Potrzebne: g++, nasm, make, sdl

### Przykład odpalenia

```bash
    make
    ./fun
```

```bash
    make
    ./fun 512 512       // ustawienie szerokości i wysokości okna
```

### Jak użytkownik może wpływać na działanie programu

- przybliżanie ARROW DOWN, oddalanie ARROW UP
- po kliknięciu BACKSPACE, wyświetlanie wraca do pozycji startowej
- poruszanie się poprzez W, A, S, D

### Jak wygląda

![Example](/Screens/example_mandelbrot.png)
