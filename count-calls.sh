#!/bin/sh
# Copyright (c) 2014, Victor Arribas <v.arribas.urjc@gmail.com>.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


set -e
set -u


#__PARSING__#

grep_llamadas=".........                      Consumo"
grep_movil="Llamadas a m.viles"
grep_main_info_filter='periodo facturado\|Total factura'


## Calls format after conversion (for awk -F'\t')
# $1	nº telf (origen)
# $2	texto "Consumo"
# $3	texto "lamadas Nacionales" | "Llamadas a Móviles" | ?
# $4	nº telf (origen)
# $5	fecha (dd/mm/aaaa)
# $6	nº telf (destino)
# $7	destino: provincia (fijo) | compañia movil (movil)
# $8	texto "dentro de cuota" | ?
# $9	texto "Llamadas Nacionales" | "Llamadas Interprovinciales" | "Llamadas a Móviles" | ?
# $10	identificador de factura
# $11	tipo de llamada: "Normal" | "Reducida" | ?
# $12	hora (hh:mm:ss)
# $13	segundos
# $14	€?
# $15	€?
# $16	€?
# $17	€?
f_parse_calls(){
	cat | grep "$grep_llamadas" | sed 's/  \+/\t/g'
}

f_parse_pricing(){
	cat | awk 'NR==1 || NR==2 || NR==8'
}

#__FORMATING__#

f_format_unify(){
	### deteccion
	### cat | awk -F'\t' '{print NF "\t" $0}'
	##caso0: considerado estandar (llamadas a fijo)
	# deteccion: NF=17
	##caso1: llamadas a fijo con un campo más que a movil ($9)
	# deteccion: $4 = Llamadas a móviles | awk NF=16
	# accion: inyeccion de "Llamadas a Movil" como $9
	
	cat | awk -F'\t' 'OFS="\t" {
	if (NF == 17) 
		{print $0}
	else if (NF == 16) 
		{print $1,$2,$3,$4,$5,$6,$7,$8,"Llamadas a Movil",$9,$10,$11,$12,$13,$14,$15,$16}
	else 
		{print "__NOT_RECOGNIZED_(NF=" NF ")__ " $0}
	}'
}


## Extract call info
# $1	nº telf (origen)
# $2	nº telf (destino)
# $3	destino: provincia | compañia movil
# $4	segundos
# $5	fecha (dd/mm/aaaa)
# $6	hora (hh:mm:ss)
# $7	texto "Llamadas Nacionales" | "Llamadas Interprovinciales" | "Llamadas a Móviles" | ?
# $8	texto "dentro de cuota" | ?
# $9	€?
f_call_info(){
	cat | awk -F'\t' 'OFS="\t" {print $1,$6,$7,$13,$5,$12,$3,$8,$14}'
}

## Extract minimal call info
# $1	nº telf (origen)
# $2	nº telf (destino)
# $3	segundos
f_call_info_minimal(){
	cat | awk -F'\t' 'OFS = "\t" {print $1,$6,$13}'
}


#__HIGH LEVEL FUNCTIONS__#
f_count_minutes_to_mobile(){
	cat "$1" | f_parse_calls | f_format_unify | grep "$grep_movil" | f_call_info_minimal | awk -F'\t' 'BEGIN{ printf "( "; ORS=" + "} {print $3} END{ ORS="\n"; print "59 ) / 60"}' | bc
}

f_count_minutes(){
	cat "$1" | f_parse_calls | f_format_unify | f_call_info_minimal | awk -F'\t' 'BEGIN{ printf "( "; ORS=" + "} {print $3} END{ ORS="\n"; print "59 ) / 60"}' | bc
}

f_count_calls(){
	cat "$1" | f_parse_calls | wc -l
}

f_count_calls_to_mobile(){
	cat "$1" | f_parse_calls | grep "$grep_movil" | wc -l
}

f_main_info(){
	cat "$1" | grep "$grep_main_info_filter" | awk -F':' '{ print "\t" $1": "$2}'
}
f_summary(){
	file=$1
	echo "Resumen factura '$file'"
	f_main_info $file
	echo "	Numero de llamadas: $(f_count_calls $file)"
	echo "	Numero de llamadas a moviles: $(f_count_calls_to_mobile $file)"
	echo "	Minutos hablados: $(f_count_minutes $file) min"
	echo "	Minutos hablados a moviles: $(f_count_minutes_to_mobile $file) min"
}

f_summary_all(){
	ls *.txt | while read file
	do
		f_summary "$file"
	done
}

f_get_files(){
	find -type f -mindepth 2 -name '*.txt'
}

#__MAIN__#
arg=${1:-help}
case $arg in
	all)
		f_get_files | while read file
		do
			f_summary "$file"
		done
	;;
	last)
		file=$(f_get_files | sort -r | head -n 1)
		f_summary "$file"
	;;
	year=*)
		dir=${arg##year=}
		if [ -d "$dir" ]; then
			ls "$dir"/*.txt | while read file
			do
				f_summary "$file"
			done
		fi
	;;
	ym=*)
		data=${arg##ym=}
		year=${data%-*}
		month=${data#*-}
		file="$year/$year-$month.txt"
		
		if [ -e "$file" ]; then
			f_summary "$file"
		fi
	;;
	help|*)
		echo "Usage: $0 last | all | year=<a year> | ym=year-month" >&2
esac

## OLD
#	cat $file | f_parse_calls | f_format_unify | awk -F'\t' '{print NF "\t" $0}'
#	cat "$file" | f_parse_calls | f_format_unify | f_call_info
#	cat "$file" | f_parse_calls | f_format_unify | grep "$grep_movil" | f_call_info
#	cat "$file" | f_parse_calls | f_format_unify | grep "$grep_movil" | f_call_info_minimal
#
#	cat "$file" | grep "$grep_llamadas" | sed 's/  \+/\t/g' | head -n 1
#	cat "$file" | grep "$grep_llamadas" | grep "$grep_movil" | awk '{print $17}'