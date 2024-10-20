# IVI
# El Índice de Valor de Importancia (I.V.I.), 
# formulado por Curtis & McIntosh, es posiblemente 
# el más conocido de los instrumentos para evaluar 
# la estructura horizontal de los bosques. 
# El I.V.I. se calcula para cada especie a partir
# de la suma de la frecuencia relativa, 
# la abundancia relativa y la dominancia relativa. 
# La frecuencia relativa de una especie se calcula
# como su porcentaje en la suma de las frecuencias 
# absolutas de todas las especies; 
# la abundancia relativa es la proporción 
# de los individuos de cada especie en el total 
# de los individuos del ecosistema y 
# la dominancia relativa de una especie 
# se calcula como su porcentaje en la suma 
# de las áreas basales en metros cuadrados 
# de todas las especies. 
# Con éste índice es posible comparar, 
# el peso ecológico de cada especie 
# dentro del ecosistema.

library(tidyverse)
setwd("G:/calcIVI")
getwd()
load("getIVI.RData")
# Esta función necesita tres variables
# "especie", "subparcela" y "dap"

# Preparando los datos
dir()
datos <- read.csv("cp1tree.csv")
datos %>%
  filter(status == "A") %>%
  select(c("sp","quadrat","dbh" )) %>%
  rename(especie = sp, subparcela = quadrat, dap = dbh) -> datos 

# Cálculo del IVI
IVI <- getIVI(datos)
head(IVI)
tail(IVI)

# Preparación para el gráfico
# Elimina última fila, selecciona las columnas
# especie, y variables relativas
IVI.1 <- IVI[1:length(IVI[ ,1])-1, c(1,3,5,7,8)]
head(IVI.1)
tail(IVI.1)

IVI.1 %>%
  gather(key = "parameter", value = "percent", -Species, -IVI) -> IVI.2
head(IVI.2)
tail(IVI.2)

# Ordenar en función del IVI
IVI.2 %>%
  arrange(desc(IVI)) %>%
  as_tibble() -> IVI.3
head(IVI.3)
tail(IVI.3)


# Conversión a factor para preservar la secuencia en nuestra visualización
IVI.3$Species <- factor(IVI.3$Species, 
  levels = c(unique(IVI.3$Species), "Otras sp."))
# Revisar
levels(IVI.3$Species)
str(IVI.3)
head(IVI.3)

# -----------------------------------------
# Top 20 del IVI
IVI.3 %>% slice(1:60) -> IVI.top 

# -----------------------------------------
# Otras especies
IVI.3 %>% slice(-(1:60)) -> IVI.otras

# Otras especies abundancia 
IVI.otras %>% filter(parameter=="relDen") %>%
  summarise(relDen = sum(percent)) %>% 
  pull() -> Den
  
# Otras especies frecuencia
IVI.otras %>% filter(parameter=="relFreq") %>%
  summarise(relFreq = sum(percent)) %>% 
  pull() -> Freq
# Otras especies Dominancia
IVI.otras %>% filter(parameter=="relDom") %>%
  summarise(relDom = sum(percent)) %>% 
  pull() -> Dom
# sumIVI de otras especies
ivi <- Den + Freq + Dom

# agrego la línea 61
IVI.top %>% add_row(tibble_row(Species = "Otras sp.",
  IVI = ivi, parameter = "relDen", percent = Den)) -> IVI.top
# agrego la linea 62
IVI.top %>% add_row(tibble_row(Species = "Otras sp.",
  IVI = ivi, parameter = "relFreq", percent = Freq))-> IVI.top
# agrego la línea 63
IVI.top %>% add_row(tibble_row(Species = "Otras sp.",
  IVI = ivi, parameter = "relDom", percent = Dom))-> IVI.top

# Para mantener el orden convierto especie en factor
IVI.top$Species <- factor(IVI.top$Species,
  levels = c(unique(IVI.top$Species)))

#
tick <- round(unique(IVI.top$IVI), 1)

##----------------------------------------------
# Creación del gráfico para el IVI
mainplot <- ggplot(IVI.top, aes(width = 0.95,
  fill = parameter, y = percent, x = Species)) +
  geom_bar(position = "stack", stat = "identity",
    color="black")
mainplot <- mainplot + geom_hline(yintercept = 0.1,
  color = "white")
# Añadir marcas de y
mainplot <- mainplot + 
  scale_y_continuous(breaks = round(seq(0, max(70), by = 10), 1),
    labels = scales::label_dollar(prefix = "", suffix = "%"),
    expand = c(0,0), limits = c(0, 69.3))
# Cambios en la leyenda
mainplot <- mainplot + 
  scale_fill_manual(name="Parámetros",
values = c("relDen" = "#8dd3c7",
  "relDom" = "#80b1d3",
  "relFreq" = "#fdb462"),
labels=c("relDen" = "Abundancia", 
  "relDom" = "Dominancia", 
  "relFreq" = "Frecuencia"),
breaks=c("relDen", "relDom", "relFreq"))
# Título de la gráfica
mainplot <- mainplot + 
  ggtitle("Análisis del Índice de Valor de Importancia")
# Ajuste de las etiquetas x e y
mainplot <- mainplot + 
  xlab("Especies") + ylab("Porcentaje")
#
mainplot <- mainplot + 
geom_text(aes(label = round(percent, 1)), size = 2, hjust = 0.5, vjust = 1.1, position = "stack") 
#
mainplot <- mainplot + 
  theme(panel.background = element_rect(fill = "white",
    colour = "black"))
# Girar las marcas del eje x
mainplot <- mainplot + guides(x = guide_axis(angle = 90))
# Mostrar la gráfica
mainplot

# FIN