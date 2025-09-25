import tensorflow as tf
from typing import Tuple, Optional

from .model_loader import load_base_model
from .labels_loader import load_labels

def train_model(labels_url: str, base_model: Optional[tf.keras.Model] = None) -> Tuple[tf.keras.Model, tf.keras.Model, str]:
    if base_model is None:
        base_model = load_base_model()
    
    print("Iniciando treinamento")
    model_trained = base_model
    print("Treinamento finalizado")

    labels = load_labels(labels_url)

    return base_model, model_trained, labels

if __name__ == "__main__":
    train_model()