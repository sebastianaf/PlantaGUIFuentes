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

% restricciones

constraint forall(i in 1..centrales)(forall(j in 1..dias)(produccion[i,j] >= 0));

%para todas las centrales, cada dia su producción debe ser menor o igual a su capacidad (es casi como la primera pero con parentesis distintos)
constraint forall(i in 1..centrales) (forall(j in 1..dias) (produccion[i, j] <= capacidades[i]));

%Para todos los días la suma de produccion de todas las centrales deben ser iguales a la demanda del día
constraint forall(d in 1..dias)((sum(i in 1..centrales)(produccion[i,d])) = demandaDia[d]);

% csp -  cop

array[1..centrales*dias] of var int: orden =
      
      [produccion[iCostosOrdenado[i],j] | i in 1..centrales, j in 1..dias]
  ;

constraint 
  
    forall(i in 1..dias)
    (
      (forall(j in 1..centrales)
        (let{
        %la capacidad maxima de cada central está definida de la siguiente manera n un día es lo que le permita su capacidad maxima sin superar el umbral para llegar al regimen alto o si se lleg, o lo que hace falta para cubrir la demanda
          var 0..1: regimenAlto;
          var int: maxCapacidad = 
          %Se puede decidir si se llega o no al regimen alto este dia por parte de la central, si se decide no superar el umbral entonces lo mejor es llegar al limite sin penalización. Si se supera, entonces lo mejor es cubrir toda la capacidad de la central.
              min([
              
     (capacidades[iCostosOrdenado[j]]*(porcentajeRegimen[iCostosOrdenado[j]]+(100-porcentajeRegimen[iCostosOrdenado[j]])*regimenAlto)) div 100,
              %la central podría suministrar lo que hace falta para cubrir la demanda (si no hace falta nada para cubrir la demanda, puede tomar el valor de cero)
                    demandaDia[i] - sum(k in 1..(j-1)) (produccion[iCostosOrdenado[k],i]),
                    
                    %vamos tantos dias hacia atras para verificar si la produccion esos días ha superado el umbral que lo catalogaría como regimen alto. Sumamos las veces que esto ocurre, si le hace falta un día para llegar a lo maximo permitido, entonces este día no se podrá superar el regimen y se llega hasta el limite (1-x con x siendo un boolean lo uso para negar)
                    
                    (capacidades[iCostosOrdenado[j]]*(porcentajeRegimen[iCostosOrdenado[j]]+(100-porcentajeRegimen[iCostosOrdenado[j]])*
                      (1-( diasRegimen[iCostosOrdenado[j]]-1 = 
                        sum(k in (i-diasRegimen[iCostosOrdenado[j]]+1)..(i-1) where k>0) 
                          (produccion[iCostosOrdenado[j],k] > capacidadesNoRegimen[iCostosOrdenado[j]]
                          
                      ))))) div 100
                      ]);
        }
        in
          produccion[iCostosOrdenado[j],i] = maxCapacidad
        )
      )
    )
  ;

var int: costoProduccionTotal = sum(i in 1..centrales)(costoProduccion[i]);


%solve:: int_search(costoProduccion, first_fail, indomain_min) satisfy;
%solve:: int_search(costoProduccion, smallest, indomain_split) minimize costoProduccionTotal;
solve:: int_search(orden, input_order, indomain_max) minimize costoProduccionTotal;
%solve:: int_search(costoProduccion, smallest, indomain_max) minimize costoProduccionTotal;
%solve minimize costoProduccionTotal;
%solve satisfy;

output["costos:\n"] ++ ["\(i): \(costos[i]); " | i in 1..length(costos)] ++ 
      ["\ncostoProduccion:\n"] ++ ["\(i): \(costoProduccion[i]); " | i in 1..length(costoProduccion)] ++ 
      ["\ncapacidades:\n"] ++ ["\(i): \(capacidades[i]); " | i in 1..length(capacidades)] ++ 
      ["\ntotal: \(costoProduccionTotal)\n"] ++ 
      ["demanda:\n"] ++ ["\(demanda[i,j])" ++ if j == dias then "\n" else " " endif | i in 1..clientes,j in 1..dias] ++
      ["produccion:\n"] ++ ["\(produccion[i,j])" ++ if j == dias then "\n" else " " endif | i in 1..centrales,j in 1..dias];                                
      