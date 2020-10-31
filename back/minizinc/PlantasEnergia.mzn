% parametros

int: dias;
int: clientes;
int: centrales;

% tres centrales electricas: nuclear, hidroelectrica y termica
array[1..centrales] of int: costos;
array[1..centrales] of int: capacidades;
array[1..centrales] of 0..100: porcentajeRegimen;
array[1..centrales] of int: diasRegimen;

array[1..clientes, 1..dias] of int: demanda;

array[1..centrales] of int: capacidadesNoRegimen = [((capacidades[i]*porcentajeRegimen[i]) div 100)| i in 1..centrales];
array[1..centrales] of int: iCostosOrdenado = arg_sort(costos);
array[1..dias] of int: demandaDia = [sum(j in 1..clientes) (demanda[j,i])| i in 1..dias];
array[1..centrales] of var int: costoProduccion = [(sum(d in 1..dias)(produccion[i,d]))*costos[i]| i in 1..centrales];

% variables

array[1..centrales, 1..dias] of var int: produccion;

array[1..centrales, 1..dias] of var 0..1: regimenAlto;

%array producción reescrito en arreglo 1D, de tal manera que primero están las centrales ordenadas por costo y del primer día al ultimo
array[1..centrales*dias] of var int: orden = [produccion[iCostosOrdenado[i],j] | i in 1..centrales, j in 1..dias];

var int: costoProduccionTotal = sum(i in 1..centrales)(costoProduccion[i]);

% restricciones

constraint forall(i in 1..centrales)(forall(j in 1..dias)(produccion[i,j] >= 0));

%para todas las centrales, cada dia su producción debe ser menor o igual a su capacidad (es casi como la primera pero con parentesis distintos)
constraint forall(i in 1..centrales) (forall(j in 1..dias) (produccion[i, j] <= capacidades[i]));

%Para todos los días la suma de produccion de todas las centrales deben ser iguales a la demanda del día
constraint forall(d in 1..dias)((sum(i in 1..centrales)(produccion[i,d])) = demandaDia[d]);

%Regimen alto es uno si la producción es mayor que el porcentaje indicado, cero en otro caso
constraint forall (i in 1..centrales) (forall(j in diasRegimen[i]..dias) 
  (regimenAlto[i,j] = (produccion[i,j]>capacidadesNoRegimen[i])));

%no puede pasar que la suma de días consecutivos iguales al limite de dias de regimen sean iguales,
%es decir, si tenemos n días de regimen, no pueden haber n días seguidos con regimenAlto igual a 1
constraint forall (i in 1..centrales) (forall(j in diasRegimen[i]..dias)
  (not(diasRegimen[i] == (sum(k in j-diasRegimen[i]+1..j) (regimenAlto[i,k])))));


%Si lo que puede producir es menor que lo que hace falta para completar la demanda entonces la central da todo lo que puede
%Si lo que hace falta para completar la demanda es menor que lo que puede hacer, entonces da lo que haga falta para completar la demanda (puede ser cero)
constraint forall(i in 1..centrales) (forall(j in 1..dias)
  (produccion[iCostosOrdenado[i],j] = min(capacidades[iCostosOrdenado[i]]*regimenAlto[iCostosOrdenado[i],j]
                                          + capacidadesNoRegimen[iCostosOrdenado[i]]*(1-regimenAlto[iCostosOrdenado[i],j]),
                                          demandaDia[j]-sum(k in 1..(i-1)) (produccion[iCostosOrdenado[k],j]))
  ));


% funcion objetivo 

solve:: int_search(orden, input_order, indomain_max) minimize costoProduccionTotal;

% salida
output["costos:\n"] ++ ["\(i): \(costos[i]); " | i in 1..length(costos)] ++ 
      ["\ntotal: \(costoProduccionTotal)\n"] ++ 
      ["\nproduccion:\n"] ++ ["\(produccion[i,j])" ++ if j == dias then "\n" else " " endif | i in 1..centrales,j in 1..dias];                                
      