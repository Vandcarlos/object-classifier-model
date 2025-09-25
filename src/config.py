import yaml
import os

def load_config(path: str = "configs/config.yaml") -> dict:
    """Carrega e retorna o conteúdo do arquivo YAML como dict."""
    if not os.path.exists(path):
        raise FileNotFoundError(f"Arquivo de configuração não encontrado: {path}")
    
    with open(path, "r") as f:
        return yaml.safe_load(f) or {}
    

if __name__ == "__main__":
    cfg = load_config()
    print(cfg)
