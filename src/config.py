from dataclasses import dataclass
from pathlib import Path
from typing import List
import yaml

CONFIG_PATH = Path("configs/config.yaml")

@dataclass
class TrainingConfig:
    base_model_path: Path
    output: TrainingOutputConfig
    epochs: int
    batch_size: int
    learning_rate: float
    image_size: List[int]

@dataclass
class TrainingOutputConfig:
    dir: Path
    model_name: str
    labels_name: str

@dataclass
class IOSConversionConfig:
    model_name: str

@dataclass
class AndroidConversionConfig:
    model_name: str

@dataclass
class ConversionConfig:
    input_model_path: Path
    input_labels_path: Path
    artifactory_dir: Path
    ios: IOSConversionConfig
    android: AndroidConversionConfig

@dataclass
class InferenceConfig:
    model_path: Path
    labels_path: Path
    image_size: List[int]

@dataclass
class AppConfig:
    training: TrainingConfig
    conversion: ConversionConfig
    inference: InferenceConfig

def load_config(path: Path = CONFIG_PATH) -> AppConfig:
    with open(path) as f:
        raw = yaml.safe_load(f)

    tr = raw["training"]
    cv = raw["conversion"]
    inf = raw["inference"]

    return AppConfig(
        training=TrainingConfig(
            base_model_path=Path(tr["base_model_path"]),
            output=TrainingOutputConfig(dir=tr["output"]["dir"], model_name=tr["output"]["model_name"], labels_name=tr["output"]["labels_name"]),
            epochs=tr["epochs"],
            batch_size=tr["batch_size"],
            learning_rate=tr["learning_rate"],
            image_size=tr["image_size"],
        ),
        conversion=ConversionConfig(
            input_model_path=Path(cv["input_model_path"]),
            input_labels_path=Path(cv["input_labels_path"]),
            artifactory_dir=Path(cv["artifactory_dir"]),
            ios=IOSConversionConfig(**cv["ios"]),
            android=AndroidConversionConfig(**cv["android"]),
        ),
        inference=InferenceConfig(
            model_path=Path(inf["model_path"]),
            labels_path=Path(inf["labels_path"]),
            image_size=inf["image_size"],
        ),
    )
