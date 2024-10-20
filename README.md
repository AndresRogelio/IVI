# Análisis del Índice de Valor de Importancia (IVI) en Ecosistemas Forestales

Este proyecto calculó y visualizó el Índice de Valor de Importancia (IVI) de diferentes especies en un ecosistema forestal. El IVI se utiliza para evaluar la importancia relativa de cada especie dentro del ecosistema, considerando su frecuencia, abundancia y dominancia.

## Descripción del Código

El código realiza las siguientes tareas:

1. **Carga de bibliotecas**: Se utilizan herramientas del paquete `tidyverse` para manipular y visualizar datos.
2. **Preparación de datos**: Se leen y filtran los datos de un archivo CSV que contiene información sobre especies de árboles.
3. **Cálculo del IVI**: Se utiliza una función definida en un archivo separado (`getIVI.RData`) para calcular el IVI para cada especie.
4. **Visualización**: Se crea un gráfico de barras apiladas para mostrar el IVI y sus componentes (abundancia, dominancia y frecuencia) de las especies más relevantes.

## Requisitos

- R (versión 4.0 o superior)
- RStudio (opcional, pero recomendado)
- Paquete `tidyverse`

### Instalación

1. Clona este repositorio en tu máquina local.
2. Abre R o RStudio.
3. Establece el directorio de trabajo al directorio donde se encuentra el archivo `getIVI.RData` y el CSV con los datos.
4. Ejecuta el código en el archivo.

## Uso

1. Cargar bibliotecas y datos
```r
library(tidyverse)
setwd("G:/calcIVI")
load("getIVI.RData")
```
- Se carga la biblioteca `tidiverse`, que incluye herramientas para manipulación de datos y visualización.
- Se establece el directorio de trabajo y se cargan los datos necesarios.

2. Preparación de datos
```r
datos <- read.csv("cp1tree.csv")
datos %>%
  filter(status == "A") %>%
  select(c("sp","quadrat","dbh" )) %>%
  rename(especie = sp, subparcela = quadrat, dap = dbh) -> datos 
```
- Se leen los datos de un archivo CSV.
- Se filtran los datos para incluir solo especias activas (status "A") y se seleccionan las columnas relevantes.
- Las columnas se renombrarn para facilitar su uso.

3. Cálculo del IVI
```r
IVI <- getIVI(datos)
```
- Se llama a la función `getIVI()` (definida en el archivo cargado) para calcular el IVI de las especies a partir de los datos preparados.

4. Preparación de datos para gráficos
```r
IVI.1 <- IVI[1:length(IVI[ ,1])-1, c(1,3,5,7,8)]
IVI.1 %>%
  gather(key = "parameter", value = "percent", -Species, -IVI) -> IVI.2
```
- Se seleccionan y reorganizan las columnas del IVI para facilitar la visualización.
- Se utilizan funciones para "derretir" los datos, creando un formato mas adecuado para graficar.

5. Ordenar y ajustar datos
```r
IVI.2 %>%
  arrange(desc(IVI)) %>%
  as_tibble() -> IVI.3
```
- Los datos se ordenan en funci´n del IVI para identificar las especies más importantes.

6. Análisis de especies menos comunes.
```r
IVI.otras <- IVI.3 %>% slice(-(1:60))
Den <- IVI.otras %>% filter(parameter=="relDen") %>% summarise(relDen = sum(percent)) %>% pull()
```
- Se separan las especies que no están en el top 60.
- Se calculan los valores de abundancia, frecuencia y dominancia para estas especies.

7. Gráfico del IVI
```r
mainplot <- ggplot(IVI.top, aes(width = 0.95, fill = parameter, y = percent, x = Species)) +
  geom_bar(position = "stack", stat = "identity", color="black")
```
- Se crea un gráfico de barras apiladas que visualiza el IVI y sus compoennte (abundancia, dominancia y frecuencia) para las especies seleccionadas

8. Personalización dle gráfico
- Se añaden títulos, etiquetas y se personaliza la leyenda y los ejes para mejorar la presentación dle gráfico.

### Ejemplo de Ejecución

Asegúrate de que el archivo `cp1tree.csv` esté en la misma carpeta que tu script. Luego, ejecuta el código y observa la salida del gráfico.

## Resultados

El código generará un gráfico que representa el IVI de las especies en el ecosistema, mostrando cómo cada una contribuye a la estructura del bosque.

## Referencias

- Curtis, J. T., & McIntosh, R. P. (1950). The Interrelations of Certain Analytical Features of the Plant Community. *Ecological Monographs*, 20(4), 341-358.
- Documentación de R y `tidyverse`.

## Conjuntos de Datos

- **cp1tree.csv**: Conjunto de datos que contiene información sobre especies de árboles, su estado, diámetro a la altura del pecho (DAP), y ubicación en el ecosistema.

## Contribuciones
Si deseas contribuir a este proyecto, siéntete libre de hacer un fork del repositorio y enviar pull requests con mejoras o nuevas funcionalidades.
