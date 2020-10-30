% Encabezado
% Restricciones Naive Model
% Jaime Cuartas Granada 1632664
% Emily Esmeralda Carvajal Camelo 1630436
% Desenfreno de Pasiones
include "globals.mzn";


enum ACTORES;
array[ACTORES, int] of int: Escenas;
int: nEscenas=length(row(Escenas,1))-1;
array[1..nEscenas] of int: Duracion;

% asserts

constraint assert(length(ACTORES) = length(col(Escenas,1)),
                  "Cantidad invalida de escenas o actores, no coincide");
constraint assert(length(row(Escenas,1))-1 = length(Duracion),
                  "Cantidad invalida de escenas o duracion, no coincide");
                  
constraint assert(forall(d in Duracion)(d > 0),
                  "Valores de duracion invalidos");
                  
constraint assert(forall(i in index_set(Duracion))
                  (forall (j in col(Escenas,i))(j = 0 \/ j = 1)),
                  "Algun valor es invalido en la matriz Escenas");
                  

% Dado un actor retorna el costo del actor por las escenas en que participa
array[ACTORES] of int: Costo = [Escenas[x,nEscenas+1] | x in ACTORES];
% Dado un actor retorna las escenas en que esta 
array[ACTORES] of set of int: EscenaDe = [{y | y in 1..nEscenas where Escenas[x,y]=1} | x in ACTORES];

% Variable
array[1..nEscenas] of var 1..nEscenas: PosicionDeEscena;

% Suma los costos de cada actor por las escenas en que esta
var int : costo = (sum(j in ACTORES)(
                       let {
                         var int: primera=min([PosicionDeEscena[e] | e in EscenaDe[j]]);
                         var int: ultima=max([PosicionDeEscena[e] | e in EscenaDe[j]]);
                       }
                       in
                      (sum(i in 1..nEscenas)
                          (if PosicionDeEscena[i] >= primera
                              /\
                              PosicionDeEscena[i] <= ultima
                           then Duracion[i]
                           else 0
                           endif)) * Costo[j]));                       
                                
% Restricciones

constraint all_different(PosicionDeEscena);

% solver

solve minimize costo;

% salida

output ["[ "]++["\(p) " | p in arg_sort(PosicionDeEscena)]++["]\n"]++["Costo: \(costo) \n"];
%output["Costo: \(costo) \n"];
