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
