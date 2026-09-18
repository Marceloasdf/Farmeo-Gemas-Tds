import sys
import os
import cv2
import numpy as np
import mss

def buscar_boton():
    ruta_dir = os.path.dirname(os.path.abspath(__file__))
    ruta_template = os.path.join(ruta_dir, "BotonReinicio.png")

    template = cv2.imread(ruta_template)
    if template is None:
        print("ERROR_IMAGEN")
        sys.exit(2)

    alto_temp, ancho_temp, _ = template.shape

    # Captura de pantalla ultra rápida con mss
    with mss.MSS() as sct:
        # monitor 1 suele ser la pantalla principal
        monitor = sct.monitors[1]
        captura = sct.grab(monitor)
        
        # Convertir a formato OpenCV BGR (mss captura en BGRA)
        pantalla_bgra = np.array(captura)
        pantalla = cv2.cvtColor(pantalla_bgra, cv2.COLOR_BGRA2BGR)

    # Coincidencia con OpenCV
    resultado = cv2.matchTemplate(pantalla, template, cv2.TM_CCOEFF_NORMED)
    _, max_val, _, max_loc = cv2.minMaxLoc(resultado)

    porcentaje = round(max_val * 100, 1)

    if max_val >= 0.70:
        centro_x = max_loc[0] + (ancho_temp // 2)
        centro_y = max_loc[1] + (alto_temp // 2)
        print(f"{centro_x} {centro_y}")
        #print(f"OK {centro_x} {centro_y} {porcentaje}")
        sys.exit(0)
    else:
        print(f"NO {porcentaje}")
        sys.exit(1)

if __name__ == "__main__":
    buscar_boton()