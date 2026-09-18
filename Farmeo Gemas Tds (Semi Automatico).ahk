SendMode("Event")


;---Colores--- 
ColorVerde:="0x206335" ;verde de poder mejorar
ColorGris:="0x818181" ;gris de no poder mejorar

;---Coordenadas---
MejorarX:=1148
MejorarY:=713

;---GUI para estado Actual---
GuiEstado := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
GuiEstado.BackColor := "Black"
WinSetTransColor("Black 150", GuiEstado)

;--- Texto del estado actual ---
GuiEstado.SetFont("s13 cffffff", "Arial")
TextoEstado := GuiEstado.Add("Text", "w1000 r6", "Estado: esperando partida")

;---GUI para vueltas completadas---
GuiEstado.SetFont("s13 c00ffff", "Arial")
TextoVueltas := GuiEstado.Add("Text", "w1000 r1 y+5", "Vueltas completadas: 0")
VueltasCompletadas := 0

GuiEstado.Show("x10 y80 NoActivate")


F1::IniciarGrindeo()
F2::Reload
F3::AjustarCamara
F4::ReiniciarAlPerder()

F7::Pause(-1)
F8::ExitApp

IniciarGrindeo() {
    Global TextoEstado
    Global TextoVueltas
    Global VueltasCompletadas

    loop{
        TextoEstado.Value := "Iniciando Nueva Vuelta"

        ;Ready  
        MouseClick("left", 1060,182,,2)
        sleep(1000)

        ;Poner y Mejorar Pyro
        TextoEstado.Value := "Estado: intentando Poner Pyromancer"
        ColocarTorreSegura("1", 833,60)
        TextoEstado.Value := "Estado: Pyromancer colocado, intentando mejorar"
        
        ;Ponerlo en Farthest
        MouseClick("Left", 704,810,,2)
        Sleep(500)
        MouseClick("Left", 704,810,,2)
        MejorarTorre(3) 

        ;Poner y Mejorar Crook 1
        TextoEstado.Value := "Estado: intentando Poner Crook Boss"
        ColocarTorreSegura("2", 853,255)
        TextoEstado.Value := "Estado: Crook Boss colocado, intentando mejorar"
        MejorarTorre(2) 

        ;Poner y Mejorar Crook 2
        TextoEstado.Value := "Estado: intentando Poner Crook Boss 2"
        ColocarTorreSegura("2",907,270)
        TextoEstado.Value := "Estado: Crook Boss 2 colocado, intentando mejorar"
        MejorarTorre(2) 

        ;Podria Poner cualquier torre aqui la verdad
        /*;Poner y Mejorar Minigunner 
        ColocarTorreSegura("3", 960, 291)
        MejorarTorre(2)*/

        ReiniciarAlPerder()

        VueltasCompletadas++
        TextoVueltas.Value := "Vueltas completadas: " . VueltasCompletadas

    }
}

;---Funciones---
ColoresSimilares(Color1, Color2, Tolerancia := 15) {
    ; Extraer canales RGB del primer color
    r1 := (Color1 >> 16) & 0xFF
    g1 := (Color1 >> 8) & 0xFF
    b1 := Color1 & 0xFF

    ; Extraer canales RGB del segundo color
    r2 := (Color2 >> 16) & 0xFF
    g2 := (Color2 >> 8) & 0xFF
    b2 := Color2 & 0xFF

    ; Verificar que cada canal esté dentro del margen permitido
    return (Abs(r1 - r2) <= Tolerancia) 
        && (Abs(g1 - g2) <= Tolerancia) 
        && (Abs(b1 - b2) <= Tolerancia)
}


;intentara mejorar la torre hasta que pueda, y lo hara la cantidad de veces que le digamos
MejorarTorre(Ciclos) {
    Global TextoEstado

    Loop Ciclos {
        Loop {
            ColorActual := PixelGetColor(MejorarX, MejorarY)
            TextoEstado.Value := "Estado: color visto: " . ColorActual . "`ncolor que debería ver para mejorar: " . ColorVerde

            ;si es verde Hacemos Click y salimos del loop
            if ColoresSimilares(ColorActual, ColorVerde, 20) {
                TextoEstado.Value := "Estado: mejora disponible, haciendo click" 
                MouseClick("left", MejorarX, MejorarY)
                Sleep(500)
                break 
            } else {
                ;si aun no es verde, esperamos 500 milisegundos mas
                TextoEstado.Value := "Estado: mejora no disponible, esperando `ncolor visto: " . ColorActual . "`ncolor que debería ver para mejorar: " . ColorVerde
                Sleep(250)
            }
        }
        Sleep(500) 
    }
} 

;intentara poner la torre hasta que pueda
ColocarTorreSegura(Tecla, CoordMapaX, CoordMapaY) {
    Global TextoEstado

    Loop {
        ; 1. Seleccionamos la torre y hacemos clic en el mapa
        Send(Tecla)
        Sleep(500)
        MouseClick("left", CoordMapaX, CoordMapaY, , 2)
        Sleep(3000) ;esto es lo que espera antes de comprar el menu
        
        ;Comprobamos si aparecio el menu de mejorar viendo si estan unos de los 2 colores
        ColorActual := PixelGetColor(MejorarX, MejorarY)
        TextoEstado.Value := "Estado: color visto " . ColorActual . "`ncolores que deberían ver " . ColorGris . " o " . ColorVerde

        if (ColoresSimilares(ColorActual, ColorGris, 20) || ColoresSimilares(ColorActual, ColorVerde, 20)) {
            TextoEstado.Value := "Estado: torre colocada correctamente" ;`ncolor visto " . ColorActual . "`ncolores que deberían ver " . ColorGris . " o " . ColorVerde
            break 
        } else {
            ;Fallo, esperamos 2 segundos mas y esperamos
            TextoEstado.Value := "Estado: no se pudo colocar la torre, reintentando `ncolor visto " . ColorActual . "`ncolores que deberían ver " . ColorGris . " o " . ColorVerde
            Sleep(2000) 
        }
    }
}

;Ajusta la camara para que el resto del macro funcione 
AjustarCamara() {

    ;Resetear Personaje
    Send("{Esc}")
    Sleep(500)
    Send("{R}")
    Sleep(500)
    Send("{Enter}")
    Sleep(8000)

    ;Zoom Adentro
    Send("{i down}")
    Sleep(1000)
    Send("{i up}")
    Sleep(1000)

   ;Mover Mouse Hacia Abajo
    MouseMove(0,100,2,"R")
    Sleep(1000)

    ;Zoom Afuera
    Send("{o down}")
    Sleep(1000)
    Send("{o up}")
    Sleep(1000)
}

ReiniciarAlPerder() {
    Global TextoEstado
    TextoEstado.Value := "Estado: Esperando fin de partida (OpenCV)..."
    archivoTemp := A_ScriptDir . "\temp_coords.txt"

    Loop {
        ; Ejecución silenciosa con Hide hacia archivo temporal
        cmd := 'python.exe "' . A_ScriptDir . '\detectar_boton.py" > "' . archivoTemp . '"'
        codigoSalida := RunWait(A_ComSpec . ' /c ' . cmd, A_ScriptDir, "Hide")

        if (codigoSalida == 0 && FileExist(archivoTemp)) {
            salidaRaw := FileRead(archivoTemp)
            salida := Trim(RegExReplace(salidaRaw, "[\r\n]+", ""))
            try FileDelete(archivoTemp)

            if (salida != "") {
                coords := StrSplit(salida, " ")
                btnX := Integer(coords[1])
                btnY := Integer(coords[2])

                TextoEstado.Value := "Estado: Botón detectado en (" . btnX . ", " . btnY . ")! Reiniciando..."
                
                CoordMode("Mouse", "Screen")
                MouseMove(btnX, btnY, 2)
                Sleep(300)
                Click()
                Sleep(500)

                MouseMove(0, 0, 0)
                break
            }
        } else if (codigoSalida == 2) {
            try FileDelete(archivoTemp)
            TextoEstado.Value := "Error: No se encontró BotonReinicio.png"
            MsgBox("Error: Falta el archivo BotonReinicio.png en la carpeta del script.")
            return
        } else {
            try FileDelete(archivoTemp)
            TextoEstado.Value := "Estado: Partida en curso, esperando pantalla final..."
            Sleep(2000)
        }
    }

    ; Espera a que recargue la sala/mapa
    Sleep(8000)
    TextoEstado.Value := "Estado: Nueva partida lista"
}



