from pathlib import Path
from src.config import load_config
from src.training.train_loop import train_model

CFG = load_config()
MODEL_BASE_PATH = CFG["paths"]["base"]["model"]
MODEL_TRAINED_PATH = CFG["paths"]["trained"]["model"]
MODEL_LABELS_PATH = CFG["paths"]["trained"]["labels"]
LABELS_URL = CFG["labels_url"]

def main():
    model_base, model_trained, labels = train_model(labels_url = LABELS_URL)
    
    save_base_model(model_base)
    save_trained_model(model_trained)
    save_labels(labels)

def save_base_model(model_loaded):
    Path(MODEL_BASE_PATH).parent.mkdir(parents=True, exist_ok=True)

    if Path(MODEL_BASE_PATH).exists():
        print(f"ℹ️ Modelo base já existe, não sobrescrevendo {MODEL_BASE_PATH}")
        return
    model_loaded.save(MODEL_BASE_PATH)
    print(f"✅ Modelo carregado salvo em {MODEL_BASE_PATH}")


def save_trained_model(model_trained):
    Path(MODEL_TRAINED_PATH).parent.mkdir(parents=True, exist_ok=True)
    model_trained.save(MODEL_TRAINED_PATH)
    print(f"✅ Modelo treinado salvo em {MODEL_TRAINED_PATH}")

def save_labels(labels):
    Path(MODEL_LABELS_PATH).parent.mkdir(parents=True, exist_ok=True)
    with open(MODEL_LABELS_PATH, "w") as f:
        f.write(labels)
        print(f"✅ Labels do modelo salvo em {MODEL_LABELS_PATH}")


if __name__ == "__main__":
    main()