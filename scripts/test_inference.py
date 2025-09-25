"""
test_inference.py
Testa o modelo TensorFlow localmente antes de enviar para Core ML.
"""

import tensorflow as tf
import numpy as np
from PIL import Image, ImageFile

from src.config import load_config

from typing import List, Tuple

CFG = load_config()
MODEL_TRAINED_PATH = CFG["paths"]["trained"]["model"]
INFERENCES = CFG["inferences"]

def main():
    model = tf.keras.models.load_model(MODEL_TRAINED_PATH)
    for index, inference in enumerate(load_inferences()):
        print(f"predizendo a inferencia {index}")
        label, prob = predict(model, inference[0])
        match_inference = label == inference[1]
        print(f"Predição feita."
              f"O modelo previu a classe corretamente? {match_inference}."
              f"era esperado: {inference[1]}, e veio: {label} com uma probabilidade de: {prob*100:.2f}%")

def load_inferences() -> List[Tuple[ImageFile.ImageFile, str]]:
    return [
        (load_image(INFERENCE["path"]), INFERENCE["predict_class"])
        for INFERENCE in INFERENCES
    ]

def load_image(path, target_size=(224, 224)):
    img = Image.open(path).convert("RGB")
    img = img.resize(target_size)
    img = np.array(img)
    img = tf.keras.applications.mobilenet_v2.preprocess_input(img)
    img = np.expand_dims(img, axis=0)
    return img

def predict(model, img) -> Tuple[str, int]:
    print(f"predizendo a inferencia")
    predictions = model.predict(img)
    print("decodando a inferencia")
    decoded_predictions = tf.keras.applications.mobilenet_v2.decode_predictions(predictions, top=1)
    _, label, prob = decoded_predictions[0][0]
    return label, prob

if __name__ == "__main__":
    main()
