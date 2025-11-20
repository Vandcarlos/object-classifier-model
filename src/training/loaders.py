import requests
import tensorflow as tf

def load_base_model():
    kwargs = {
        "weights": "imagenet"
    }

    print(f"Inicando carregamento do modelo com os hiperparâmetros {kwargs}")
    model = tf.keras.applications.MobileNetV2(**kwargs)
    print("Modelo carregado ")

    return model

def load_labels(url: str) -> str:
    print(f"🔽 Baixando labels a partir da url: {url}")
    r = requests.get(url)
    print(f"✅ Labels baixadas")
    return r.text

def _remove_background_label(labels: str) -> str:
    print("Removendo primeira linha das labels")
    new_labels = "\n".join(labels.splitlines()[1:])
    print("Primeira linha das labels removida")
    return new_labels
