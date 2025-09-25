"""
model_loader.py
Carrega um modelo pré-treinado.
Salva em formato Keras (.h5) para futura conversão.
"""

import tensorflow as tf

def load_base_model():
    kwargs = {
        "weights": "imagenet"
    }

    print(f"Inicando carregamento do modelo com parâmetros {kwargs}")
    model = tf.keras.applications.MobileNetV2(**kwargs)
    print("Modelo carregado ")

    return model

if __name__ == "__main__":
    load_base_model()
