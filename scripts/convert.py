import tensorflow as tf

from src.config import load_config
from src.conversion.convert_loop import convert
from typing import List

CFG = load_config()
MODEL_TRAINED_PATH = CFG["paths"]["trained"]["model"]
MODEL_LABELS_PATH = CFG["paths"]["trained"]["labels"]
IOS_MODEL_PATH = CFG["paths"]["artifactory"]["ios"]
ANDROID_MODEL_PATH = CFG["paths"]["artifactory"]["android"]

def main():
    model = load_model()
    ios_model, android_model = convert(model = model, labels = None)
    save_models(ios_model, android_model)

def load_model() -> tf.keras.Model:
    print(f"Carregando modelo salvo no path: {MODEL_TRAINED_PATH}")

    try:
        model = tf.keras.models.load_model(MODEL_TRAINED_PATH)
        print(f"Modelo carregado")
        return model
    except (OSError, FileNotFoundError) as e:
        raise SystemExit(
            f"[ERRO] Não foi possível abrir o modelo em {MODEL_TRAINED_PATH}.\n"
            "→ Certifique-se de que o treino foi executado e o arquivo está no local correto.\n"
            f"Detalhe técnico: {e}"
        )

def load_labels() -> List[str]:
    with open(MODEL_LABELS_PATH, "r") as f:
        labels = [line.strip() for line in f.readlines()]
        print(f"✅ {len(labels)} labels carregadas.")
        return labels

def save_models(ios_model, android_model):
    ios_model.save(IOS_MODEL_PATH)
    print(f"iOS model saved at {IOS_MODEL_PATH}")

    with open(ANDROID_MODEL_PATH, "wb") as f:
        f.write(android_model)
        print(f"android model saved at {ANDROID_MODEL_PATH}")

if __name__ == "__main__":
    main()
