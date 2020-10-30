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
array[int,1..2] of int: Disponibilidad;
array[int,1..2] of ACTORES: Evitar;

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
  
% Dado un actor suma los costos por las escenas en que esta                         
array[ACTORES] of var int : TiempoDe = [(
                       let {
                         var int: primera = min([PosicionDeEscena[e] | e in EscenaDe[j]]);
                         var int: ultima = max([PosicionDeEscena[e] | e in EscenaDe[j]]);
                       }
                       in
                      (sum(i in 1..nEscenas)
                          (if PosicionDeEscena[i] >= primera
                              /\
                              PosicionDeEscena[i] <= ultima
                           then Duracion[i]
                           else 0
                           endif))) | j in ACTORES];                           

%Suma la duracion de las escenas en que dos actores que estan en la lista evitar se encuentran en el mismo momento en el set                     
var int: evitar = (sum(j in 1..length(col(Evitar,1)))(
                      let {
                           set of int: a = EscenaDe[row(Evitar,j)[1]];
                           set of int: b = EscenaDe[row(Evitar,j)[2]];
                           var int: primera = (if sum(a intersect b) != 0
                                               then min([PosicionDeEscena[e] | e in a intersect b])
                                               else 0
                                               endif);
                           var int: ultima = (if primera != 0
                                              then min([max([PosicionDeEscena[e] | e in a]),
                                                        max([PosicionDeEscena[e] | e in b])])
                                              else -1
                                              endif);
                     }
                     in
                     (sum(i in 1..nEscenas)
                          (if PosicionDeEscena[i] >= primera
                              /\
                              PosicionDeEscena[i] <= ultima
                           then Duracion[i]
                           else 0
                           endif))));
                                   
% Restricciones

constraint all_different(PosicionDeEscena);

constraint forall(i in 1..length(col(Disponibilidad,1)))
                  (if row(Disponibilidad,i)[2] = 0
                  then TiempoDe[ACTORES[row(Disponibilidad,i)[1]]] > row(Disponibilidad,i)[2]
                  else TiempoDe[ACTORES[row(Disponibilidad,i)[1]]] <= row(Disponibilidad,i)[2]
                  endif);

%solver

solve minimize 9*costo + evitar;

%salida

output ["[ "]++["\(p) " | p in arg_sort(PosicionDeEscena)]++["]\n"]
++["Tiempo compartido: \(evitar)"]++["\n"]
++["Costo: \(costo) \n"];
%output["Costo: \(costo) \n"];
