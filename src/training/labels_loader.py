"""
convert.py
Converte modelo Keras (.h5) para Core ML (.mlpackage) com suporte a classificação.
Adiciona classLabel para que o Vision retorne VNClassificationObservation.
"""

import requests

def load_labels(url: str) -> str:
    print(f"🔽 Baixando labels a partir da url: {url}")
    r = requests.get(url)
    print(f"✅ Labels baixadas")
    return r.text

def remove_background_label(labels: str) -> str:
    print("Removendo primeira linha das labels")
    new_labels = "\n".join(labels.splitlines()[1:])
    print("Primeira linha das labels removida")
    return new_labels
