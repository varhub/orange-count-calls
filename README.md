# orange-count-calls
Extractor de información de las facturas telefónicas de Orange

## Motivación
La factura de Orange, cuando es descargada del *Area de Clientes* viene dividida en dos ficheros, un .pdf que es 'la factura', y un **.txt** que tiene el registro de todas las llamadas.

En mi caso, tengo el boto de 1.000 min a móviles, y aunque sería más que razonable saber cuántos minutos llevo consumidos Orange no permite este tipo de consultas.

Por ello he realizado este script. Que cuenta el número de llamadas y los minutos a fijos y móviles.


## Requisitos
Se trata de un script de bash, luego para Windows se necesita software addicional.

## Estructura
La estructura de ficheros necesaria es bastante laxa, dirigida sobre todo por organización.
* Los *.txt* pueden tener cualquier nombre, pero **deben** atender a un orden alfabético. *De modo que la última factura coincide con el último fichero si se lista de forma ordenada*
* Deben estar en divididos en carpetas. En este caso por año, pero cualquier otro nombre es asumible al ser un parámetro de entrada.
* No puede haber otros *.txt* en el árbol de subdirectorios.

## Mi estructura
* Facturas Orange/
  * count-calls.sh
  * 2013/
    * ... 
  * 2014/
    * 2014-01.pdf
    * 2014-01.txt
    * 2014-02.pdf
    * 2014-02.txt
    * ...
    * 2014-12.pdf
    * 2014-12.txt
 * ... 


## Ejemplo

`$ bash count-calls.sh last`
```
Resumen factura '2014/2014-08.txt'
	Fecha inicio periodo facturado: 01/07/2014
	Fecha fin periodo facturado: 31/07/2014
	Total factura: 16,34
	Numero de llamadas:     112
	Numero de llamadas a moviles:      32
	Minutos hablados: 1085 min
	Minutos hablados a moviles: 512 min
```
