## Zbiór Mandelbrota
Program wyświetlający zbiór <a href="https://en.wikipedia.org/wiki/Mandelbrot_set" target="_blank">Mandelbrota</a> w oknie graficznym symulatora RARS albo w pliku bmp

## Pliki:
- Mandelbrot_set_on_bitmap.asm - wyświetlanie zbioru Mandelbrota w oknie graficznym symulatora RARS, trzeba wybrać Tools -> Bitmap Display, potem wybrać wysokość i szerokość na 512 pikseli i wcisnąć 'Connect to Program', następnie odpalić program
- Testing_file.asm - służy do testowania wyświetlania pikseli w bmp, otwierania, zamykania plików w bmp, testowania operacji stałopozycjnych oraz do przechowywania funkcji, które wcześniej służyły to testów
- Mandelbrot_set_on_bmp.asm - generowanie zbioru Mandelbrota w pliku bmp, trzeba pamiętać, aby przy uruchomieniu mieć włączoną opcję w RARS Settings -> Derive current working directory oraz żeby mieć w tym samym folderze dowolny plik bmp 512 x 512 o nazwie "black.bmp"
- black.bmp - plik pomocniczy do generowania pliku bmp, z niego pobierany jest header bmp (można też samodzielnie ustawić header bmp bez oddzielnego pliku, ale miałem z tym problem)

<hr>

#### Problemy
- Mandelbrot_set_on_bitmap.asm - funckja draw_pixel nie rysuje pikseli gdy y = 0, cała reszta jest ok
- Mandelbrot_set_on_bmp.asm - funkcja draw_pixel_on_bmp nie rysuje pikseli gdy y = 512, cała reszta ok
##### Te funkcje działają bardzo podobnie i to jest ten sam problem w obu przypadkach (po prostu kolejność bajtów jest inna w bmp i bitmapie), na razie nie udało się tego naprawić

<hr>

#### Przykład wyświetlania (pozostałe przykłady znajdują się w folderze MandelbrotSetImages)
![mandelbrot_set_bitmap](https://user-images.githubusercontent.com/113067612/235349261-04fbbb2f-cfa7-407f-9da4-9c20e1c723b5.png)

<hr>

#### Uwagi ogólne
Bitmapa i bmp mają inny układ współrzednych
- Bitmapa: NW: (0, 0), NE: (512, 0), SE: (512, 512), SW: (0, 512)
- BMP: NW: (0, 512), NE: (512, 512), SE: (512, 0), SW: (0, 0)

W programie współrzedne bmp są zamieniane na współrzędne bitmapy, współrzędne bitmapy są zamieniane na współrzędne układu o środku w środku bitmapy z wartościami na osi x, y od -256 do 256, a na ostatnim etapie te współrzędne są mapowane na wartości od -2 do 2 w naszej przyjętej reprezentacji stałopozycyjnej (w funkcji from_xy_to_complex), która ma 22b na część całkowitą i 10b na część ułamkową
