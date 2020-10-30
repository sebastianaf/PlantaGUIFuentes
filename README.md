# PlantasDeEnergía
Complejidad y optimización -> Proyecto 2

## Estudiantes

Jaime Cuartas Granada, 
Emily Esmeralda Carvajal Camelo,
Sebastián Afanador Fontal

## Instrucciones

Para poder ejecutar este proyecto es necesario tener en su computador docker y docker-compose
Si utiliza una distribución de linux (Ubuntu) puede utilizar

```
sudo apt-get install docker.io
sudo apt install docker-compose
```

## Ejecutar

Una vez clonado el repositorio en la carpeta raiz debe ejecutar

```
docker-compose up --build
docker exec -it react npm install --save axios
```
**Nota:**
El comando anterior va a tomar algun tiempo, por favor sea paciente.
Este descargando y configurando minizinc, python3 y node en 2 contenedores para permitirle usar la aplicación


## Finalmente
Una vez iniciado el docker puede acceder a la aplicación a través del

`localhost:8000`

